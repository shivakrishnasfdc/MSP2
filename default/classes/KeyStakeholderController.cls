@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class KeyStakeholderController {
    private static Map<String, String> influenceMap { get; set; }

    private static Map<String, String> supportMap { get; set; }

    @TestVisible
    private static List<Org_Chart_Field__c> orgChartfields {
        get {
            if (orgChartfields != null) {
                return orgChartfields;
            }
            orgChartfields = OrgChartSettingsController.getVisibleOrgChartFields('Key Stakeholder');
            return orgChartfields;
        }
        set;
    }

    @TestVisible
    private static map<String, Set<String>> mapKeyStakeholderAndContactFields {
        get {
            if (mapKeyStakeholderAndContactFields != null) {
                return mapKeyStakeholderAndContactFields;
            }

            Set<String> kfields = new Set<String>();
            Set<String> cfields = new Set<String>();
            for (Org_Chart_Field__c orgChartfield : orgChartfields) {
                if (orgChartfield.ObjectName__c == Key_Stakeholder__c.sObjectType.getDescribe().getName()) {
                    kfields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == Contact.sObjectType.getDescribe().getName()) {
                    cfields.add(orgChartfield.FieldName__c);
                }
            }

            if (UtilityForSObject.isFieldReadable(Contact.sObjectType, 'PhotoUrl')) {
                cfields.add('PhotoUrl');
            }

            cfields.add('ReportsToId');

            mapKeyStakeholderAndContactFields = new Map<String, Set<String>>();
            mapKeyStakeholderAndContactFields.put('contacts', cfields);
            mapKeyStakeholderAndContactFields.put('keystakeholders', kfields);

            return mapKeyStakeholderAndContactFields;
        }
        set;
    }

    @AuraEnabled
    public static GraphData addLeadsAsKeyStakeholders(String graphDataJsonString, Id accountPlanId) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);
        if (accountPlanId == null || gd == null || gd.nodeDataArray == null) {
            return new GraphData();
        }
        Map<String, String> influenceMap = getMapInfluence(accountPlanId);
        Map<String, String> supportMap = getMapSupport(accountPlanId);
        
        if (influenceMap == null || supportMap == null) {
            return new GraphData();
        }
        return MapMemberLeadService.createLeadsForAccountPlan(
            gd,
            accountPlanId,
            influenceMap,
            supportMap
        );
    }

    @AuraEnabled
    public static void deleteKeyStakeholderLeads(List<String> stakeholderIds) {
        if (stakeholderIds == null) {
            return;
        }

        MapMemberLeadService.deleteKeyStakeholderLeads(stakeholderIds);
    }

    @AuraEnabled
    public static String getKeyStakeholderObjectLabel() {
        return SObjectType.Key_Stakeholder__c.getLabel();
    }

    @AuraEnabled
    public static MatrixWrapper getMatrixByAccountPlan(Id accountPlanId) {
        List<InfluenceWrapper> influenceList = getInfluenceByAccountPlan(accountPlanId);
        List<SupportWrapper> supportList = getSupportByAccountPlan(accountPlanId);
        if (influenceList == null) {
            influenceList = new List<InfluenceWrapper>();
        }
        if (supportList == null) {
            supportList = new List<SupportWrapper>();
        }
        pq_Influence_And_Support_Matrix__c matrix = getOneMatrix(accountPlanId);
        if (matrix == null) {
            matrix = new pq_Influence_And_Support_Matrix__c();
        }
        return new MatrixWrapper(matrix, influenceList, supportList);
    }

    @AuraEnabled
    public static List<InfluenceWrapper> getInfluenceByAccountPlan(Id accountPlanId) {
        List<InfluenceWrapper> result = new List<InfluenceWrapper>();
        result.add(new InfluenceWrapper(System.Label.TBD));

        List<pq_Influence__c> influenceValues = getListinfluence(accountPlanId);
        if (influenceValues == null) {
            influenceValues = new List<pq_Influence__c>();
        }
        for (pq_Influence__c infl : influenceValues) {
            result.add(new InfluenceWrapper(infl));
        }
        return result;
    }

    @AuraEnabled
    public static List<SupportWrapper> getSupportByAccountPlan(Id accountPlanId) {
        List<SupportWrapper> result = new List<SupportWrapper>();
        result.add(new SupportWrapper(System.Label.TBD));

        List<pq_Support__c> supportValues = getListSupport(accountPlanId);
        if (supportValues == null) {
            supportValues = new List<pq_Support__c>();
        }
        for (pq_Support__c supp : supportValues) {
            result.add(new SupportWrapper(supp));
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, String> getSupportColors() {
        return GraphDataService.getSupportColors();
    }

    @AuraEnabled
    public static Map<String, ObjectUpdatibility> getUpdatibility() {
        Map<String, ObjectUpdatibility> result = new Map<String, ObjectUpdatibility>();

        result.put(
            'Key_Stakeholder__c',
            new ObjectUpdatibility(
                Key_Stakeholder__c.SObjectType.getDescribe().getName(),
                UtilityForSObject.getFieldUpdatibility(
                    Key_Stakeholder__c.SObjectType,
                    new List<SObjectField>{
                        Key_Stakeholder__c.InfluenceId__c.getDescribe().getSObjectField(),
                        Key_Stakeholder__c.SupportId__c.getDescribe().getSObjectField()
                    }
                )
            )
        );

        result.put(
            'Contact',
            new ObjectUpdatibility(
                Contact.SObjectType.getDescribe().getName(),
                UtilityForSObject.getFieldUpdatibility(
                    Contact.SObjectType,
                    new List<SObjectField>{
                        Contact.FirstName.getDescribe().getSObjectField(),
                        Contact.LastName.getDescribe().getSObjectField(),
                        Contact.Title.getDescribe().getSObjectField(),
                        Contact.Email.getDescribe().getSObjectField(),
                        Contact.Phone.getDescribe().getSObjectField()
                    }
                )
            )
        );

        return result;
    }

    @AuraEnabled
    public static Boolean canDeleteKeyStakeholder() {
        try {
            fflib_SecurityUtils.checkObjectIsDeletable(Key_Stakeholder__c.SObjectType);

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Key_Stakeholder__c getKeyStakeholderByIdORContactId(Id objectId, Id planId) {
        List<Key_Stakeholder__c> keyStakeholders = KeyStakeholderSelector.newInstance()
            .selectByIdOrContactIdAndPlanId(
                new Set<Id>{ objectId },
                planId,
                mapKeyStakeholderAndContactFields.get('keystakeholders'),
                mapKeyStakeholderAndContactFields.get('contacts')
            );

        if (keyStakeholders.isEmpty()) {
            return null;
        }

        return keyStakeholders.get(0);
    }

    @AuraEnabled
    public static Key_Stakeholder__c getKeyStakeholderById(Id keyStakeholderId) {
        List<Key_Stakeholder__c> keyStakeholders = KeyStakeholderSelector.newInstance()
            .selectById(new Set<Id>{ keyStakeholderId });

        if (keyStakeholders.isEmpty()) {
            return null;
        }

        return keyStakeholders.get(0);
    }

    @AuraEnabled
    public static MatrixWrapper getMatrixByMemberId(Id memberId) {
        if (memberId == null) {
            return null;
        }

        List<Key_Stakeholder__c> keyStakeholders = KeyStakeholderSelector.newInstance()
            .selectById(new Set<Id>{ memberId });

        if (keyStakeholders == null || keyStakeholders.isEmpty()) {
            return null;
        }
        Key_Stakeholder__c keyStakeholder = keyStakeholders[0];

        if (keyStakeholder.Account_Plan__c == null) {
            return null;  
        }

        return getMatrixByAccountPlan(keyStakeholder.Account_Plan__c);

    }

    @AuraEnabled
    public static MatrixMember getMatrixMemberById(Id memberId) {
        if (memberId == null) {
            return null;
        }

        List<Key_Stakeholder__c> keyStakeholders = KeyStakeholderSelector.newInstance()
            .selectById(new Set<Id>{ memberId });

        if (keyStakeholders == null || keyStakeholders.isEmpty()) {
            return null;
        }

        Key_Stakeholder__c ks = keyStakeholders[0];

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(ks.Account_Plan__c);

        if (!setting.Is_Influence_Support_Global_Scope__c) {
            return new MatrixMember(ks);
        }

        List<Contact_Extended_Field__c> contactExtFields = ContactExtendedFieldSelector.newInstance()
            .selectByContactId(new Set<Id>{ ks.Contact__c });
        if (contactExtFields.size() == 1) {
            Contact_Extended_Field__c contactExtField = contactExtFields[0];
            String influenceName = (contactExtField.Influence__r != null) ? contactExtField.Influence__r.Name : null;
            String supportName = (contactExtField.Support__r != null) ? contactExtField.Support__r.Name : null;
            return new MatrixMember(ks, influenceName, supportName);
        }

        return new MatrixMember(ks, null, null);
    }

    @AuraEnabled
    public static GraphData getParentNodesForContactIds(List<String> contactIds, Id mapOrAccountPlanId) {
        return GraphDataService.getParentNodesForContactIds(
            contactIds,
            orgChartfields,
            mapKeyStakeholderAndContactFields.get('contacts'),
            mapOrAccountPlanId
        );
    }

    @AuraEnabled
    public static GraphData getContactGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        String accountId,
        Id mapOrAccountPlanId,
        String searchKey
    ) {
        GraphData gd = GraphDataService.getContactGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            accountId,
            orgChartfields,
            mapKeyStakeholderAndContactFields.get('contacts'),
            mapOrAccountPlanId
        );

        if (gd != null) {
            gd.searchKey = searchKey;
        }

        return gd;
    }

    @AuraEnabled
    public static List<MatrixMember> getKeyStakeholdersByAccountPlanId(Id accountPlanId) {
        List<Key_Stakeholder__c> keystakeholders = KeyStakeholderSelector.newInstance()
            .selectByAccountPlanIdForYourContactsAndSelectFields(
                new Set<Id>{ accountPlanId },
                mapKeyStakeholderAndContactFields.get('keystakeholders'),
                mapKeyStakeholderAndContactFields.get('contacts')
            );

        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact_Extended_Field__c> contactExtMap = new Map<Id, Contact_Extended_Field__c>();
        for (Key_Stakeholder__c ks : keystakeholders) {
            contactIds.add(ks.Contact__c);
        }

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(accountPlanId);
        if (setting.Is_Influence_Support_Global_Scope__c) {
            List<Contact_Extended_Field__c> contactExtFields = ContactExtendedFieldSelector.newInstance()
                .selectByContactId(contactIds);
            for (Contact_Extended_Field__c cef : contactExtFields) {
                contactExtMap.put(cef.Contact__c, cef);
            }

            List<MatrixMember> matrixMemberList = new List<MatrixMember>();
            for (Key_Stakeholder__c ks : keystakeholders) {
                Contact_Extended_Field__c contactExtField = contactExtMap.get(ks.Contact__c);
                matrixMemberList.add(
                    new MatrixMember(ks, contactExtField?.Influence__r?.Name, contactExtField?.Support__r?.Name)
                );
            }

            return matrixMemberList;
        }

        List<MatrixMember> resultForNonGlobal = new List<MatrixMember>();
        for (Key_Stakeholder__c ks : keystakeholders) {
            resultForNonGlobal.add(new MatrixMember(ks));
        }

        return resultForNonGlobal;
    }

    @AuraEnabled
    public static MatrixMember upsertKeyStakeholder(Id stakeholderId, String influence, String support) {
        List<pq_Influence__c> influenceList = InfluenceSelector.newInstance()
            .selectByName(new Set<String>{ influence });
        List<pq_Support__c> supportList = SupportSelector.newInstance().selectByName(new Set<String>{ support });

        Id influenceId = null;
        Id supportId = null;

        String influenceName = '';
        String supportName = '';

        if (influenceList.size() > 0) {
            influenceId = influenceList[0].Id;
            influenceName = influenceList[0].Name;
        }
        if (supportList.size() > 0) {
            supportId = supportList[0].Id;
            supportName = supportList[0].Name;
        }

        Key_Stakeholder__c keyStakeholder = getKeyStakeholderById(stakeholderId);

        // GET SETTING, CHECK TO SEE IF LOCAL INFLUENCE SUPPORT OR GLOBAL
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(
            keyStakeholder.Account_Plan__c
        );

        if (setting.Is_Influence_Support_Global_Scope__c) {
            ContactExtendedFieldService.updateInfluenceSupport(keyStakeholder.Contact__c, influenceId, supportId);
            return new MatrixMember(keyStakeholder, influenceName, supportName);
        } else {
            fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Key_Stakeholder__c.SObjectType }
            );

            KeyStakeholders keyStakeholderRecords = KeyStakeholders.newInstance(
                new List<Key_Stakeholder__c>{ keyStakeholder }
            );

            keyStakeholderRecords.updateField(Schema.Key_Stakeholder__c.InfluenceId__c, influenceId, unitOfWork);
            keyStakeholderRecords.updateField(Schema.Key_Stakeholder__c.SupportId__c, supportId, unitOfWork);

            unitOfWork.commitWork();

            Key_Stakeholder__c result = getKeyStakeholderById(stakeholderId);

            return new MatrixMember(result);
        }
    }

    @AuraEnabled
    public static GraphData addContactAsKeyStakeholders(Id accountPlanId, String graphDataJsonString) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);

        return gd;

        // Code path to be deprecated

        // if (accountPlanId == null || gd == null || gd.nodeDataArray == null) {
        //     return new GraphData();
        // }

        // Set<Id> contactIdSet = new Set<Id>();
        // for (GraphNodeData node : gd.nodeDataArray) {
        //     contactIdSet.add(node.key);
        // }

        // List<Key_Stakeholder__c> keyStakeHolders = KeyStakeholderService.addContactAsKeyStakeholder(
        //     accountPlanId,
        //     contactIdSet
        // );

        // List<StakeholderWrapper> kshwList = new List<StakeholderWrapper>();
        // for (Key_Stakeholder__c ks : keyStakeHolders) {
        //     kshwList.add(new StakeholderWrapper(ks));
        // }

        // RMNodeCoordinateService.updateNodeCoordinates(accountPlanId, gd.nodeDataArray);

        // RM_Chart_Setting__C setting = RMChartSettingService.getRelationshipMapSettingForObject(accountPlanId);
        // setting.Show_Parents__c = false;
        // setting.Show_Empty_Fields__c = true;

        // return GraphDataService.generateGraphData(
        //     kshwList,
        //     setting,
        //     getMapInfluence(accountPlanId),
        //     getMapSupport(accountPlanId),
        //     mapKeyStakeholderAndContactFields.get('contacts'),
        //     orgChartfields,
        //     accountPlanId
        // );
    }

    @AuraEnabled
    public static void deleteKeyStakeholders(List<Id> stakeholderIds) {
        if (stakeholderIds == null) {
            return;
        }

        List<Key_Stakeholder__c> ksList = new List<Key_Stakeholder__c>();
        for (Id ksId : stakeholderIds) {
            if (ksId == null) {
                continue;
            }
            ksList.add(new Key_Stakeholder__c(Id = ksId));
        }
        if (ksList.size() == 0) {
            return;
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(ksList);
        uow.commitWork();
    }

    @AuraEnabled
    public static GraphData getGraphDataForYourContactsByAccountPlanId(Id accountPlanId) {
        // System.debug('====getGraphDataForYourContactsByAccountPlanId===')
        // This method should be not be used anymore!
        // Find Leads that have been converted to contacts & create keystakeholders
        MapMemberLeadService.convertLeadsToKeyStakeholders(accountPlanId);

        List<Key_Stakeholder__c> stakeholders = KeyStakeholderSelector.newInstance()
            .selectByAccountPlanIdForYourContactsAndSelectFields(
                new Set<Id>{ accountPlanId },
                mapKeyStakeholderAndContactFields.get('keystakeholders'),
                mapKeyStakeholderAndContactFields.get('contacts')
            );
        Set<String> contactIdSet = new Set<String>();
        List<StakeholderWrapper> kshwList = new List<StakeholderWrapper>();
        for (Key_Stakeholder__c ks : stakeholders) {
            contactIdSet.add(ks.Contact__c);
            kshwList.add(new StakeholderWrapper(ks));
        }

        RM_Chart_Setting__C setting = RMChartSettingService.getRelationshipMapSettingForObject(accountPlanId);

        Map<String, String> infl = getMapInfluence(accountPlanId);
        Map<String, String> supp = getMapSupport(accountPlanId);
        System.debug('====called from KeystakeholderController getGraphDataForYourContactsByAccountPlanId===');
        GraphData gd = GraphDataService.generateGraphData(
            kshwList,
            setting,
            infl,
            supp,
            mapKeyStakeholderAndContactFields.get('contacts'),
            orgChartfields,
            accountPlanId
        );

        // Add in Placeholder nodes
        gd = GraphDataService.getAndInjectPlaceholderNodes(gd, accountPlanId);

        // Add in Map Member User nodes
        gd = MapMemberUserService.getAndInjectMapMemberUserNodes(gd, accountPlanId);

        // Add in Leads
        gd = MapMemberLeadService.getAndInjectKeyStakeholderLeadNodes(gd, accountPlanId, infl, supp);

        // Add in registered coordinates for all nodes
        gd = GraphDataService.getAndInjectNodeCoordinates(gd, accountPlanId);

        // Add in group links
        gd = GraphDataService.getAndInjectCustomLinks(gd, accountPlanId);

        // Add in badges
        gd = RMSvgService.injectBadges(accountPlanId, gd, setting);

        // Add in local hierarchy links for contacts
        if (!setting.Is_Reports_To_Global_Scope__c) {
            gd = GraphDataService.getAndInjectLocalHierarchyLinksForContacts(accountPlanId, gd, contactIdSet);
        }

        return gd;
    }

    @AuraEnabled
    public static CrushSettings getOrgSettings() {
        return new CrushSettings(SettingService.getOrgSettingsAndCreateIfNeeded());
    }

    @AuraEnabled
    public static CrushSettings upsertSettings(String settings) {
        CRUSH_Settings_Obj__c settingsObject = ((CrushSettings) JSON.deserialize(settings, CrushSettings.class))
            .toSObject();
        CRUSH_Settings_Obj__c updatedSettings = SettingService.upsertSettings(settingsObject);
        return new CrushSettings(updatedSettings);
    }

    private static Map<String, String> getMapInfluence(Id accountPlanId) {
        if (influenceMap != null) {
            return influenceMap;
        }

        pq_Influence_And_Support_Matrix__c matrix = getOneMatrix(accountPlanId);
        List<pq_Influence__c> influences = new List<pq_Influence__c>();
        if (matrix != null) {
            influences = InfluenceSupportMatrixService.getInfluencesByMatrixes(new Set<Id>{ matrix?.Id });
        }

        Map<String, String> inflMap = new Map<String, String>();
        for (pq_Influence__c infl : influences) {
            inflMap.put(infl.Name, infl.Label__c);
        }

        influenceMap = inflMap;

        return influenceMap;
    }

    private static Map<String, String> getMapSupport(Id accountPlanId) {
        if (supportMap != null) {
            return supportMap;
        }

        pq_Influence_And_Support_Matrix__c matrix = getOneMatrix(accountPlanId);
        List<pq_Support__c> supports = new List<pq_Support__c>();
        if (matrix != null) {
            supports = InfluenceSupportMatrixService.getSupportByMatrixes(new Set<Id>{ matrix.Id });
        }

        Map<String, String> sMap = new Map<String, String>();
        for (pq_Support__c supp : supports) {
            sMap.put(supp.Name, supp.Label__c);
        }

        supportMap = sMap;

        return supportMap;
    }

    private static List<pq_Influence__c> getListInfluence(Id accountPlanId) {
        pq_Influence_And_Support_Matrix__c matrix = getOneMatrix(accountPlanId);
        if (matrix != null) {
            return InfluenceSupportMatrixService.getInfluencesByMatrixes(new Set<Id>{ matrix.Id });
        }

        return new List<pq_Influence__c>();
    }

    private static List<pq_Support__c> getListSupport(Id accountPlanId) {
        pq_Influence_And_Support_Matrix__c matrix = getOneMatrix(accountPlanId);
        if (matrix != null) {
            return InfluenceSupportMatrixService.getSupportByMatrixes(new Set<Id>{ matrix.Id });
        }

        return new List<pq_Support__c>();
    }

    private static pq_Influence_And_Support_Matrix__c getOneMatrix(Id accountPlanId) {
        Map<Id, pq_Influence_And_Support_Matrix__c> matrixes = InfluenceSupportMatrixService.getMatrixesForAccountPlan(
            new Set<Id>{ accountPlanId }
        );
        return matrixes.get(accountPlanId);
    }
}