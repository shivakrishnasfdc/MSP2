@SuppressWarnings('PMD.ExcessivePublicCount,PMD.NcssMethodCount,PMD.CyclomaticComplexity,PMD.NcssTypeCount,PMD.ExcessiveClassLength')
public with sharing class RelationshipMapMemberController {
    @TestVisible
    private static Map<String, String> influenceMap { get; set; }

    @TestVisible
    private static Map<String, String> supportMap { get; set; }

    private static String mapType { get; set; }

    @TestVisible
    public static List<Org_Chart_Field__c> orgChartfields {
        get {
            if (orgChartfields != null) {
                return orgChartfields;
            }
            // orgChartfields = OrgChartSettingsController.getVisibleOrgChartFields('Relationship Map');
            orgChartfields = OrgChartSettingsController.getVisibleOrgChartFields(mapType);
            return orgChartfields;
        }
        set;
    }

    //account hierarchy:
    @TestVisible
    private static List<Org_Chart_Field__c> accountOrgChartfields {
        get {
            if (accountOrgChartfields != null) {
                return accountOrgChartfields;
            }
            accountOrgChartfields = OrgChartSettingsController.getVisibleOrgChartFieldsByObjectNameAndMapType(mapType,new Set<String>{'Account'});
            return accountOrgChartfields;
        }
        set;
    }
    
    @TestVisible
    public static map<String, Set<String>> mapMembersAndContactFields {
        get {
            if (mapMembersAndContactFields != null) {
                return mapMembersAndContactFields;
            }

            Set<String> keyStakeholderFields = new Set<String>();
            Set<String> contactFields = new Set<String>();
            Set<String> userFields = new Set<String>();
            Set<String> accountFields = new Set<String>();
            for (Org_Chart_Field__c orgChartfield : orgChartfields) {
                if (orgChartfield.ObjectName__c == Relationship_Map_Member__c.sObjectType.getDescribe().getName()) {
                    keyStakeholderFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == Contact.sObjectType.getDescribe().getName()) {
                    contactFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == User.sObjectType.getDescribe().getName()) {
                    userFields.add(orgChartfield.FieldName__c);
                }
                 else if (orgChartfield.ObjectName__c == Account.sObjectType.getDescribe().getName()) {
                    accountFields.add(orgChartfield.FieldName__c);
                }
            }

            if (UtilityForSObject.isFieldReadable(Contact.sObjectType, 'PhotoUrl')) {
                contactFields.add('PhotoUrl');
            }

            if (UtilityForSObject.isFieldReadable(Contact.sObjectType, 'ReportsToId')) {
                contactFields.add('ReportsToId');
            }

            if (UtilityForSObject.isFieldReadable(User.sObjectType, 'ManagerId')) {
                userFields.add('ManagerId');
            }
            mapMembersAndContactFields = new Map<String, Set<String>>();
            mapMembersAndContactFields.put('contacts', contactFields);
            mapMembersAndContactFields.put('members', keyStakeholderFields);
            mapMembersAndContactFields.put('users', userFields);
            mapMembersAndContactFields.put('accounts', accountFields);

            return mapMembersAndContactFields;
        }
        set;
    }

    //account hierarchy:
    @TestVisible
    private static map<String, Set<String>> mapMembersAndAccountFields {
        get {
            if (mapMembersAndAccountFields != null) {
                return mapMembersAndAccountFields;
            }

            Set<String> keyStakeholderFields = new Set<String>();
            Set<String> contactFields = new Set<String>();
            Set<String> userFields = new Set<String>();
            Set<String> accountFields = new Set<String>();
            for (Org_Chart_Field__c orgChartfield : accountOrgChartfields) {
                if (orgChartfield.ObjectName__c == Relationship_Map_Member__c.sObjectType.getDescribe().getName()) {
                    keyStakeholderFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == Contact.sObjectType.getDescribe().getName()) {
                    contactFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == User.sObjectType.getDescribe().getName()) {
                    userFields.add(orgChartfield.FieldName__c);
                }
                 else if (orgChartfield.ObjectName__c == Account.sObjectType.getDescribe().getName()) {
                    accountFields.add(orgChartfield.FieldName__c);
                }
            }

            if (UtilityForSObject.isFieldReadable(Contact.sObjectType, 'PhotoUrl')) {
                contactFields.add('PhotoUrl');
            }

            if (UtilityForSObject.isFieldReadable(Contact.sObjectType, 'ReportsToId')) {
                contactFields.add('ReportsToId');
            }

            if (UtilityForSObject.isFieldReadable(User.sObjectType, 'ManagerId')) {
                userFields.add('ManagerId');
            }
            mapMembersAndAccountFields = new Map<String, Set<String>>();
            mapMembersAndAccountFields.put('contacts', contactFields);
            mapMembersAndAccountFields.put('members', keyStakeholderFields);
            mapMembersAndAccountFields.put('users', userFields);
            mapMembersAndAccountFields.put('accounts', accountFields);

            return mapMembersAndAccountFields;
        }
        set;
    }

    //Added MSP
    @AuraEnabled
    public static List<Relationship_Map__c> getMapMembersByAccountPlan(Id accountPlanId, String queryFileds) {
        //List<Relationship_Map__c> mapMembersList = 
        //String queryFileds = pqcrush__Contact__r.Name,pqcrush__InfluenceId__r.Name, pqcrush__SupportId__r.Name, pqcrush__Contact__r.ReportsTo.Name;
        String queryString = 'SELECT Id, '+ queryFileds +' from pqcrush__Relationship_Map_Member__c where pqcrush__Relationship_Map__r.pqcrush__pq_AccountPlanId__c =:accountPlanId';
        return Database.query(queryString);
    }

    //Added MSP
    @AuraEnabled
    public static List<Map<String, Object>> getDatatableColumns(String fieldsString, String objectString){
    String queryString = 'SELECT '+fieldsString+ ' from '+objectString;
    SObject queryObject = Schema.getGlobalDescribe().get(objectString).newSObject();
    String soqlFields = queryString.subString(
        queryString.indexOfIgnoreCase('select') + 7,
        queryString.indexOfIgnoreCase(' from ')
    )
        .trim();
    List<String> soqlColumns = soqlFields.split('[,]{1}[\\s]*');
    system.debug('SOQL'+soqlFields);
    system.debug('soqlColumns'+soqlColumns);
    system.debug('queryObject'+queryObject);
    List<Map<String, Object>> tableColumns = new List<Map<String, Object>>();
    Map<String, Schema.SObjectField> fieldMap = queryObject.getSObjectType().getDescribe().fields.getMap();
    
    for (String fieldName : soqlColumns) {
        Schema.SObjectType currentSObjectType = queryObject.getSObjectType();
        Schema.DescribeFieldResult field;
        Map<String, Object> fieldColumn = new Map<String, Object>();
        system.debug('fieldName'+fieldName);
        system.debug('currentSObjectType'+currentSObjectType);          
        if (fieldName.contains('.')) {
            String parentReference = fieldName.contains('__r')
                ? fieldName.substringBeforeLast('__r.') + '__c' // custom objects
                : fieldName.substringBeforeLast('.') + 'Id'; // standard objects typical schema
            system.debug('parentReference'+parentReference);
            
            Schema.SObjectType referenceTo = fieldMap.get(parentReference).getDescribe().getReferenceTo().get(0);
            //currentSObjectType = referenceTo;
            if(fieldName.contains('.'))
                field = currentSObjectType.getDescribe().fields.getMap().get(parentReference).getDescribe();
            //field = currentSObjectType.getDescribe().fields.getMap().get(pqcrush__Contact__c.ReportsTo).getDescribe();
            system.debug('field'+field);
        } else {
            field = fieldMap.get(fieldName).getDescribe();
        }
        String flatFieldName ;
        String fieldNameUrl;
        String type;
        if(fieldName.contains('.')){
            flatFieldName=fieldName.replace('.', '_'); // parent fields handled by clientside flattener
            fieldColumn.put('type', 'url');
            type='url';
            fieldNameUrl = flatFieldName+'url';

            fieldColumn.put('label', field.getLabel());
        //fieldColumn.put('type', DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.get(field.getType()));
        fieldColumn.put('fieldName', fieldNameUrl);
        fieldColumn.put('type', type);
        Map<String, Object> typeAttributes = new Map<String, Object>();
        typeAttributes.put('label', new Map<String, Object>{ 'fieldName' => flatFieldName });
        typeAttributes.put('target', '_blank');
        fieldColumn.put('typeAttributes', typeAttributes);
        fieldColumn.put('sortable', true);
        }
        else{
            flatFieldName = fieldName;
            type= 'text' ;
            fieldNameUrl = flatFieldName;
            fieldColumn.put('label', field.getLabel());
        //fieldColumn.put('type', DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.get(field.getType()));
        fieldColumn.put('fieldName', fieldNameUrl);
        fieldColumn.put('type', type);
        /*Map<String, Object> typeAttributes = new Map<String, Object>();
        typeAttributes.put('label', new Map<String, Object>{ 'fieldName' => flatFieldName });
        typeAttributes.put('target', '_blank');
        fieldColumn.put('typeAttributes', typeAttributes);*/
        fieldColumn.put('sortable', true);
        }
        if(fieldName.contains('ReportsTo')){
                fieldColumn.put('label', 'Reports To');
            }
            else{
                fieldColumn.put('label', field.getLabel());
            }
        //fieldColumn.put('type', DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.get(field.getType()));
        fieldColumn.put('fieldName', fieldNameUrl);
        fieldColumn.put('type', type);
        Map<String, Object> typeAttributes = new Map<String, Object>();
        typeAttributes.put('label', new Map<String, Object>{ 'fieldName' => flatFieldName });
        typeAttributes.put('target', '_blank');
        fieldColumn.put('typeAttributes', typeAttributes);
        fieldColumn.put('sortable', true);
        
        system.debug('fieldColumn'+fieldColumn);
        tableColumns.add(fieldColumn);
        
    }
    system.debug('tableColumns :::'+tableColumns); 
    return tableColumns;
}

    @AuraEnabled(cacheable=true)
    public static Boolean isAccountPlanMap(Id mapId) {
        if (mapId == null) {
            return null;
        }
        return RelationshipMapService.hasAccountPlanSetting(mapId);
    }

    @AuraEnabled(cacheable=true)
    public static Id getParentIdForRelationshipMapId(Id mapId) {
        if (mapId == null || mapId.getSobjectType() != Relationship_Map__c.getSObjectType()) {
            return null;
        }
        return RelationshipMapService.getParentIdForRelationshipMapId(mapId);
    }

    @AuraEnabled
    public static MatrixWrapper getMatrixByMemberId(Id memberId) {
        if (memberId == null) {
            return null;
        }
        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance()
            .selectById(new Set<Id>{ memberId });

        if (members.isEmpty()) {
            return null;
        }
        Relationship_Map_Member__c mapMember = (Relationship_Map_Member__c) UtilityForList.first(members);
        return getMatrixByRelationshipMap(mapMember.Relationship_Map__c);
    }

    @AuraEnabled
    public static MatrixWrapper getMatrixByAccountPlan(Id accountPlanId) {
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance()
            .selectByAccountPlanIds(new Set<Id>{ accountPlanId });
        if (maps.size() <= 0) {
            return null;
        }

        Id mapId = maps[0].Id;
        return getMatrixByRelationshipMap(mapId);
    }

    @AuraEnabled
    public static MatrixWrapper getMatrixByRelationshipMap(Id mapId) {
        Map<Id, pq_Influence_And_Support_Matrix__c> matrixes = InfluenceSupportMatrixService.getMatrixesForRelationshipMap(
            new Set<Id>{ mapId }
        );
        pq_Influence_And_Support_Matrix__c matrix = matrixes.get(mapId);
        IF(matrix != NULL){
        List<pq_Influence__c> infList = InfluenceSupportMatrixService.getInfluencesByMatrixes(new Set<Id>{ matrix.Id });
        List<InfluenceWrapper> influenceList = wrapInfluences(infList);

        List<pq_Support__c> suppList = InfluenceSupportMatrixService.getSupportByMatrixes(new Set<Id>{ matrix.Id });
        List<SupportWrapper> supportList = wrapSupport(suppList);
        return new MatrixWrapper(matrix, influenceList, supportList);
        }
        else{
        return new MatrixWrapper(null, null, null);
    }
    }

    private static List<InfluenceWrapper> wrapInfluences(List<pq_Influence__c> influenceValues) {
        List<InfluenceWrapper> result = new List<InfluenceWrapper>();
        result.add(new InfluenceWrapper(System.Label.TBD));

        for (pq_Influence__c infl : influenceValues) {
            result.add(new InfluenceWrapper(infl));
        }
        return result;
    }

    private static List<SupportWrapper> wrapSupport(List<pq_Support__c> supportValues) {
        List<SupportWrapper> result = new List<SupportWrapper>();
        result.add(new SupportWrapper(System.Label.TBD));

        for (pq_Support__c supp : supportValues) {
            result.add(new SupportWrapper(supp));
        }
        return result;
    }

    @AuraEnabled
    public static MatrixWrapper getAccountMatrixByRelationshipMap(Id mapId) {
        Map<Id, pq_Influence_And_Support_Matrix__c> matrixes = InfluenceSupportMatrixService.getMatrixesForRelationshipMap(
            new Set<Id>{ mapId }
        );
        pq_Influence_And_Support_Matrix__c matrix = matrixes.get(mapId);
        IF(matrix != NULL){
        List<pq_Influence__c> infList = InfluenceSupportMatrixService.getInfluencesByMatrixes(new Set<Id>{ matrix.Id });
        List<InfluenceWrapper> influenceList = wrapAccountInfluences(infList);

        List<pq_Support__c> suppList = InfluenceSupportMatrixService.getSupportByMatrixes(new Set<Id>{ matrix.Id });
        List<SupportWrapper> supportList = wrapAccountSupport(suppList);
        return new MatrixWrapper(matrix, influenceList, supportList);
        }
        else{
        return new MatrixWrapper(null, null, null);
    }
    }

    private static List<InfluenceWrapper> wrapAccountInfluences(List<pq_Influence__c> influenceValues) {
        List<InfluenceWrapper> result = new List<InfluenceWrapper>();
        result.add(new InfluenceWrapper(''));

        for (pq_Influence__c infl : influenceValues) {
            result.add(new InfluenceWrapper(infl));
        }
        return result;
    }

    private static List<SupportWrapper> wrapAccountSupport(List<pq_Support__c> supportValues) {
        List<SupportWrapper> result = new List<SupportWrapper>();
        result.add(new SupportWrapper(''));

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
    public static MatrixMember getMatrixMemberByIdORContactId(Id objectId, Id mapId) {
        Relationship_Map_Member__c mapMember = getMapMemberByIdORContactId(objectId, mapId);
        return ConvertToMatrixMember(new List<Relationship_Map_Member__c>{ mapMember });
    }

    @AuraEnabled
    public static Relationship_Map_Member__c getMapMemberByIdORContactId(Id objectId, Id mapId) {
        if (objectId == null) {
            return null;
        }
        setMapType(mapId);
        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance()
            .selectByIdOrContactIdAndMapId(
                new Set<Id>{ objectId },
                mapId,
                mapMembersAndContactFields.get('members'),
                mapMembersAndContactFields.get('contacts')
            );
        return (Relationship_Map_Member__c) UtilityForList.first(members);
    }

    @AuraEnabled
    public static Relationship_Map_Member__c getMapMemberById(Id memberId) {
        if (memberId == null) {
            return null;
        }
        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance()
            .selectById(new Set<Id>{ memberId });
        return (Relationship_Map_Member__c) UtilityForList.first(members);
    }

    @AuraEnabled
    public static MatrixMember getMatrixMemberById(Id memberId) {
        if (memberId == null) {
            return null;
        }
        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance()
            .selectById(new Set<Id>{ memberId });
        return ConvertToMatrixMember(members);
    }

    private static MatrixMember convertToMatrixMember(List<Relationship_Map_Member__c> mapMembers) {
        return RelationshipMapMemberHelper.convertToMatrixMember(mapMembers);
    }

    @AuraEnabled
    public static List<MatrixMember> getMapMembersByMapId(Id mapId) {
        return RelationshipMapMemberHelper.getMapMembersByMapId(mapId);
    }

    @AuraEnabled
    public static MatrixMember upsertMapMember(Id memberId, String influence, String support) {
        return RelationshipMapMemberHelper.upsertMapMember(memberId, influence, support);
    }

    @AuraEnabled
    public static GraphData getParentNodesForContactIds(List<String> contactIds, Id mapOrAccountPlanId) {
        setMapType(mapOrAccountPlanId);
        return GraphDataService.getParentNodesForContactIds(
            contactIds,
            orgChartfields,
            mapMembersAndContactFields.get('contacts'),
            mapOrAccountPlanId
        );
    }

    public static void setMapType(Id mapOrAccountPlanId) {
        
        if (!String.isBlank(mapType)) {
            return;
        }
        
        if (mapOrAccountPlanId == null) {
            mapType = 'Relationship Map';
            return;
        }
        if (mapOrAccountPlanId.getSobjectType() == Account.getSObjectType()) {
            mapType = 'Account Map';
            return;
        }
        
        if (mapOrAccountPlanId.getSobjectType() == Relationship_Map__c.getSObjectType()) {
            List<Relationship_Map__c> rms = RelationshipMapSelector.newInstance()
            .selectByIds(new Set<Id>{ mapOrAccountPlanId });
            Relationship_Map__c relationshipMap = new Relationship_Map__c();
            if (rms != null && !rms.isEmpty()) {
            relationshipMap = rms[0];  

            if (relationshipMap.pq_AccountPlanId__c != null) {
                mapType = 'Key Stakeholder';
                return;
            }

            if (relationshipMap.pq_Opportunity_Plan__c != null) {
                mapType = 'Opportunity Plan';
                return;
            }
            }
        mapType = 'Relationship Map';
        }
    }

    @AuraEnabled
    public static GraphData getContactGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        String accountId,
        Id mapOrAccountPlanId,
        String searchKey
    ) {
        setMapType(mapOrAccountPlanId);
        GraphData gd = GraphDataService.getContactGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            accountId,
            orgChartfields,
            mapMembersAndContactFields.get('contacts'),
            mapOrAccountPlanId
        );
        if (gd != null) {
            gd.searchKey = searchKey;
        }
        return gd;
    }

    
