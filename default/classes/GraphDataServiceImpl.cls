@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class GraphDataServiceImpl {
    public Map<String, String> influenceMap;
    public Map<String, String> supportMap;
    public Set<String> contactFieldSet;
    public Set<String> accountFieldSet;

    private Map<String, String> supportColors {
        get {
            if (supportColors != null) {
                return supportColors;
            }
            try {
                Crush_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
                if (orgSettings != null && orgSettings.Support_Colors_Long__c != null) {
                    supportColors = UtilityForString.parseNameValueStringToMap(orgSettings.Support_Colors_Long__c);
                } else {
                    supportColors = new Map<String, String>();
                }
            } catch (Exception e) {
                supportColors = new Map<String, String>();
            }
            System.debug('===supportColors=='+supportColors);
            return supportColors;
        }
        set;
    }

    /******************************
     *      PRIVATE MEMBERS
     ******************************/

    @TestVisible
    private static List<Org_Chart_Field__c> orgChartfields {
        get {
            if (orgChartfields != null) {
                return orgChartfields;
            }
            orgChartfields = OrgChartSettingsController.getVisibleOrgChartFields('Relationship Map');
            return orgChartfields;
        }
        set;
    }

    @TestVisible
    private static map<String, Set<String>> mapMembersAndContactFields {
        get {
            if (mapMembersAndContactFields != null) {
                return mapMembersAndContactFields;
            }

            Set<String> keyStakeholderFields = new Set<String>();
            Set<String> contactFields = new Set<String>();
            Set<String> userFields = new Set<String>();

            for (Org_Chart_Field__c orgChartfield : orgChartfields) {
                if (orgChartfield.ObjectName__c == Relationship_Map_Member__c.sObjectType.getDescribe().getName()) {
                    keyStakeholderFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == Contact.sObjectType.getDescribe().getName()) {
                    contactFields.add(orgChartfield.FieldName__c);
                } else if (orgChartfield.ObjectName__c == User.sObjectType.getDescribe().getName()) {
                    userFields.add(orgChartfield.FieldName__c);
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

            return mapMembersAndContactFields;
        }
        set;
    }

    /******************************
     *      PUBLIC METHODS
     ******************************/

    public Map<String, String> getSupportColors() {
        return supportColors;
    }
//called when list of contacts is loaded from clicking people button
    public GraphData getContactGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        String accountId,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> contactFields,
        Id mapOrAccountPlanId
    ) {
        System.debug('==searchTerm=='+searchTerm);
        System.debug('==excludeIds=='+excludeIds);
        System.debug('==accountId=='+accountId);
        System.debug('==orgChartfields=='+orgChartfields);
        System.debug('==contactFields=='+contactFields);
        System.debug('==mapOrAccountPlanId=='+mapOrAccountPlanId);
        Id acctId = UtilityForString.getIdForString(accountId);
        Set<Id> accountAndChildAccountIds = new Set<Id>();
        if (acctId != null && acctId.getSObjectType() == Account.getSObjectType()) {
            accountAndChildAccountIds = AccountService.getAccountAndDescendents(acctId).keySet();
            System.debug('===accountAndChildAccountIds=='+accountAndChildAccountIds);
        }
        
        Integer max = 100;
        
        List<Contact> contacts;
        
        Set<Id> excludeSet = new Set<Id>();
        for (String exclude : excludeIds) {
            excludeSet.add(exclude);
        }
        System.debug('===excludeSet=='+excludeSet);
        
        
        if (searchTerm.length() < 3) {
            contacts = ContactSelector.newInstance()
            .selectByAccountIdWithAdditionalFields(excludeSet, contactFields, max, accountAndChildAccountIds);
        } else {
            contacts = ContactSelector.newInstance()
            .search(searchTerm, excludeSet, contactFields, max, accountAndChildAccountIds);
        }
        System.debug('===contacts=='+contacts);

        Set<Id> contactIds = (new Map<Id, Contact>(contacts)).keySet();

        Set<Id> reportsToIds = new Set<Id>();
        for (Contact c : contacts) {
            if (c.ReportsToId != null && !contactIds.contains(c.ReportsToId) && !excludeSet.contains(c.ReportsToId)) {
                reportsToIds.add(c.ReportsToId);
            }
        }
        System.debug('===reportsToIds=='+reportsToIds);

        List<Contact> reportsToContacts = ContactSelector.newInstance()
            .selectByIdAndSelectFields(reportsToIds, contactFields);
            System.debug('===reportsToContacts=='+reportsToContacts);
            
            Set<Contact> allContacts = new Set<Contact>(contacts);
            allContacts.addAll(reportsToContacts);
            System.debug('===allContacts=='+allContacts);
            
            Set<Id> allContactIds = new Set<Id>(contactIds);
            allContactIds.addAll(reportsToIds);
            System.debug('===allContactIds=='+allContactIds);
            
            // "rels" --> Instances of Contacts that are in Map Groups
            List<Relationship_Group_Contact_Association__c> rels = RelationshipGroupContactSelector.newInstance()
            .selectWithGroupsByContactIds(allContactIds);
            System.debug('===rels=='+rels);
            
            RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);
            setting.Show_Parents__c = false;
            setting.Show_Parents__c = true;
            System.debug('===setting=='+setting);
            
            System.debug('===called from getContactGraphDataForSearchTerm');
            System.debug('===contacts=='+contacts);
            System.debug('===reportsToContacts=='+reportsToContacts);
            System.debug('===allContacts=='+allContacts);
            GraphData gd = generateOrgGraph(
                new Set<Contact>(allContacts),
                null,
                rels,
                orgChartfields,
                mapOrAccountPlanId,
                setting
                );
                // Denote any nodes that are parents for Contacts (Reports To)
                for (GraphNodeData gnd : gd.nodeDataArray) {
                    if (reportsToIds.contains(gnd.key)) {
                        gnd.isParentNode = true;
                        System.debug('===gnd=='+gnd);
                    }
                }
                
                // MAKING LINK DATA FOR LIST OF PEOPLE WHO REPORT TO OUR LIST OF CONTACTS
                // SO THAT WHEN WE DROP THESE ON THE CHART, THE LINES INTO & OUT OF THE CONTACTS ARE ALL ACCOUNTED FOR
                List<Contact> reports = ContactSelector.newInstance().selectByReportsToId(contactIds, new Set<String>());
                System.debug('===reports=='+reports);
                System.debug('===gd.linkDataArray=='+gd.linkDataArray);
                for (Contact c : reports) {
                    if (!allContactIds.contains(c.Id)) {
                        String linkId = String.valueOf(c.ReportsToId) + String.valueOf(c.Id);
                        System.debug('===linkId=='+linkId);
                        gd.linkDataArray.add(new GraphLinkData(linkId, null, c.ReportsToId, true, c.Id, '__standard', null));
                    }
                }
                
                System.debug('===gd.linkDataArray=='+gd.linkDataArray);
        return gd;
    }

//account hierarchy : responsible for populating the Account nodes data in the side panel , when we click users button(the side panel appears up)
    public GraphData getAccountGraphDataForSearchTerm(
        String searchTerm,
        List<String> excludeIds,
        String accountId,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> contactFields,
        Id mapOrAccountPlanId
    ) {
        System.debug('===getAccountGraphDataForSearchTerm called from graphDataServieImpl===');
        Id acctId = UtilityForString.getIdForString(accountId);
        System.debug('==getAccountGraphDataForSearchTerm called==');
        
        System.debug('==searchTerm=='+searchTerm);
        System.debug('==excludeIds=='+excludeIds);
        System.debug('==accountId=='+accountId);
        System.debug('==orgChartfields=='+orgChartfields);
        System.debug('==contactFields=='+contactFields);
        System.debug('==mapOrAccountPlanId=='+mapOrAccountPlanId);
        Set<Id> accountAndChildAccountIds = new Set<Id>();
        if (acctId != null && acctId.getSObjectType() == Account.getSObjectType()) {
            accountAndChildAccountIds = AccountService.getAccountAndDescendents(acctId).keySet();
        }

        Integer max = 100;
        List<GraphNodeData> nodeData = new List<GraphNodeData>();
        List<GraphLinkData> linkData = new List<GraphLinkData>();
        Set<Id> excludeIdSet = new  Set<Id> ();
        MapMemberPlaceholderRelationshipSelector mms =new MapMemberPlaceholderRelationshipSelector();
        for(pqcrush__Map_Member_Placeholder_Relationship__c exId : mms.selectByAccountPlanIdAndSelectFields(new Set<Id>{mapOrAccountPlanId}, new Set<String>{'id', 'pqcrush__To__c','pqcrush__From__c','pqcrush__Account_Plan__c'})){
            if(exId.pqcrush__To__c != null) excludeIdSet.add(exId.pqcrush__To__c);
            if(exId.pqcrush__From__c != null) excludeIdSet.add(exId.pqcrush__From__c);
        }
        AccountSelector acs =new AccountSelector();
        for(Account acc: acs.notSelectByIdAndSelectFields(excludeIdSet, new Set<String>{'Id','Name'})){
            
            GraphNodeData newNode = new GraphNodeData(
                acc.Id,
                null,//memberId
                'keystakeholder',//type
                acc.Name,//name
                null,//title
                null,//profileImageUrlOrData
                null,//influence
                null,//influenceImageUrl
                null,//support
                null,//supportColor
                null,//supportImageUrl
                acc.Name,//Account name
                null//additionalFields
            );

            nodeData.add(newNode);
        }

        return  new GraphData(nodeData, linkData);
    }

    public GraphData getLeadGraphDataForSearchTerm(String searchTerm, List<String> excludeIds, Id mapOrAccountPlanId) {
        // Check if users have access to leads
        if (!Schema.sObjectType.Lead.isAccessible()) {
            return new GraphData();
        }

        Integer max = 100;

        Id mapId = mapOrAccountPlanId;

        Set<Id> excludeSet = new Set<Id>();
        for (String exclude : excludeIds) {
            excludeSet.add(exclude);
        }

        Boolean hasAccountPlanSetting = RelationshipMapService.hasAccountPlanSetting(mapId);

        // "rels" --> Instances of Contacts that are in Map Groups
        // List<Relationship_Group_Contact_Association__c> rels = RelationshipGroupContactSelector.newInstance()
        //     .selectWithGroupsByContactIds(allContactIds);

        // GET LEADS
        List<Lead> leads;

        if (searchTerm.length() < 3) {
            leads = LeadSelector.newInstance()
                .selectNonConvertedWithAdditionalFields(excludeSet, new Set<String>(), max);
        } else {
            leads = LeadSelector.newInstance().search(searchTerm, excludeSet, new Set<String>(), max);
        }

        List<GraphNodeData> leadNodes = GraphDataLeadService.createGraphDataNodes(
            leads,
            null,
            null,
            mapOrAccountPlanId
        );

        // Get list of Lead IDs in search results
        Set<String> allLeadIds = new Set<String>();
        for (Lead l : leads) {
            allLeadIds.add(l.Id);
        }

        // TODO -> Move this duplicated code to central location for Leads, Users, Placeholders (all non-Contacts/KS)
        // Get Relationship Links
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);
        List<Map_Member_Placeholder_Relationship__c> links;
        if (setting.Is_Relationship_Line_Global_Scope__c) {
            links = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectGlobalRelationshipsById(allLeadIds, mapOrAccountPlanId, hasAccountPlanSetting);
        } else {
            links = MapMemberPlaceholderRelationshipSelector.newInstance()
                .selectLocalRelationshipsById(allLeadIds, mapOrAccountPlanId, hasAccountPlanSetting);
        }
        List<GraphLinkData> linkData = new List<GraphLinkData>();
        for (Map_Member_Placeholder_Relationship__c link : links) {
            linkData.add(
                new GraphLinkData(
                    link.Id,
                    null,
                    link.From__c,
                    true,
                    link.To__c,
                    link.Type__c,
                    HierarchyHelperService.getLabelForRelationship(link)
                )
            );
        }

        return new GraphData(leadNodes, linkData);
    }

    public GraphData getParentNodesForContactIds(
        List<String> contactIds,
        List<Org_Chart_Field__c> orgChartfields,
        Set<String> contactFields,
        Id mapOrAccountPlanId
    ) {
        Set<Id> contactIdsSet = new Set<Id>();
        for (String contactId : contactIds) {
            contactIdsSet.add(contactId);
        }

        List<Contact> childContacts = ContactSelector.newInstance()
            .selectByIdAndSelectFields(contactIdsSet, contactFields);

        Set<Id> parentIdSet = new Set<Id>();
        for (Contact c : childContacts) {
            if (c.ReportsToId != null) {
                parentIdSet.add(c.ReportsToId);
            }
        }

        List<Contact> parentContacts = ContactSelector.newInstance()
            .selectByIdAndSelectFields(parentIdSet, contactFields);

        List<Relationship_Group_Contact_Association__c> rels = RelationshipGroupContactSelector.newInstance()
            .selectWithGroupsByContactIds(parentIdSet);

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapOrAccountPlanId);
        setting.Show_Parents__c = false;
        setting.Show_Parents__c = true;
        
        System.debug('===called from getParentNodesForContactIds for childgd');
        GraphData childgd = generateOrgGraph(
            new Set<Contact>(childContacts),
            null,
            rels,
            orgChartfields,
            mapOrAccountPlanId,
            setting
        );
        System.debug('===called from getParentNodesForContactIds');
        GraphData gd = generateOrgGraph(
            new Set<Contact>(parentContacts),
            null,
            rels,
            orgChartfields,
            mapOrAccountPlanId,
            setting
        );
        for (GraphNodeData gnd : gd.nodeDataArray) {
            gnd.isParentNode = true;
        }

        gd.linkDataArray.addAll(childgd.linkDataArray);

        return gd;
    }

