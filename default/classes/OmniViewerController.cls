public with sharing class OmniViewerController {
    // ---------------------------------------------------

    @TestVisible
    private static Set<String> contactFields {
        get {
            if (contactFields != null) {
                return contactFields;
            }

            contactFields = new Set<String>();

            List<String> objectList = new List<String>{ Contact.sObjectType.getDescribe().getName() };
            List<Schema.DescribeSObjectResult> objectDescriptions = Schema.describeSObjects(objectList);

            for (Schema.DescribeSObjectResult obj : objectDescriptions) {
                Map<String, Schema.SObjectField> fieldMap = obj.fields.getMap();
                List<Schema.SObjectField> fieldValues = fieldMap.values();

                for (Schema.SObjectField field : fieldValues) {
                    // If field is a reference type and not a ref used for a cross-object query,
                    // then add relationship Name with dot notation to final field name (ex: "Account.Name")
                    Schema.DescribeFieldResult dfr = field.getDescribe();

                    if (!dfr.isAccessible()) {
                        continue;
                    }

                    String fieldName = dfr.getName();
                    List<Schema.sObjectType> refObjectList = dfr.getReferenceTo();

                    if (dfr.getRelationshipName() != null && refObjectList != new List<Schema.sObjectType>()) {
                        String refObject = String.valueOf(UtilityForList.first(refObjectList));
                        if (String.isBlank(refObject)) {
                            continue;
                        }
                        String nameField = UTIL_Describe.getNameField(refObject);
                        if (String.isBlank(nameField)) {
                            continue;
                        }
                        contactFields.add(fieldName + '.' + nameField);
                    } else {
                        contactFields.add(fieldName);
                    }
                }
            }

            return contactFields;
        }
        set;
    }

    // ---------------------------------------------------

    @TestVisible
    private static Map<String, Set<String>> mapMembersOmniViewerFields {
        get {
            if (mapMembersOmniViewerFields != null) {
                return mapMembersOmniViewerFields;
            }

            Set<String> keyStakeholderFields = new Set<String>();
            keyStakeholderFields.add('pqcrush__Relationship_Map__r.Name');

            mapMembersOmniViewerFields = new Map<String, Set<String>>();
            mapMembersOmniViewerFields.put('contacts', contactFields);
            mapMembersOmniViewerFields.put('members', keyStakeholderFields);

            return mapMembersOmniViewerFields;
        }
        set;
    }

    @TestVisible
    private static Map<String, Set<String>> keyStakeholderOmniViewerFields {
        get {
            if (keyStakeholderOmniViewerFields != null) {
                return keyStakeholderOmniViewerFields;
            }

            Set<String> keyStakeholderFields = new Set<String>();
            keyStakeholderFields.add('pqcrush__Account_Plan__r.Name');

            keyStakeholderOmniViewerFields = new Map<String, Set<String>>();
            keyStakeholderOmniViewerFields.put('contacts', contactFields);
            keyStakeholderOmniViewerFields.put('keystakeholders', keyStakeholderFields);

            return keyStakeholderOmniViewerFields;
        }
        set;
    }

    // ---------------------------------------------------

    @AuraEnabled
    public static Contact getContactById(Id contactId) {
        List<Contact> contacts = ContactSelector.newInstance()
            .selectByIdAndSelectFields(new Set<Id>{ contactId }, contactFields);

        if (contacts == null || contacts.isEmpty()) {
            return null;
        }

        return contacts.get(0);
    }

    @AuraEnabled
    public static Relationship_Map_Member__c getMapMemberByIdORContactId(Id objectId, Id mapId) {
        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance()
            .selectByIdOrContactIdAndMapId(
                new Set<Id>{ objectId },
                mapId,
                mapMembersOmniViewerFields.get('members'),
                new Set<String>{ 'Id' }
            );

        if (members == null || members.isEmpty()) {
            return null;
        }

        return members.get(0);
    }

    @AuraEnabled
    public static Key_Stakeholder__c getKeyStakeholderByIdORContactId(Id objectId, Id planId) {
        List<Key_Stakeholder__c> keyStakeholders = KeyStakeholderSelector.newInstance()
            .selectByIdOrContactIdAndPlanId(
                new Set<Id>{ objectId },
                planId,
                keyStakeholderOmniViewerFields.get('keystakeholders'),
                new Set<String>{ 'Id' }
            );

        if (keyStakeholders == null || keyStakeholders.isEmpty()) {
            return null;
        }

        return keyStakeholders.get(0);
    }

    @AuraEnabled
    public static Map<Id, Contact_Extended_Field__c> getContactExtendedFields(Id contactId) {
        List<Contact_Extended_Field__c> extendedFields = ContactExtendedFieldSelector.newInstance()
            .selectByContactId(new Set<Id>{ contactId });

        Map<Id, Contact_Extended_Field__c> mapContactExtendedFields = new Map<Id, Contact_Extended_Field__c>();

        for (Contact_Extended_Field__c extendedField : extendedFields) {
            mapContactExtendedFields.put(extendedField.Contact__c, extendedField);
        }

        return mapContactExtendedFields;
    }

    @AuraEnabled
    public static MatrixMember getMatrixMemberById(Id memberId) {
        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance()
            .selectById(new Set<Id>{ memberId });
        Relationship_Map_Member__c mapMember = (Relationship_Map_Member__c) UtilityForList.first(members);

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(
            mapMember.Relationship_Map__c
        );

        if (setting != null && !setting.Is_Influence_Support_Global_Scope__c) {
            return new MatrixMember(mapMember);
        }
        if (mapMember.Contact__c != null) {
        List<Contact_Extended_Field__c> contactExtFields = ContactExtendedFieldSelector.newInstance()
            .selectByContactId(new Set<Id>{ mapMember.Contact__c });

        if (contactExtFields.size() == 1) {
            Contact_Extended_Field__c contactExtField = contactExtFields[0];
            return new MatrixMember(
                mapMember,
                contactExtField.Influence__r != null ? contactExtField.Influence__r.Name : null,
                contactExtField.Support__r != null ? contactExtField.Support__r.Name : null
            );
        }
        }

        return new MatrixMember(mapMember, null, null);
    }

    @AuraEnabled
    public static List<MatrixMember> getMatrixMembersByContactId(Id contactId) {
        List<Relationship_Map_Member__c> members = new List<Relationship_Map_Member__c>();

        Map<Id, Id> memberIdxMapId = new Map<Id, Id>();

        if (Relationship_Map_Member__c.getSObjectType().getDescribe().isAccessible()) {
            members = RelationshipMapMemberSelector.newInstance().selectByContactId(new Set<Id>{ contactId });
        }

        List<MatrixMember> result = new List<MatrixMember>();

        Set<Id> mapOrAccountPlanIds = new Set<Id>();

        for (Relationship_Map_Member__c mem : members) {
            result.add(new MatrixMember(mem));
            mapOrAccountPlanIds.add(mem.Relationship_Map__c);
            memberIdxMapId.put(mem.Id, mem.Relationship_Map__c);
        }
        Map<Id, pq_Influence_And_Support_Matrix__c> matrixesForMap = new Map<Id, pq_Influence_And_Support_Matrix__c>();
        if (!memberIdxMapId.isEmpty()) {
            matrixesForMap = InfluenceSupportMatrixService.getMatrixesForRelationshipMap(
            new Set<Id>(memberIdxMapId.values())
            );
        }
        Map<Id, RM_Chart_Setting__c> settings = new Map<Id, RM_Chart_Setting__c>();
        if (!mapOrAccountPlanIds.isEmpty()) {
            settings = RMChartSettingService.getRelationshipMapSettingForObjects(mapOrAccountPlanIds);
        }

        for (MatrixMember m : result) {
            RM_Chart_Setting__c s = settings.get(m.containerId);
            if (s != null && s.Is_Influence_Support_Global_Scope__c) {
                m.isUsingGlobalInfluence = true;
            }
            pq_Influence_And_Support_Matrix__c matrix = matrixesForMap.get(m.containerId);
            if (matrix != null) {
                m.influenceLabel = String.isBlank(matrix?.Influence_Label__c)
                    ? Label.pqcrush.Influence
                    : matrix?.Influence_Label__c;
                m.supportLabel = String.isBlank(matrix?.Support_Label__c)
                    ? Label.pqcrush.Support
                    : matrix?.Support_Label__c;
            }
        }

        return result;
    }

    @AuraEnabled
    public static List<ReportStructureWrapper> getReportingStructureForContact(Id contactId) {
        List<ReportStructureWrapper> result = new List<ReportStructureWrapper>();

        // Query salesforce Reports To Data for Contact
        Contact thisContact = ContactSelector.newInstance()
            .selectByIdAndSelectFields(new Set<Id>{ contactId }, new Set<String>{ 'ReportsTo.Name' })
            .get(0);

        List<Contact> peopleTheyManage = ContactSelector.newInstance()
            .selectByReportsToId(new Set<Id>{ contactId }, new Set<String>());

        ReportStructureWrapper globalReportsToData = ReportStructureWrapper.convert(thisContact, peopleTheyManage);

        result.add(globalReportsToData);

        // Query Relationship Map Reports To Data
        List<Map_Member_Placeholder_Relationship__c> localReportsToLinks = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectHierarchyLinksByContactId(new Set<String>{ contactId });

        List<ReportStructureWrapper> localReportsToData = ReportStructureWrapper.convert(
            contactId,
            localReportsToLinks
        );
        result.addAll(localReportsToData);

        return result;
    }

    @AuraEnabled
    public static List<MapRelationshipLineContainer> getRelationshipsForContact(Id contactId) {
        List<Contact_Relationship__c> contactRels = ContactRelationshipSelector.newInstance()
            .selectActiveCustomRelsByToOrFrom(new Set<String>{ contactId });
        List<Map_Member_Placeholder_Relationship__c> customLinks = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectActiveCustomRelsByToOrFrom(new Set<String>{ contactId });
        List<MapRelationshipLineContainer> result = MapRelationshipLineContainer.convert(
            contactId,
            contactRels,
            customLinks
        );
        return result;
    }
    // ---------------------------------------------------
}