//account hierarchy : responsible for populating the Account nodes data in the side panel , when we click users button(the side panel appears up)
    @AuraEnabled
    public static GraphData getAccountGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        String accountId,
        Id mapOrAccountPlanId,
        String searchKey
    ) {
        setMapType(mapOrAccountPlanId);
        GraphData gd = GraphDataService.getAccountGraphDataForSearchTerm(
            searchTerm,
            excludeIds,
            accountId,
            accountOrgChartfields,
            mapMembersAndAccountFields.get('accounts'),
            mapOrAccountPlanId
        );
        if (gd != null) {
            gd.searchKey = searchKey;
        }
        return gd;
    }

    // TODO - RENAME AND MOVE THIS TO GRAPHDATACONTROLLER
    @AuraEnabled
    public static GraphData getUserGraphDataForHierarchyId(Id hierarchyId) {
        return RelationshipMapMemberHelper.getUserGraphDataForHierarchyId(hierarchyId);
    }

    // Account Data
    @AuraEnabled
    public static GraphData getAccountGraphData(Id hierarchyId) {
        if (hierarchyId == null || hierarchyId.getSobjectType() != Account.sObjectType) {
            return new GraphData();
        }
        /*else{
            pqcrush__Account_Relationship_Map__c arm = [select Id,pqcrush__Account_Plan_Id__r.pqcrush__Account__c from pqcrush__Account_Relationship_Map__c where Id = :hierarchyId LIMIT 1];
            List<Id> accIds = getHierarchy(arm.pqcrush__Account_Plan_Id__r.pqcrush__Account__c);
            createARMM(accIds, hierarchyId);
        }*/

        // Get map instance
        //List<Account_Relationship_Map__c> maps = AccountRelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ hierarchyId });
        List<Account> maps = AccountSelector.newInstance().selectByIds(new Set<Id>{ hierarchyId });
        if (maps.size() == 0) {
            throw Application.createAuraHandledException(
                String.format(System.label.error_insufficient_access, new List<String>{ String.valueOf(hierarchyId) })
            );
        }
        setMapType(hierarchyId);

        // Convert any Leads (that were converted to contacts) to Map Members
       // MapMemberLeadService.convertLeadsToMapMembers(hierarchyId);

        // GET ALL KeyStakeholders/MapMembers
        List<Account> members = AccountSelector.newInstance()
            .selectByAccIdsAndSelectFieldsWithYourAccounts(hierarchyId);

        // Wrap MapMembers into helper
        Set<String> accountIdSet = new Set<String>();
        List<AccountWrapper> wrapperList = new List<AccountWrapper>();
        for (Account member : members) {
            accountIdSet.add(member.Id);
            AccountWrapper wrapper = new AccountWrapper(member);
            wrapperList.add(wrapper);
        }

        // Get Map Settings
        RM_Chart_Setting__C mapSetting = RMChartSettingService.getRelationshipMapSettingForObject(hierarchyId);
        List<pq_Influence_And_Support_Matrix__c> matrixes = getMatrixes(new Set<Id>{ hierarchyId });

        Map<String, String> infl = getMapInfluence(matrixes);
        Map<String, String> supp = getMapSupport(matrixes);

        // Get the KeyStakeholder nodes
        GraphData gd = GraphDataService.generateAccountGraphData(
            wrapperList,
            mapSetting,
            infl,
            supp,
            mapMembersAndAccountFields.get('accounts'),
            accountOrgChartfields,
            hierarchyId
        );

        // return GraphDataService.generateAccountGraphData(
        //     wrapperList,
        //     setting,
        //     getMapInfluence(matrixes),
        //     getMapSupport(matrixes),
        //     mapMembersAndAccountFields.get('accounts'),
        //     orgChartfields,
        //     relationshipMapId
        // );

        // Add in Placeholder nodes
        // gd = GraphDataService.getAndInjectPlaceholderNodes(gd, hierarchyId);

        // // Add in Map Member User nodes
        // gd = MapMemberUserService.getAndInjectMapMemberUserNodes(gd, hierarchyId);

        // // Add in Map Member Lead nodes
        // gd = MapMemberLeadService.getAndInjectMapMemberLeadNodes(gd, hierarchyId, infl, supp);

        // Add in registered coordinates for ALL nodes
        gd = GraphDataService.getAndInjectNodeCoordinates(gd, hierarchyId);

        // // Add in group links
        // gd = GraphDataService.getAndInjectCustomLinks(gd, hierarchyId);

        // // Add in badges
        // gd = RMSvgService.injectBadges(hierarchyId, gd, mapSetting);

        return gd;
    }