//account hierarchy : responsible for updating the parent account of the new node after adding the new node on the canvas    
public void updateParentAccountId(
    List<GraphLinkData> graphLinkDataList,
    Id mapOrAccountPlanId,
    RM_Chart_Setting__c setting
) {
    // Handle updating accounts if using global reports to
    System.debug('===updateParentAccountId called in graphDataServiceImpl-===');
    if (setting.Is_Reports_To_Global_Scope__c) {
        for (GraphlinkData variable : graphLinkDataList) {
            System.debug('==variable=='+variable);
        }
        Set<Id> accountIds = new Set<Id>();
        Map<String, String> parentAccountMap = new Map<String, String>();
        for (graphLinkData gld : graphLinkDataList) {
            System.debug('==inside link data loop==');
            accountIds.add(gld.toKey.substring(0,18));
            parentAccountMap.put(gld.toKey, gld.fromKey);
        }
        System.debug('==parentAccountMap=='+parentAccountMap);
        
        List<Account> accounts = AccountSelector.newInstance()
        .selectByIdAndSelectFields(accountIds, new Set<String>{ 'ParentId' });
        
        System.debug('===accounts =='+accounts);
        List<Schema.SObjectType> lissst = new List<Schema.SObjectType>();
        lissst.add( Account.sObjectType);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(lissst);
        for (Account acc : accounts) {
            Id parent = (Id)parentAccountMap.get(acc.Id);
            System.debug('==parent=='+parent);
            if (String.isBlank(parent)) {
                acc.ParentId = null;
            } else {
                Id ParentId = Id.valueOf(parent);
                if (ParentId != null && ParentId.getSobjectType() == Account.sObjectType) {
                    acc.ParentId = parent;
                } else {
                    acc.ParentId = null;
                }
            }
            System.debug('==Account everytime==='+acc);
            uow.registerDirty(acc);
        }

        System.debug('==uow=='+uow);
        uow.commitWork();
    }

    // Handle updating placeholders
    MapMemberPlaceholderService.updatePlaceholderReportToLinks(graphLinkDataList, mapOrAccountPlanId, setting);
}


    public void updateReportsTo(
        List<GraphLinkData> graphLinkDataList,
        Id mapOrAccountPlanId,
        RM_Chart_Setting__c setting
    ) {
        // Handle updating contacts if using global reports to
        if (setting.Is_Reports_To_Global_Scope__c) {
            Set<Id> contactIds = new Set<Id>();
            Map<String, String> reportsToMap = new Map<String, String>();
            for (graphLinkData gld : graphLinkDataList) {
                contactIds.add(gld.toKey);
                reportsToMap.put(gld.toKey, gld.fromKey);
            }

            List<Contact> contacts = ContactSelector.newInstance()
                .selectByIdAndSelectFields(contactIds, new Set<String>{ 'ReportsToId' });

            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            for (Contact c : contacts) {
                String reportsTo = reportsToMap.get(c.Id);
                if (String.isBlank(reportsTo)) {
                    c.ReportsToId = null;
                } else {
                    Id reportsToId = Id.valueOf(reportsTo);
                    if (reportsToId != null && reportsToId.getSobjectType() == Contact.sObjectType) {
                        c.ReportsToId = reportsTo;
                    } else {
                        c.ReportsToId = null;
                    }
                }
                uow.registerDirty(c);
            }

            uow.commitWork();
        }

        // Handle updating placeholders
        MapMemberPlaceholderService.updatePlaceholderReportToLinks(graphLinkDataList, mapOrAccountPlanId, setting);
    }

    // Generate Contact/MapMember centric GraphData
    public GraphData generateGraphData(
        List<IRelationshipMapObject> hierarchyObjects,
        RM_Chart_Setting__c setting,
        Map<String, String> influenceMap,
        Map<String, String> supportMap,
        Set<String> contactFieldSet,
        List<Org_Chart_Field__c> orgChartfields,
        Id mapOrAccountPlanId
    ) {
        System.debug('===called from generateContactGraphData hierarchyObjects===' + hierarchyObjects);
        System.debug('===called from generateContactGraphData setting===' + setting);
        System.debug('===called from generateContactGraphData influenceMap===' + influenceMap);
        System.debug('===called from generateContactGraphData supportMap===' + supportMap);
        System.debug('===called from generateContactGraphData contactFieldSet===' + contactFieldSet);
        System.debug('===called from generateContactGraphData orgChartfields===' + orgChartfields);
        System.debug('===called from generateContactGraphData mapOrAccountPlanId===' + mapOrAccountPlanId);
        if (hierarchyObjects == null || hierarchyObjects.size() == 0) {
            return new GraphData();
        }

        this.influenceMap = influenceMap;
        this.supportMap = supportMap;
        this.contactFieldSet = contactFieldSet;

        Integer levels = 0;
        if (setting.Show_Parents__c) {
            levels = 1;
        }

        if (!setting.Is_Reports_To_Global_Scope__c) {
            levels = 0;
        }

        Map<Id, IRelationshipMapObject> mapRelationshipMapMemberObject = new Map<Id, IRelationshipMapObject>();
        for (IRelationshipMapObject hierarchyObject : hierarchyObjects) {
            mapRelationshipMapMemberObject.put(hierarchyObject.contactId(), hierarchyObject);
        }
        System.debug('===called from generateGraphData mapRelationshipMapMemberObject===' + mapRelationshipMapMemberObject);
        System.debug('===called from generateGraphData levels===' + levels);
        Set<Contact> contacts = getContactsAncestry(hierarchyObjects, levels);
        System.debug('===called from generateGraphData contacts===' + contacts);

        Set<Id> allContactIds = new Set<Id>();
        for (Contact c : contacts) {
            allContactIds.add(c.Id);
        }

        List<Relationship_Group_Contact_Association__c> rels = RelationshipGroupContactSelector.newInstance()
            .selectWithGroupsByContactIds(allContactIds);
            System.debug('===called from generateGraphData');
        return generateOrgGraph(
            contacts,
            mapRelationshipMapMemberObject,
            rels,
            orgChartfields,
            mapOrAccountPlanId,
            setting
        );
    }

