public with sharing class ContactRelationshipServiceImpl {
    private static final String PERMISSION_SET_STRATEGY_ADMIN = 'CRUSH_Administrator';
    private static final Integer LABEL_MAX_LENGTH = 255;

    /******************************
     *      PUBLIC METHODS
     ******************************/
    public List<GraphLinkData> getRelationships(Set<Id> contactIds, Id mapId, Boolean hasAccountPlanSetting) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapId);

        List<Contact_Relationship__c> relationships;
        if (setting.Is_Relationship_Line_Global_Scope__c) {
            relationships = ContactRelationshipSelector.newInstance()
                .selectGlobalRelationshipsById(contactIds, mapId, hasAccountPlanSetting);
        } else {
            relationships = ContactRelationshipSelector.newInstance()
                .selectLocalRelationshipsById(contactIds, mapId, hasAccountPlanSetting);
        }

        List<GraphLinkData> links = new List<GraphLinkData>();
        for (Contact_Relationship__c rel : relationships) {
            links.add(
                new GraphLinkData(
                    rel.Id,
                    rel.TempId__c,
                    rel.From_Contact__c,
                    true,
                    rel.To_Contact__c,
                    rel.Contact_Relationship_Type__c,
                    HierarchyHelperService.getLabelForRelationship(rel)
                )
            );
        }
        return links;
    }

    public void deleteCustomLinks(List<GraphLinkData> linkData) {
        Set<String> ids = new Set<String>();
        for (GraphLinkData ld : linkData) {
            if (!String.isBlank(ld.Id)) {
                ids.add(ld.Id);
            } else if (!String.isBlank(ld.tempId)) {
                ids.add(ld.tempId);
            }
        }

        List<Contact_Relationship__c> relationshipRecords = ContactRelationshipSelector.newInstance()
            .selectByIdOrTempKey(ids);

        // Placeholder Links
        List<Map_Member_Placeholder_Relationship__c> placeholderRelationshipRecords = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectByIdOrTempKey(ids);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(relationshipRecords);
        uow.registerDeleted(placeholderRelationshipRecords);
        uow.commitWork();
    }

    public void newCustomLinks(List<GraphLinkData> linkData, Id mapOrAccountPlanId) {
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (GraphLinkData ld : linkData) {
            if (String.isBlank(ld.category)) {
                continue;
            }
            if (checkForContactToContactLink(ld.fromKey, ld.toKey)) {
                Contact_Relationship__c newRel = new Contact_Relationship__c(
                    From_Contact__c = ld.fromKey,
                    To_Contact__c = ld.toKey,
                    TempId__c = ld.tempId,
                    Label__c = ld.text,
                    Contact_Relationship_Type__c = ld.category
                );
                if (!setting.Is_Relationship_Line_Global_Scope__c) {
                    newRel.put(String.valueOf(mapOrAccountPlanId.getSobjectType()), mapOrAccountPlanId);
                }
                uow.registerNew(newRel);
            } else {
                Map_Member_Placeholder_Relationship__c newPlaceholderRel = new Map_Member_Placeholder_Relationship__c(
                    From__c = ld.fromKey,
                    To__c = ld.toKey,
                    TempId__c = ld.tempId,
                    Type__c = ld.category,
                    Label__c = ld.text,
                    Contact_Relationship_Type__c = ld.category,
                    Is_Hierarchy__c = false
                );
                if (!setting.Is_Relationship_Line_Global_Scope__c) {
                    newPlaceholderRel.put(String.valueOf(mapOrAccountPlanId.getSobjectType()), mapOrAccountPlanId);
                }
                uow.registerNew(newPlaceholderRel);
            }
        }

        uow.commitWork();
    }

    public void updateCustomLinks(List<GraphLinkData> linkData) {
        Map<String, GraphLinkData> ids = new Map<String, GraphLinkData>();
        for (GraphLinkData ld : linkData) {
            if (!String.isBlank(ld.Id) && (ld.Id instanceof Id)) {
                ids.put(ld.Id, ld);
            } else if (!String.isBlank(ld.tempId)) {
                ids.put(ld.tempId, ld);
            }
        }

        updateContactCustomLinks(ids);
        updatePlaceholderCustomLinks(ids);
    }

    private void updateContactCustomLinks(Map<String, GraphLinkData> ids) {
        // Contact Links
        List<Contact_Relationship__c> relationshipRecords = ContactRelationshipSelector.newInstance()
            .selectByIdOrTempKey(ids.keySet());

        List<Map_Member_Placeholder_Relationship__c> placeholderLinksToAdd = new List<Map_Member_Placeholder_Relationship__c>();
        List<Contact_Relationship__c> contactLinksToRemove = new List<Contact_Relationship__c>();
        for (Contact_Relationship__c cr : relationshipRecords) {
            GraphLinkData gld = ids.get(cr.Id);
            if (gld == null) {
                gld = ids.get(cr.TempId__c);
            }

            if (gld == null) {
                continue;
            }

            if (checkForContactToContactLink(gld.fromKey, gld.toKey)) {
                cr.From_Contact__c = gld.fromKey;
                cr.To_Contact__c = gld.toKey;
                cr.Label__c = this.getValidString(gld.text);
            } else {
                placeholderLinksToAdd.add(
                    new Map_Member_Placeholder_Relationship__c(
                        From__c = gld.fromKey,
                        To__c = gld.toKey,
                        Label__c = this.getValidString(gld.text),
                        Type__c = gld.category,
                        pqcrush__Contact_Relationship_Type__c = gld.category
                    )
                );
                contactLinksToRemove.add(cr);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(placeholderLinksToAdd);
        uow.registerDeleted(contactLinksToRemove);
        uow.registerDirty(relationshipRecords);
        uow.commitWork();
    }

    private void updatePlaceholderCustomLinks(Map<String, GraphLinkData> ids) {
        // Placeholder Links
        List<Map_Member_Placeholder_Relationship__c> placeholderRelationshipRecords = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectByIdOrTempKey(ids.keySet());

        List<Map_Member_Placeholder_Relationship__c> placeholderLinksToRemove = new List<Map_Member_Placeholder_Relationship__c>();
        List<Contact_Relationship__c> contactLinksToAdd = new List<Contact_Relationship__c>();
        for (Map_Member_Placeholder_Relationship__c mmpr : placeholderRelationshipRecords) {
            GraphLinkData gld = ids.get(mmpr.Id);
            if (gld == null) {
                gld = ids.get(mmpr.TempId__c);
            }
            if (gld == null) {
                continue;
            }

            if (!checkForContactToContactLink(gld.fromKey, gld.toKey)) {
                mmpr.From__c = gld.fromKey;
                mmpr.To__c = gld.toKey;
                mmpr.Label__c = this.getValidString(gld.text);
            } else {
                contactLinksToAdd.add(
                    new Contact_Relationship__c(
                        From_Contact__c = gld.fromKey,
                        To_Contact__c = gld.toKey,
                        Label__c = this.getValidString(gld.text),
                        pqcrush__Contact_Relationship_Type__c = gld.category
                    )
                );
                placeholderLinksToRemove.add(mmpr);
            }
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(contactLinksToAdd);
        uow.registerDirty(placeholderRelationshipRecords);
        uow.registerDeleted(placeholderLinksToRemove);
        uow.commitWork();
    }

    private String getValidString(String label) {
        if (String.isBlank(label)) {
            return '';
        }

        if (label.length() > LABEL_MAX_LENGTH) {
            return label.left(LABEL_MAX_LENGTH);
        }

        return label;
    }

    private Boolean checkForContactToContactLink(String fromKey, String toKey) {
        Id fromId = Id.valueOf(fromKey);
        Id toId = Id.valueOf(toKey);

        if (fromId == null || toId == null) {
            return false;
        }

        if (fromId.getSobjectType() == Contact.SObjectType && toId.getSobjectType() == Contact.SObjectType) {
            return true;
        }

        return false;
    }
}