//account hierarchy : 
    @AuraEnabled
    public static GraphData getAccountGraphDataForHierarchyId(Id hierarchyId) {
        if (hierarchyId == null || hierarchyId.getSobjectType() != pqcrush__Account_Relationship_Map__c.sObjectType) {
            return new GraphData();
        }
        /*else{
            pqcrush__Account_Relationship_Map__c arm = [select Id,pqcrush__Account_Plan_Id__r.pqcrush__Account__c from pqcrush__Account_Relationship_Map__c where Id = :hierarchyId LIMIT 1];
            List<Id> accIds = getHierarchy(arm.pqcrush__Account_Plan_Id__r.pqcrush__Account__c);
            createARMM(accIds, hierarchyId);
        }*/

        // Get map instance
        List<Account_Relationship_Map__c> maps = AccountRelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ hierarchyId });
        if (maps.size() == 0) {
            throw Application.createAuraHandledException(
                String.format(System.label.error_insufficient_access, new List<String>{ String.valueOf(hierarchyId) })
            );
        }
        setMapType(hierarchyId);

        // Convert any Leads (that were converted to contacts) to Map Members
       // MapMemberLeadService.convertLeadsToMapMembers(hierarchyId);

        // GET ALL KeyStakeholders/MapMembers
        List<Account_Map_Member__c> members = AccountRelationshipMapMemberSelector.newInstance()
            .selectByRelationshipMapIdsAndSelectFieldsWithYourAccounts(
                new Set<Id>{ hierarchyId },
                mapMembersAndContactFields.get('members'),
                mapMembersAndAccountFields.get('accounts')
            );

        // Wrap MapMembers into helper
        Set<String> accountIdSet = new Set<String>();
        List<AccountMemberWrapper> wrapperList = new List<AccountMemberWrapper>();
        for (Account_Map_Member__c member : members) {
            accountIdSet.add(member.Account__c);
            AccountMemberWrapper wrapper = new AccountMemberWrapper(member);
            wrapperList.add(wrapper);
        }

        // Get Map Settings
        RM_Chart_Setting__C mapSetting = RMChartSettingService.getRelationshipMapSettingForObject(hierarchyId);
        List<pq_Influence_And_Support_Matrix__c> matrixes = getMatrixes(new Set<Id>{ hierarchyId });

        Map<String, String> infl = getMapInfluence(matrixes);
        Map<String, String> supp = getMapSupport(matrixes);

        // Get the KeyStakeholder nodes
        GraphData gd = GraphDataService.generateAccountGraphData(
            wrapperList,
            mapSetting,
            infl,
            supp,
            mapMembersAndAccountFields.get('accounts'),
            accountOrgChartfields,
            hierarchyId
        );

        // return GraphDataService.generateAccountGraphData(
        //     wrapperList,
        //     setting,
        //     getMapInfluence(matrixes),
        //     getMapSupport(matrixes),
        //     mapMembersAndAccountFields.get('accounts'),
        //     orgChartfields,
        //     relationshipMapId
        // );

        // Add in Placeholder nodes
        // gd = GraphDataService.getAndInjectPlaceholderNodes(gd, hierarchyId);

        // // Add in Map Member User nodes
        // gd = MapMemberUserService.getAndInjectMapMemberUserNodes(gd, hierarchyId);

        // // Add in Map Member Lead nodes
        // gd = MapMemberLeadService.getAndInjectMapMemberLeadNodes(gd, hierarchyId, infl, supp);

        // Add in registered coordinates for ALL nodes
        gd = GraphDataService.getAndInjectNodeCoordinates(gd, hierarchyId);

        // // Add in group links
        // gd = GraphDataService.getAndInjectCustomLinks(gd, hierarchyId);

        // // Add in badges
        // gd = RMSvgService.injectBadges(hierarchyId, gd, mapSetting);

        // Add in local hierarchy links for contacts
        if (!mapSetting.Is_Reports_To_Global_Scope__c) {
            gd = GraphDataService.getAndInjectLocalHierarchyLinksForContacts(hierarchyId, gd, accountIdSet);
        }
        return gd;
    }

    public static void createARMM(List<Id> accIds, Id accRM){
        List<pqcrush__Account_Map_Member__c> aRMMList = [select Id,pqcrush__Account_Relationship_Map__c,pqcrush__Account__c from pqcrush__Account_Map_Member__c where pqcrush__Account_Relationship_Map__c =:accRM WITH SECURITY_ENFORCED];
        Set<Id> existingAccIds = new Set<Id>();
        for(pqcrush__Account_Map_Member__c amm : aRMMList){
            existingAccIds.add(amm.pqcrush__Account__c);
        }
        List<pqcrush__Account_Map_Member__c> newaRMMList = new List<pqcrush__Account_Map_Member__c>();
        for(Id aId : accIds){
            if(existingAccIds.size()==0 || !existingAccIds.contains(aId)){
                pqcrush__Account_Map_Member__c newrmm = new pqcrush__Account_Map_Member__c();
                newrmm.pqcrush__Account__c = aId;
                newrmm.pqcrush__Account_Relationship_Map__c = accRM;
                newaRMMList.add(newrmm);
            }
        }
        if(newaRMMList.size() > 0){
            Database.Insert(newaRMMList, false, Accesslevel.USER_MODE);
        }
    }
    
    /*public static List<Id> getHierarchy(Id parentId) {
        List<Id> fullHierarchy = new List<Id>();
        List<Id> childAccIds = new List<Id>();
        childAccIds.add(parentId);
        fullHierarchy.add(parentId);
        for(Integer i=0; i<6 ; i++){
            List<Id> childHierarchy = new List<Id>();
        	childHierarchy = fetchChildAccounts(childAccIds);
            childAccIds.clear();
            if(childHierarchy.size() < 1){
                break;
            }
            else{
                childAccIds.addAll(childHierarchy);
                fullHierarchy.addAll(childHierarchy);
            }
        }
        
        return fullHierarchy;
    }
    
    private static List<Id> fetchChildAccounts(List<Id> hierarchy) {
        List<Account> children = [SELECT Id, Name FROM Account WHERE ParentId IN :hierarchy];
        List<Id> childHierarchy = new List<Id>();
        for (Account child : children) {
            childHierarchy.add(child.Id);
            //fetchChildAccounts(child.Id, hierarchy);  // Recursive call to get deeper levels
        }
        return childHierarchy;
    }*/
    
    @AuraEnabled
    public static GraphData addLeadToRelationshipMap(String graphDataJsonString, Id relationshipMapId) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);

        if (relationshipMapId == null || gd == null || gd.nodeDataArray == null) {
            return new GraphData();
        }

        List<pq_Influence_And_Support_Matrix__c> matrixes = getMatrixes(new Set<Id>{ relationshipMapId });

        return MapMemberLeadService.createLeadsForMap(
            gd,
            relationshipMapId,
            getMapInfluence(matrixes),
            getMapSupport(matrixes)
        );
    }

    @AuraEnabled
    public static void deleteMapMemberLeads(List<String> stakeholderIds) {
        if (stakeholderIds == null) {
            return;
        }

        MapMemberLeadService.deleteMapMemberLeads(stakeholderIds);
    }

    //called when you drag a contact and add it on top of the graph
    @AuraEnabled
    public static GraphData addContactToRelationshipMap(Id relationshipMapId, String graphDataJsonString) {
        return RelationshipMapMemberHelper.addContactToRelationshipMap(relationshipMapId, graphDataJsonString);
    }

    //utilised for generation of hierarchy of data present on the canvas
    @AuraEnabled
    public static GraphData addAccountToRelationshipMap(Id relationshipMapId, String graphDataJsonString) {
        GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);

        if (relationshipMapId == null || gd == null || gd.nodeDataArray == null) {
            return new GraphData();
        }

        setMapType(relationshipMapId);

        Set<Id> accountIdSet = new Set<Id>();
        for (GraphNodeData node : gd.nodeDataArray) {
            accountIdSet.add(node.key);
        }
        updateParentAccountForFirstAccount(accountIdSet,relationshipMapId);
        List<Account_Map_Member__c> mapMembers = AccountRelationshipMapService.addAccountToRelationshipMap(
            relationshipMapId,
            accountIdSet
        );
        List<AccountMemberWrapper> wrapperList = new List<AccountMemberWrapper>();
        for (Account_Map_Member__c member : mapMembers) {
            AccountMemberWrapper wrapper = new AccountMemberWrapper(member);
            wrapperList.add(wrapper);
        }

        RMNodeCoordinateService.updateNodeCoordinates(relationshipMapId, gd.nodeDataArray);

        RM_Chart_Setting__C setting = RMChartSettingService.getRelationshipMapSettingForObject(relationshipMapId);
        setting.Show_Parents__c = false;
        setting.Show_Empty_Fields__c = true;

        List<pq_Influence_And_Support_Matrix__c> matrixes = getMatrixes(new Set<Id>{ relationshipMapId });
        return GraphDataService.generateAccountGraphData(
            wrapperList,
            setting,
            getMapInfluence(matrixes),
            getMapSupport(matrixes),
            mapMembersAndAccountFields.get('accounts'),
            orgChartfields,
            relationshipMapId
        );
    }

   public static void updateParentAccountForFirstAccount(Set<Id> accountIdSet,Id relationshipMapId){
        if(!accountIdSet.isEmpty() && relationshipMapId !=null){

            pqcrush__Account_Relationship_Map__c arm = [SELECT Id, pqcrush__Account_Plan_Id__c, pqcrush__Account_Plan_Id__r.pqcrush__Account__c FROM pqcrush__Account_Relationship_Map__c WHERE id=:relationshipMapId WITH SECURITY_ENFORCED];
            List<AggregateResult> count = [SELECT  Count(Id) total FROM pqcrush__Account_Map_Member__c WHERE pqcrush__Account_Relationship_Map__c='a1JOz00000AksVtMAJ' WITH SECURITY_ENFORCED];
            if(arm.pqcrush__Account_Plan_Id__r.pqcrush__Account__c !=null && (Integer.valueOf(count[0].get('total'))==0)){
                Database.UPDATE (new Account(Id=new List<Id>(accountIdSet)[0], ParentId=arm.pqcrush__Account_Plan_Id__r.pqcrush__Account__c), true, Accesslevel.USER_MODE);
            }
        }
    }

    @AuraEnabled
    public static void removeParentId(List<Id> memberIds) {
        if (memberIds == null) {
            return;
        }

        List<Account> membersList = new List<Account>();
        for (Id memberId : memberIds) {
            if (memberId == null) {
                continue;
            }
            membersList.add(new Account(Id = memberId, ParentId=null));
        }
        if (membersList.size() == 0) {
            return;
        }
        Database.update(membersList,true,Accesslevel.USER_MODE);

        /*fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(membersList);
        uow.commitWork();*/
    }

    @AuraEnabled
    public static void deleteMembers(List<Id> memberIds) {
        if (memberIds == null) {
            return;
        }

        List<Relationship_Map_Member__c> membersList = new List<Relationship_Map_Member__c>();
        for (Id memberId : memberIds) {
            if (memberId == null) {
                continue;
            }
            membersList.add(new Relationship_Map_Member__c(Id = memberId));
        }
        if (membersList.size() == 0) {
            return;
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDeleted(membersList);
        uow.commitWork();
    }

    @AuraEnabled
    public static Id getMapIdForSObjectIdNoCreate(Id recordId) {
        return getMapIdForSObjectIdCheckCreate(recordId, false);
    }

    @AuraEnabled
    public static Id getMapIdForSObjectId(Id recordId) {
        if (recordId == null) {
            return null;
        }
        Crush_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        Schema.SObjectType objType = recordId.getSObjectType();
        Boolean shouldCreate = (objType == Account_Plan__c.sObjectType || objType == pq_Master_Account_Plan__c.sObjectType || objType == Account.sObjectType)
            ? orgSettings.Auto_Create_Stakeholder_Maps__c
            : orgSettings.Auto_Create_Relationship_Maps__c;
        return getMapIdForSObjectIdCheckCreate(recordId, shouldCreate);
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isMapMemberLeadCreatable() {
        return Map_Member_Lead__c.sObjectType.getDescribe().isCreateable();
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isMapMemberUserCreatable() {
        return Map_Member_User__c.sObjectType.getDescribe().isCreateable();
    }

    private static Id getMapIdForSObjectIdCheckCreate(Id recordId, Boolean shouldCreate) {
        if (recordId == null) {
            return null;
        }
        Schema.SObjectType objType = recordId.getSObjectType();
        if (objType == null) {
            return null;
        }
        if (objType == pqcrush__Relationship_Map__c.sObjectType) {
            return recordId;
        }
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Query objectQuery = new Query(objType, null).byId(recordId).selectField('Id').setLimit(1);
        Set<Schema.SObjectField> objRelationshipFields = SObjectService.relationshipsFromDescribeMatchingObjectType(
            objDescribe,
            pqcrush__Relationship_Map__c.sObjectType
        );
        objectQuery.selectFields(objRelationshipFields);
        SObject result = (SObject) UtilityForList.first(objectQuery.toSObjectList());
        Id foundId = SObjectService.getFirstIdFromSObjectMatchingFields(result, objRelationshipFields);

        Set<Schema.SObjectField> mapRelationshipFields;
        if (foundId == null) {
            result = null;
            Query mapQuery = new Query(pqcrush__Relationship_Map__c.sObjectType, null)
                .selectField('Id')
                .setLimit(1)
                .orderBy('CreatedDate', 'ASC');
            mapRelationshipFields = SObjectService.relationshipsFromDescribeMatchingObjectType(
                pqcrush__Relationship_Map__c.sObjectType.getDescribe(),
                objDescribe.getSObjectType()
            );
            if (mapRelationshipFields.size() > 0) {
                for (Schema.SObjectField rel : mapRelationshipFields) {
                    mapQuery.addConditionEq(rel, recordId);
                }
                result = (SObject) UtilityForList.first(mapQuery.toSObjectList());
            }
            foundId = SObjectService.getFirstIdFromSObjectMatchingFields(
                result,
                new Set<Schema.SObjectField>{ pqcrush__Relationship_Map__c.Id }
            );
        }
        if (foundId == null && shouldCreate) {
            List<Schema.SObjectField> objFieldList = new List<Schema.SObjectField>(objRelationshipFields);
            List<Schema.SObjectField> mapFieldList = new List<Schema.SObjectField>(mapRelationshipFields);
            pqcrush__Relationship_Map__c theMap = RelationshipMapService.createRelatedMap(
                objFieldList,
                mapFieldList,
                objDescribe,
                recordId
            );
            if (theMap != null) {
                foundId = theMap.Id;
            }
        }
        return foundId;
    }

    public static Map<String, String> getMapInfluence(List<pq_Influence_And_Support_Matrix__c> matrixes) {
        if (influenceMap != null) {
            return influenceMap;
        }

        if (matrixes == null || matrixes.size() <= 0) {
            return new Map<String, String>();
        }

        Set<Id> matrixIds = new Set<Id>();
        for (pq_Influence_And_Support_Matrix__c matrix : matrixes) {
            matrixIds.add(matrix.Id);
        }

        List<pq_Influence__c> influences = InfluenceSupportMatrixService.getInfluencesByMatrixes(matrixIds);

        Map<String, String> inflMap = new Map<String, String>();
        for (pq_Influence__c infl : influences) {
            inflMap.put(infl.Name, infl.Label__c);
        }

        influenceMap = inflMap;

        return influenceMap;
    }

    public static Map<String, String> getMapSupport(List<pq_Influence_And_Support_Matrix__c> matrixes) {
        if (supportMap != null) {
            return supportMap;
        }

        if (matrixes == null || matrixes.size() <= 0) {
            return new Map<String, String>();
        }

        Set<Id> matrixIds = new Set<Id>();
        for (pq_Influence_And_Support_Matrix__c matrix : matrixes) {
            matrixIds.add(matrix.Id);
        }

        List<pq_Support__c> supports = InfluenceSupportMatrixService.getSupportByMatrixes(matrixIds);

        Map<String, String> sMap = new Map<String, String>();
        for (pq_Support__c supp : supports) {
            sMap.put(supp.Name, supp.Label__c);
        }

        supportMap = sMap;

        return supportMap;
    }

    public static List<pq_Influence_And_Support_Matrix__c> getMatrixes(Set<Id> mapIds) {
        if (mapIds == null || mapIds.size() <= 0) {
            return new List<pq_Influence_And_Support_Matrix__c>();
        }

        Map<Id, pq_Influence_And_Support_Matrix__c> matrixes = InfluenceSupportMatrixService.getMatrixesForRelationshipMap(
            mapIds
        );

        List<pq_Influence_And_Support_Matrix__c> result = new List<pq_Influence_And_Support_Matrix__c>();
        for (pq_Influence_And_Support_Matrix__c max : matrixes.values()) {
            if (max != null) {
                result.add(max);
            }
        }

        return result;
    }
}