//
//account hierarchy : utilised fro generation of hierarchy of data present on the canvas 
    public GraphData generateAccountGraphData(
        List<AccountMapObject> hierarchyObjects,
        RM_Chart_Setting__c setting,
        Map<String, String> influenceMap,
        Map<String, String> supportMap,
        Set<String> accountFieldSet,
        List<Org_Chart_Field__c> orgChartfields,
        Id mapOrAccountPlanId
    ) {
        System.debug('===called from generateAccountGraphData hierarchyObjects===' + hierarchyObjects);
        System.debug('===called from generateAccountGraphData setting===' + setting);
        System.debug('===called from generateAccountGraphData influenceMap===' + influenceMap);
        System.debug('===called from generateAccountGraphData supportMap===' + supportMap);
        System.debug('===called from generateAccountGraphData accountFieldSet===' + accountFieldSet);
        System.debug('===called from generateAccountGraphData orgChartfields===' + orgChartfields);
        System.debug('===called from generateAccountGraphData mapOrAccountPlanId===' + mapOrAccountPlanId);
        if (hierarchyObjects == null || hierarchyObjects.size() == 0) {
            return new GraphData();
        }

        this.influenceMap = influenceMap;
        this.supportMap = supportMap;
        this.accountFieldSet = accountFieldSet;

        Integer levels = 0;
        if (setting.Show_Parents__c) {
            levels = 1;
        }

        if (!setting.Is_Reports_To_Global_Scope__c) {
            levels = 0;
        }

        Map<Id, AccountMapObject> mapRelationshipMapMemberObject = new Map<Id, AccountMapObject>();
        for (AccountMapObject hierarchyObject : hierarchyObjects) {
            System.debug('===each hierarchy object==='+hierarchyObject);

            mapRelationshipMapMemberObject.put(hierarchyObject.accountId(), hierarchyObject);
        }
        System.debug('===mapRelationshipMapMemberObject==='+mapRelationshipMapMemberObject);
        System.debug('===levels==='+levels);
        Set<Account> accounts = getAccountsAncestry(hierarchyObjects, levels);
        System.debug('===called from generateAccountGraphData accounts===' + accounts);
        Set<Id> allAccountIds = new Set<Id>();
        for (Account c : accounts) {
            allAccountIds.add(c.Id);
        }
System.debug('====allAccountIds==='+allAccountIds);
        List<GraphNodeData> nodeData = new List<GraphNodeData>();
        List<GraphLinkData> linkData = new List<GraphLinkData>();
        // RelationshipMapMemberWrapper temp = (RelationshipMapMemberWrapper) hierarchyObjects[0];
            // accountIds.add(temp.pqcrush__Account__c);
        for(Account acc: accounts){
            AccountMapObject hco = mapRelationshipMapMemberObject != null
                ? mapRelationshipMapMemberObject.get(acc.Id)
                : null;
                List<OrgAdditionalField> additionalFields = generateAdditionalAccountFields(
                acc,
                hco,
                orgChartfields,
                setting.Show_Empty_Fields__c
            );
            
            System.debug('==acc.ParentId==='+acc.ParentId);
            System.debug('==acc.ParentId==='+acc);
            GraphNodeData newNode = new GraphNodeData(
                acc.Id,
                null,//memberId
                'keystakeholder',//type
                acc.Name,//name
                null,//title
                null,//profileImageUrlOrData
                null,//influence
                null,//influenceImageUrl
                null,//support
                null,//supportColor
                null,//supportImageUrl
                acc.Name,//Account name
                additionalFields//additionalFields
            );
            System.debug('===newNode===='+newNode);
            nodeData.add(newNode);
            if(acc.ParentId != null){
                String linkId = String.valueOf(acc.ParentId) + String.valueOf(acc.Id);
                    linkData.add(new GraphLinkData(linkId, null, acc.ParentId, true, acc.Id, '__standard', null));
                    System.debug('===linkData everytime==='+linkData);

            }
        }

        return  new GraphData(nodeData, linkData);
    }

    public List<Contact_Relationship_Type__c> getContactRelationshipTypes(Id mapOrAccountPlanId) {
        Id mapId = mapOrAccountPlanId;
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ mapId });
        Boolean hasAccountPlanSetting = false;
        Id accountPlanId = null;
        if (maps != null && maps.size() > 0) {
            Relationship_Map__c rmMap = maps[0];
            if (rmMap?.Type_Setting__c == 'pqcrush__Account_Plan__c') {
                hasAccountPlanSetting = true;
            }

            accountPlanId = rmMap.pq_AccountPlanId__c;
        }

        return ContactRelationshipTypeSelector.newInstance()
            .selectByRelationshipMaps(new Set<Id>{ mapId }, hasAccountPlanSetting, accountPlanId);
    }

    public GraphData getAndInjectLocalHierarchyLinksForContacts(
        Id mapOrAccountPlanId,
        GraphData graphData,
        Set<String> contactIds
    ) {
        if (graphData == null) {
            return null;
        }

        // Retrieve Hierarchy Links
        List<Map_Member_Placeholder_Relationship__c> hierarchyRels = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectHierarchyLinksByPlaceholderId(new Set<Id>{ mapOrAccountPlanId }, contactIds);

        List<GraphLinkData> gldList = new List<GraphLinkData>();

        for (Map_Member_Placeholder_Relationship__c rel : hierarchyRels) {
            gldList.add(new GraphLinkData(rel.Id, null, rel.From__c, true, rel.To__c, rel.Type__c, ''));
        }

        // Inject all local hierarchy links for contacts
        graphData.linkDataArray.addAll(gldList);

        return graphData;
    }


    public GraphData getAndInjectLocalHierarchyLinksFor(
        Id mapOrAccountPlanId,
        GraphData graphData,
        Set<String> contactIds
    ) {
        if (graphData == null) {
            return null;
        }

        // Retrieve Hierarchy Links
        List<Map_Member_Placeholder_Relationship__c> hierarchyRels = MapMemberPlaceholderRelationshipSelector.newInstance()
            .selectHierarchyLinksByPlaceholderId(new Set<Id>{ mapOrAccountPlanId }, contactIds);

        List<GraphLinkData> gldList = new List<GraphLinkData>();

        for (Map_Member_Placeholder_Relationship__c rel : hierarchyRels) {
            gldList.add(new GraphLinkData(rel.Id, null, rel.From__c, true, rel.To__c, rel.Type__c, ''));
        }

        // Inject all local hierarchy links for contacts
        graphData.linkDataArray.addAll(gldList);

        return graphData;
    }

    // -----------------------------------------------------------------

    public GraphData getAndInjectPlaceholderNodes(GraphData graphData, Id mapOrAccountPlanId) {
        if (graphData == null) {
            return null;
        }

        // Build up unique set of node keys
        Set<Id> nodeKeys = new Set<Id>();
        for (GraphNodeData gnd : graphData.nodeDataArray) {
            nodeKeys.add(gnd.key);
        }

        // Retrieve all placeholder nodes and their links related to this object
        GraphData placeholderGraphData = MapMemberPlaceholderService.getPlaceholdersAndLinksByObjectId(
            mapOrAccountPlanId
        );

        // Only inject node data for placeholders that are not already in the unique nodeKeys list (will mainly be group nodes) since both can be in the same groups
        for (GraphNodeData gnd : placeholderGraphData.nodeDataArray) {
            if (nodeKeys.contains(gnd.key)) {
                continue;
            }
            graphData.nodeDataArray.add(gnd);
        }

        // Inject all placeholder links
        graphData.linkDataArray.addAll(placeholderGraphData.linkDataArray);

        return graphData;
    }

    public GraphData getAndInjectNodeCoordinates(GraphData graphData, Id mapOrAccountPlanId) {
        if (graphData == null) {
            return null;
        }

        // Get node locations
        Map<String, RM_Node_Coordinate__c> nodeCoordinates = RMNodeCoordinateService.getNodeCoordinates(
            mapOrAccountPlanId
        );

        Double totalDistance = 0.0;
        Double separation = 400.0;
        Double startingYPosition = -250.0;

        // Loop Through all Nodes and set their coordinates
        for (GraphNodeData gnd : graphData.nodeDataArray) {
            RM_Node_Coordinate__c coordinate = nodeCoordinates.get(gnd.key);
            if (coordinate != null) {
                gnd.location = new Point((Double) coordinate.X__c, (Double) coordinate.Y__c);
            } else {
                gnd.location = new Point(totalDistance, startingYPosition);
                totalDistance += separation;
            }
        }

        return graphData;
    }

    // -----------------------------------------------------------------
    public GraphData getAndInjectCustomLinks(GraphData gd, Id mapId) {
        return MapMemberPlaceholderService.getAndInjectCustomLinks(gd, mapId);
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private GraphData generateOrgGraph(
        Set<Contact> contacts,
        Map<Id, IRelationshipMapObject> mapRelationshipMapMemberObject,
        List<Relationship_Group_Contact_Association__c> rels,
        List<Org_Chart_Field__c> orgChartfields,
        Id mapOrAccountPlanId,
        RM_Chart_Setting__c setting
    ) {
        Id mapId = mapOrAccountPlanId;
        Boolean hasAccountPlanSetting = RelationshipMapService.hasAccountPlanSetting(mapId);
        System.debug('===hasAccountPlanSetting=='+hasAccountPlanSetting);
        Map<Id, Relationship_Group_Contact_Association__c> groupContactAssocByContactId = RelationshipGroupService.getGroupContactAssocMap(
            rels,
            mapOrAccountPlanId
            );
            System.debug('===groupContactAssocByContactId=='+groupContactAssocByContactId);
            // ALL CONTACTS IN THE GRAPH
            Set<Id> allContactIds = new Set<Id>();
            for (Contact c : contacts) {
                allContactIds.add(c.Id);
            }
            System.debug('===allContactIds=='+allContactIds);

        List<GraphNodeData> nodeData = new List<GraphNodeData>();
        List<GraphLinkData> linkData = new List<GraphLinkData>();

        // GET RESOURCE URLS FOR INFLUENCE & SUPPORT KEYS
        Map<String, String> mapInfluenceImageUrl = new Map<String, String>();
        if (influenceMap != null) {
            mapInfluenceImageUrl = StaticResourceService.getResourceUrlsForResourceNames(influenceMap.KeySet());
        }
        System.debug('===mapInfluenceImageUrl=='+mapInfluenceImageUrl);
        Map<String, String> mapSupportImageUrl = new Map<String, String>();
        if (supportMap != null) {
            mapSupportImageUrl = StaticResourceService.getResourceUrlsForResourceNames(supportMap.KeySet());
        }
        System.debug('===mapSupportImageUrl=='+mapSupportImageUrl);
        Map<Id, Relationship_Group__c> relGroups = new Map<Id, Relationship_Group__c>();

        // Get Contact Extended Data (where the profile image base64 data is stored)
        List<Contact_Extended_Field__c> extendedFields = ContactExtendedFieldSelector.newInstance()
            .selectByContactId(allContactIds);
            System.debug('==extendedFields=='+extendedFields);
            System.debug('==allContactIds=='+allContactIds);
        Map<Id, Contact_Extended_Field__c> mapContactExtendedFields = new Map<Id, Contact_Extended_Field__c>();
        for (Contact_Extended_Field__c extendedField : extendedFields) {
            mapContactExtendedFields.put(extendedField.Contact__c, extendedField);
        }
        System.debug('==mapContactExtendedFields=='+mapContactExtendedFields);
        for (Contact c : contacts) {
            IRelationshipMapObject hco = mapRelationshipMapMemberObject != null
                ? mapRelationshipMapMemberObject.get(c.Id)
                : null;
            List<OrgAdditionalField> additionalFields = generateAdditionalContactFields(
                c,
                hco,
                orgChartfields,
                setting.Show_Empty_Fields__c
            );
            System.debug('==additionalFields=='+additionalFields);
            System.debug('==c=='+c);
            System.debug('==hco=='+hco);
            System.debug('==setting=='+setting);
            // CREATE NODE DATA
            GraphNodeData newNode = generateNodeData(
                c,
                hco,
                additionalFields,
                mapInfluenceImageUrl,
                mapSupportImageUrl,
                mapContactExtendedFields.get(c.Id),
                setting
            );
            System.debug('===newNode=='+newNode);
            Relationship_Group_Contact_Association__c groupContactAssoc = groupContactAssocByContactId.get(c.Id);
            if (groupContactAssoc != null) {
                newNode.groupKey = groupContactAssoc.Relationship_Group__c;
                relGroups.put(groupContactAssoc.Relationship_Group__r.Id, groupContactAssoc.Relationship_Group__r);
            }

            System.debug('===relGroups===' + relGroups);
            nodeData.add(newNode);

            if (c.ReportsToId != null && setting.Is_Reports_To_Global_Scope__c) {
                String linkId = String.valueOf(c.ReportsToId) + String.valueOf(c.Id);
                linkData.add(new GraphLinkData(linkId, null, c.ReportsToId, true, c.Id, '__standard', null));
            }
            System.debug('===linkData=== ' + linkData);
        }

        Map<Id, Relationship_Group__c> allGroups = RelationshipGroupService.getAllGroups(relGroups, mapOrAccountPlanId);
        System.debug('===allGroups==' + allGroups);

        nodeData.addAll(RelationshipGroupService.createNodeDataForGroups(allGroups.values()));
        linkData.addAll(
            ContactRelationshipService.getRelationships(allContactIds, mapOrAccountPlanId, hasAccountPlanSetting)
        );
        System.debug('===nodeData==' + nodeData);
        System.debug('===linkData1=== ' + linkData);
        System.debug('===GraphData=== ' + new GraphData(nodeData, linkData));
        return new GraphData(nodeData, linkData);
    }

    private Set<Contact> getContactsAncestry(List<IRelationshipMapObject> hierarchyObjects, Integer levels) {
        Map<Id, Contact> contactMap = new Map<Id, Contact>(); //Using Map instead of Set because Contact Equality borks if Mailing Address field is included
        
        Set<Id> contactIds = new Set<Id>();
        for (IRelationshipMapObject hierarchyObject : hierarchyObjects) {
            contactIds.add(hierarchyObject.contactId());
        }
        System.debug('==contactIds=='+contactIds);
        for (Integer i = 0; i <= levels; i++) {
            List<Contact> selectedcontacts = ContactSelector.newInstance()
            .selectByIdAndSelectFields(contactIds, contactFieldSet);
            Set<Id> selectedContactIds = new Map<Id, Contact>(selectedcontacts).keyset();
            System.debug('==selectedContactIds=='+selectedContactIds);

            Set<Id> newContactIds = new Set<Id>();

            for (Contact c : selectedcontacts) {
                if (c.ReportsToId != null) {
                    newContactIds.add(c.ReportsToId);
                }
            }

            for (IRelationshipMapObject hierarchyObject : hierarchyObjects) {
                if (
                    !(hierarchyObject instanceof RelationshipMapMemberWrapper) &&
                    !(hierarchyObject instanceof StakeholderWrapper)
                ) {
                    continue;
                }

                Id contactId = hierarchyObject.contactId();
                if (!selectedContactIds.contains(contactId) && contactIds.contains(contactId)) {
                    selectedcontacts.add(
                        new Contact(
                            Id = hierarchyObject.contactId(),
                            FirstName = hierarchyObject.contactFirstName(),
                            LastName = hierarchyObject.contactLastName(),
                            ReportsToId = hierarchyObject.parentId()
                        )
                    );

                    if (hierarchyObject.parentId() != null) {
                        newContactIds.add(hierarchyObject.parentId());
                    }
                }
            }

            System.debug('==ContactIds before=='+contactIds);
            contactIds.removeAll(contactIds);
            System.debug('==ContactIds removeAll=='+contactIds);
            System.debug('==newContactIds =='+newContactIds);
            contactIds.addAll(newContactIds);
            System.debug('==ContactIds adAll=='+contactIds);
            System.debug('==contactMap =='+contactMap);
            
            contactMap.putAll(selectedcontacts);
            System.debug('==contactMap =='+contactMap);
            
            if (contactIds.isEmpty()) {
                break;
            }
        }
        System.debug('==contactMap values=='+contactMap.values());
        Set<Contact> contacts = new Set<Contact>(contactMap.values());

        return contacts;
    }
    private Set<Account> getAccountsAncestry(List<AccountMapObject> hierarchyObjects, Integer levels) {
        Map<Id, Account> accountMap = new Map<Id, Account>(); //Using Map instead of Set because Contact Equality borks if Mailing Address field is included
        
       Set<Id> accountIds = new Set<Id>();
        for (AccountMapObject hierarchyObject : hierarchyObjects) {
            // RelationshipMapMemberWrapper temp = (RelationshipMapMemberWrapper) hierarchyObject;
            accountIds.add(hierarchyObject.accountId());
        }
        System.debug('==accountIds=='+accountIds);
       
        // System.debug('==contactIds=='+contactIds);
        for (Integer i = 0; i <= levels; i++) {
            List<Account> selectedaccounts = AccountSelector.newInstance()
            .selectByIdAndSelectFields(accountIds, accountFieldSet);
            Set<Id> selectedAccountIds = new Map<Id, Account>(selectedaccounts).keyset();
            System.debug('==selectedAccountIds=='+selectedAccountIds);

            Set<Id> newAccounttIds = new Set<Id>();

            // for (Account c : selectedaccounts) {
            //     if (c.ReportsToId != null) {
            //         newAccounttIds.add(c.ReportsToId);
            //     }
            // }

            for (AccountMapObject hierarchyObject : hierarchyObjects) {
                if (
                    !(hierarchyObject instanceof RelationshipMapMemberWrapper) &&
                    !(hierarchyObject instanceof StakeholderWrapper)
                ) {
                    continue;
                }
                Id accountId = hierarchyObject.accountId();
                if (!selectedAccountIds.contains(accountId) && accountIds.contains(accountId)) {
                    selectedaccounts.add(
                        new Account(
                            Id = hierarchyObject.id(),
                            Name = hierarchyObject.accountFirstName()
                            // LastName = hierarchyObject.contactLastName(),
                            // ReportsToId = hierarchyObject.parentId()
                        )
                    );

                    // if (hierarchyObject.parentId() != null) {
                    //     newAccounttIds.add(hierarchyObject.parentId());
                    // }
                }
            }

            System.debug('==accountIds before=='+accountIds);
            accountIds.removeAll(accountIds);
            System.debug('==accountIds removeAll=='+accountIds);
            System.debug('==newAccounttIds =='+newAccounttIds);
            accountIds.addAll(newAccounttIds);
            System.debug('==accountIds adAll=='+accountIds);
            System.debug('==accountMap =='+accountMap);
            
            accountMap.putAll(selectedaccounts);
            System.debug('==accountMap =='+accountMap);
            
            if (accountIds.isEmpty()) {
                break;
            }
        }
        System.debug('==accountMap values=='+accountMap.values());
        Set<Account> accounts = new Set<Account>(accountMap.values());
        System.debug('====returning from AccountAncestry==='+accounts);
        return accounts;
    }

    private GraphNodeData generateNodeData(
        Contact c,
        IRelationshipMapObject member,
        List<OrgAdditionalField> additionalFields,
        Map<String, String> mapInfluenceImageUrl,
        Map<String, String> mapSupportImageUrl,
        Contact_Extended_Field__c contactExtendedField,
        RM_Chart_Setting__c setting
    ) {
        String influenceImageUrl = null;
        String supportImageUrl = null;
        String influence = null;
        String support = null;
        String supportColor = null;
        Id memberId = null;
        String type = 'contact';

        if (member != null) {
            memberId = member.id();
            type = 'keystakeholder';
            influence = member.influence();
            support = member.support();
            supportColor = member.supportColor();
            influenceImageUrl = mapInfluenceImageUrl != null ? mapInfluenceImageUrl.get(influence) : null;
            supportImageUrl = mapSupportImageUrl != null ? mapSupportImageUrl.get(support) : null;
        }

        if (setting.Is_Influence_Support_Global_Scope__c) {
            support = contactExtendedField?.Support__r.Name;
            influence = contactExtendedField?.Influence__r.Name;
            supportColor = contactExtendedField?.Support__r.Color__c;
        }
        System.debug('==c.Id=='+c.Id);
        System.debug('==memberId=='+memberId);
        System.debug('==type=='+type);
        System.debug('==name=='+(c.FirstName != null ? c.FirstName : '') + (c.LastName != null ? (' ' + c.LastName) : ''));
        System.debug('==title=='+(String) UtilityForSObject.getFieldValue(c, 'Title'));
        System.debug('==profileImageUrlOrData=='+contactExtendedField?.Profile_Picture_Data__c);
        System.debug('==influence=='+influence);
        System.debug('==influenceImageUrl=='+influenceImageUrl);
        System.debug('==support=='+support);
        System.debug('==supportColor=='+supportColor);
        System.debug('==getAccountName(c)=='+getAccountName(c));
        System.debug('==additionalFields=='+additionalFields);
        GraphNodeData gnd = new GraphNodeData(
            c.Id,
            memberId,
            type,
            (c.FirstName != null ? c.FirstName : '') + (c.LastName != null ? (' ' + c.LastName) : ''),
            (String) UtilityForSObject.getFieldValue(c, 'Title'),
            contactExtendedField?.Profile_Picture_Data__c,
            influence,
            influenceImageUrl,
            support,
            supportColor,
            supportImageUrl,
            getAccountName(c),
            additionalFields
        );
        return gnd;
    }

    private String getAccountName(Contact c) {
        Map<String, Object> queriedFields = c.getPopulatedFieldsAsMap();
        Account a = (Account) queriedFields.get('Account');

        if (a != null && !String.isBlank(a.Name)) {
            return a.Name;
        }
        return '';
    }

    private List<OrgAdditionalField> generateAdditionalContactFields(
        Contact c,
        IRelationshipMapObject hierarchyObject,
        List<Org_Chart_Field__c> orgChartfields,
        Boolean showEmptyFields
    ) {
        List<OrgAdditionalField> additionalFields = new List<OrgAdditionalField>();
        Set<String> fieldNames = new Set<String>();

        for (Org_Chart_Field__c field : orgChartfields) {
            if (isNonNameContactField(field)) {
                String val = '';
                if (field.FieldName__c.contains('.')) {
                    val = getRelatedFieldValue(c, field.FieldName__c);
                } else {
                    val = String.valueOf(c.get(field.FieldName__c));
                }
                if ((showEmptyFields || !String.isBlank(val)) && !fieldNames.contains(field.FieldName__c)) {
                    additionalFields.add(
                        new OrgAdditionalField(
                            field.FieldName__c,
                            field.FieldLabel__c,
                            val,
                            field.IsMain__c,
                            getValType(val)
                        )
                    );
                    fieldNames.add(field.FieldName__c);
                }
            } else if (isNonInfluenceAndSupportField(field, hierarchyObject)) {
                String val = String.valueOf(hierarchyObject.get(field.FieldName__c));
                if ((showEmptyFields || !String.isBlank(val)) && !fieldNames.contains(field.FieldName__c)) {
                    additionalFields.add(
                        new OrgAdditionalField(field.FieldName__c, field.FieldLabel__c, val, field.IsMain__c, '')
                    );
                    fieldNames.add(field.FieldName__c);
                }
            }
        }

        return additionalFields;
    }

    private List<OrgAdditionalField> generateAdditionalAccountFields(
        Account c,
        AccountMapObject hierarchyObject,
        List<Org_Chart_Field__c> orgChartfields,
        Boolean showEmptyFields
    ) {
        List<OrgAdditionalField> additionalFields = new List<OrgAdditionalField>();
        Set<String> fieldNames = new Set<String>();

        for (Org_Chart_Field__c field : orgChartfields) {
            if (isNonNameAccountField(field)) {
                String val = '';
                if (field.FieldName__c.contains('.')) {
                    val = getAccountRelatedFieldValue(c, field.FieldName__c);
                } else {
                    val = String.valueOf(c.get(field.FieldName__c));
                }
                if ((showEmptyFields || !String.isBlank(val)) && !fieldNames.contains(field.FieldName__c)) {
                    additionalFields.add(
                        new OrgAdditionalField(
                            field.FieldName__c,
                            field.FieldLabel__c,
                            val,
                            field.IsMain__c,
                            getValType(val)
                        )
                    );
                    fieldNames.add(field.FieldName__c);
                }
            } else if (isAccountNonInfluenceAndSupportField(field, hierarchyObject)) {
                String val = String.valueOf(hierarchyObject.get(field.FieldName__c));
                if ((showEmptyFields || !String.isBlank(val)) && !fieldNames.contains(field.FieldName__c)) {
                    additionalFields.add(
                        new OrgAdditionalField(field.FieldName__c, field.FieldLabel__c, val, field.IsMain__c, '')
                    );
                    fieldNames.add(field.FieldName__c);
                }
            }
        }

        return additionalFields;
    }

    private String getRelatedFieldValue(Contact c, String relatedStringField) {
        SObject result = (SObject) c;
        List<String> parts = relatedStringField.split('\\.');
        for (Integer i = 0; i < parts.size() - 1; i++) {
            String part = parts[i];
            result = result.getSObject(part);
            if (result == null) {
                return null;
            }
        }

        return String.valueOf(result.get(parts[parts.size() - 1]));
    }
    private String getAccountRelatedFieldValue(Account c, String relatedStringField) {
        SObject result = (SObject) c;
        List<String> parts = relatedStringField.split('\\.');
        for (Integer i = 0; i < parts.size() - 1; i++) {
            String part = parts[i];
            result = result.getSObject(part);
            if (result == null) {
                return null;
            }
        }

        return String.valueOf(result.get(parts[parts.size() - 1]));
    }

    private String getValType(String val) {
        if (String.isEmpty(val)) {
            return '';
        }
        // https://mathiasbynens.be/demo/url-regex using @diegoperini
        Boolean isUrlPattern = Pattern.matches(
            '^(?:(?:(?:https?|ftp):)?\\/\\/)(?:\\S+(?::\\S*)?@)?(?:(?!(?:10|127)(?:\\.\\d{1,3}){3})(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z0-9\\u00a1-\\uffff][a-z0-9\\u00a1-\\uffff_-]{0,62})?[a-z0-9\\u00a1-\\uffff]\\.)+(?:[a-z\\u00a1-\\uffff]{2,}\\.?))(?::\\d{2,5})?(?:[/?#]\\S*)?$',
            val.toLowerCase()
        );
        if (!isUrlPattern) {
            return '';
        }

        if (val.containsIgnoreCase('linkedin.com')) {
            return 'linkedin';
        }

        if (val.containsIgnoreCase('facebook.com')) {
            return 'facebook';
        }

        if (val.containsIgnoreCase('twitter.com')) {
            return 'twitter';
        }

        return '';
    }

    private Boolean isNonNameContactField(Org_Chart_Field__c field) {
        return field.ObjectName__c == Contact.sObjectType.getDescribe().getName() &&
            field.FieldName__c != 'Name' &&
            field.FieldName__c != 'FirstName' &&
            field.FieldName__c != 'LastName' &&
            field.FieldName__c != 'Title';
    }
    private Boolean isNonNameAccountField(Org_Chart_Field__c field) {
        return field.ObjectName__c == Account.sObjectType.getDescribe().getName() &&
            field.FieldName__c != 'Name';
    }

    private Boolean isNonInfluenceAndSupportField(Org_Chart_Field__c field, IRelationshipMapObject hierarchyObject) {
        if (hierarchyObject == null) {
            return false;
        }
        return field.ObjectName__c == hierarchyObject.objectName() &&
            field.FieldName__c != 'pqcrush__Influence__c' &&
            field.FieldName__c != 'pqcrush__Support__c';
    }
    private Boolean isAccountNonInfluenceAndSupportField(Org_Chart_Field__c field, AccountMapObject hierarchyObject) {
        if (hierarchyObject == null) {
            return false;
        }
        return field.ObjectName__c == hierarchyObject.objectName() &&
            field.FieldName__c != 'pqcrush__Influence__c' &&
            field.FieldName__c != 'pqcrush__Support__c';
    }

    // GET CONTACTS THAT NO LONGER HAVE PARENTS
    private static List<GraphLinkData> getOldRelationshipLinks(GraphData oldData) {
        List<GraphLinkData> oldRelationshipLinks = new List<GraphLinkData>();
        for (GraphLinkData gld : oldData.linkDataArray) {
            if (!String.isBlank(gld.category)) {
                oldRelationshipLinks.add(gld);
            }
        }
        return oldRelationshipLinks;
    }
}