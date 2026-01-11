@SuppressWarnings('PMD.ExcessivePublicCount,PMD.NcssMethodCount')
public with sharing class RelationshipMapMemberHelper {
    
    public static MatrixMember convertToMatrixMember(List<Relationship_Map_Member__c> mapMembers) {
        if (mapMembers == null || mapmembers.size() <= 0) {
            return null;
        }

        // Future convert the whole list and return a map
        Relationship_Map_Member__c mapMember = mapMembers[0];

        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(
            mapMember.Relationship_Map__c
        );

        if (!setting.Is_Influence_Support_Global_Scope__c) {
            return new MatrixMember(mapMember);
        }

        List<Contact_Extended_Field__c> contactExtFields = ContactExtendedFieldSelector.newInstance()
            .selectByContactId(new Set<Id>{ mapMember.Contact__c });
        if (contactExtFields.size() == 1) {
            return new MatrixMember(
                mapMember,
                contactExtFields[0].Influence__r.Name,
                contactExtFields[0].Support__r.Name
            );
        }
        return new MatrixMember(mapMember, null, null);
    }
	public static GraphData addContactToRelationshipMap(Id relationshipMapId, String graphDataJsonString) {
           GraphData gd = (GraphData) JSON.deserialize(graphDataJsonString, GraphData.class);

        if (relationshipMapId == null || gd == null || gd.nodeDataArray == null) {
            return new GraphData();
        }

        RelationshipMapMemberController.setMapType(relationshipMapId);

        Set<Id> contactIdSet = new Set<Id>();
        for (GraphNodeData node : gd.nodeDataArray) {
            contactIdSet.add(node.key);
        }
        List<Relationship_Map_Member__c> mapMembers = RelationshipMapService.addContactToRelationshipMap(
            relationshipMapId,
            contactIdSet
        );
        List<RelationshipMapMemberWrapper> wrapperList = new List<RelationshipMapMemberWrapper>();
        for (Relationship_Map_Member__c member : mapMembers) {
            RelationshipMapMemberWrapper wrapper = new RelationshipMapMemberWrapper(member);
            wrapperList.add(wrapper);
        }

        RMNodeCoordinateService.updateNodeCoordinates(relationshipMapId, gd.nodeDataArray);

        RM_Chart_Setting__C setting = RMChartSettingService.getRelationshipMapSettingForObject(relationshipMapId);
        setting.Show_Parents__c = false;
        setting.Show_Empty_Fields__c = true;

        List<pq_Influence_And_Support_Matrix__c> matrixes = RelationshipMapMemberController.getMatrixes(new Set<Id>{ relationshipMapId });
        return GraphDataService.generateGraphData(
            wrapperList,
            setting,
            RelationshipMapMemberController.getMapInfluence(matrixes),
            RelationshipMapMemberController.getMapSupport(matrixes),
            RelationshipMapMemberController.mapMembersAndContactFields.get('contacts'),
            RelationshipMapMemberController.orgChartfields,
            relationshipMapId
        );
	}
    public static List<MatrixMember> getMapMembersByMapId(Id mapId) {
        if (mapId == null) {
            return new List<MatrixMember>();
        }
        RelationshipMapMemberController.setMapType(mapId);
        List<Relationship_Map_Member__c> rmmList = RelationshipMapMemberSelector.newInstance()
            .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                new Set<Id>{ mapId },
                RelationshipMapMemberController.mapMembersAndContactFields.get('members'),
                RelationshipMapMemberController.mapMembersAndContactFields.get('contacts')
            );

        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact_Extended_Field__c> contactExtMap = new Map<Id, Contact_Extended_Field__c>();
        for (Relationship_Map_Member__c rmm : rmmList) {
            contactIds.add(rmm.Contact__c);
        }
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(mapId);
        if (setting.Is_Influence_Support_Global_Scope__c) {
            List<Contact_Extended_Field__c> contactExtFields = ContactExtendedFieldSelector.newInstance()
                .selectByContactId(contactIds);
            for (Contact_Extended_Field__c cef : contactExtFields) {
                contactExtMap.put(cef.Contact__c, cef);
            }
            List<MatrixMember> matrixMemberList = new List<MatrixMember>();
            for (Relationship_Map_Member__c rmm : rmmList) {
                Contact_Extended_Field__c contactExtField = contactExtMap.get(rmm.Contact__c);
                matrixMemberList.add(
                    new MatrixMember(rmm, contactExtField?.Influence__r?.Name, contactExtField?.Support__r?.Name)
                );
            }
            return matrixMemberList;
        }

        List<MatrixMember> resultForNonGlobal = new List<MatrixMember>();
        for (Relationship_Map_Member__c rmm : rmmList) {
            resultForNonGlobal.add(new MatrixMember(rmm));
        }
        return resultForNonGlobal;
    }
    public static MatrixMember upsertMapMember(Id memberId, String influence, String support) {
        if (memberId == null) {
            return null;
        }

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

        Relationship_Map_Member__c mapMember = RelationshipMapMemberController.getMapMemberById(memberId);
        // GET SETTING, CHECK TO SEE IF LOCAL INFLUENCE SUPPORT OR GLOBAL
        RM_Chart_Setting__c setting = RMChartSettingService.getRelationshipMapSettingForObject(
            mapMember.Relationship_Map__c
        );

        if (setting.Is_Influence_Support_Global_Scope__c) {
            ContactExtendedFieldService.updateInfluenceSupport(mapMember.Contact__c, influenceId, supportId);
            return new MatrixMember(mapMember, influenceName, supportName);
        } else {
            fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();

            RelationshipMapMembers mapMemberRecords = RelationshipMapMembers.newInstance(
                new List<Relationship_Map_Member__c>{ mapMember }
            );

            mapMemberRecords.updateField(Schema.Relationship_Map_Member__c.InfluenceId__c, influenceId, unitOfWork);
            mapMemberRecords.updateField(Schema.Relationship_Map_Member__c.SupportId__c, supportId, unitOfWork);

            unitOfWork.commitWork();

            Relationship_Map_Member__c result = RelationshipMapMemberController.getMapMemberById(memberId);
            return new MatrixMember(result);
        }
    }
    public static GraphData getUserGraphDataForHierarchyId(Id hierarchyId) {
        if (hierarchyId == null || hierarchyId.getSobjectType() != pqcrush__Relationship_Map__c.sObjectType) {
            return new GraphData();
        }

        // Get map instance
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ hierarchyId });
        if (maps.size() == 0) {
            throw Application.createAuraHandledException(
                String.format(System.label.error_insufficient_access, new List<String>{ String.valueOf(hierarchyId) })
            );
        }
        RelationshipMapMemberController.setMapType(hierarchyId);

        // Convert any Leads (that were converted to contacts) to Map Members
        MapMemberLeadService.convertLeadsToMapMembers(hierarchyId);

        // GET ALL KeyStakeholders/MapMembers
        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance()
            .selectByRelationshipMapIdsAndSelectFieldsWithYourContacts(
                new Set<Id>{ hierarchyId },
                RelationshipMapMemberController.mapMembersAndContactFields.get('members'),
                RelationshipMapMemberController.mapMembersAndContactFields.get('contacts')
            );

        // Wrap MapMembers into helper
        Set<String> contactIdSet = new Set<String>();
        List<RelationshipMapMemberWrapper> wrapperList = new List<RelationshipMapMemberWrapper>();
        for (Relationship_Map_Member__c member : members) {
            contactIdSet.add(member.Contact__c);
            RelationshipMapMemberWrapper wrapper = new RelationshipMapMemberWrapper(member);
            wrapperList.add(wrapper);
        }

        // Get Map Settings
        RM_Chart_Setting__C mapSetting = RMChartSettingService.getRelationshipMapSettingForObject(hierarchyId);
        List<pq_Influence_And_Support_Matrix__c> matrixes = RelationshipMapMemberController.getMatrixes(new Set<Id>{ hierarchyId });

        Map<String, String> infl = RelationshipMapMemberController.getMapInfluence(matrixes);
        Map<String, String> supp = RelationshipMapMemberController.getMapSupport(matrixes);

        // Get the KeyStakeholder nodes
        GraphData gd = GraphDataService.generateGraphData(
            wrapperList,
            mapSetting,
            infl,
            supp,
            RelationshipMapMemberController.mapMembersAndContactFields.get('contacts'),
            RelationshipMapMemberController.orgChartfields,
            hierarchyId
        );

        // Add in Placeholder nodes
        gd = GraphDataService.getAndInjectPlaceholderNodes(gd, hierarchyId);

        // Add in Map Member User nodes
        gd = MapMemberUserService.getAndInjectMapMemberUserNodes(gd, hierarchyId);

        // Add in Map Member Lead nodes
        gd = MapMemberLeadService.getAndInjectMapMemberLeadNodes(gd, hierarchyId, infl, supp);

        // Add in registered coordinates for ALL nodes
        gd = GraphDataService.getAndInjectNodeCoordinates(gd, hierarchyId);

        // Add in group links
        gd = GraphDataService.getAndInjectCustomLinks(gd, hierarchyId);

        // Add in badges
        gd = RMSvgService.injectBadges(hierarchyId, gd, mapSetting);

        // Add in local hierarchy links for contacts
        if (!mapSetting.Is_Reports_To_Global_Scope__c) {
            gd = GraphDataService.getAndInjectLocalHierarchyLinksForContacts(hierarchyId, gd, contactIdSet);
        }
        return gd;
    }

}