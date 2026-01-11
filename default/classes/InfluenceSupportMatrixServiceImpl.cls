public with sharing class InfluenceSupportMatrixServiceImpl {
    public Map<Id, pq_Influence_And_Support_Matrix__c> getMatrixesForRelationshipMap(Set<Id> mapIds) {
        Map<Id, pq_Account_Plan_Matrix_Association__c> rmAPXMatrixAssoc = getRMMatrixMapUsingAccountPlan(mapIds);

        Map<Id, RM_Chart_Setting__c> settingsMap = RMChartSettingService.getRelationshipMapSettingForObjects(mapIds);

        // GET ANY MATRIXID THAT IS MAP TO THE RELATIONSHIP MAP
        List<pq_Relationship_Map_Matrix_Association__c> matrixAssocs = RMMatrixAssociationSelector.newInstance()
            .selectByRelationshipMaps(mapIds);

        pq_Influence_And_Support_Matrix__c defaultMatrix = InfluenceSupportMatrixSelector.newInstance().selectDefault();

        Map<Id, pq_Relationship_Map_Matrix_Association__c> mapXmatrixAssoc = new Map<Id, pq_Relationship_Map_Matrix_Association__c>();

        for (pq_Relationship_Map_Matrix_Association__c assoc : matrixAssocs) {
            mapXmatrixAssoc.put(assoc.Relationship_Map__c, assoc);
        }

        Map<Id, pq_Influence_And_Support_Matrix__c> result = new Map<Id, pq_Influence_And_Support_Matrix__c>();

        for (Id mapId : mapIds) {
            // Check to see if its global scope, if yes, returnd default
            RM_Chart_Setting__c setting = settingsMap.get(mapId);
            if (setting.Is_Influence_Support_Global_Scope__c) {
                result.put(mapId, defaultMatrix);
                continue;
            }

            // Check Account Plan Assoc First
            pq_Account_Plan_Matrix_Association__c apAssoc = rmAPXMatrixAssoc.get(mapId);
            if (apAssoc != null) {
                pq_Influence_And_Support_Matrix__c apMatrix = new pq_Influence_And_Support_Matrix__c(
                    Id = apAssoc.Influence_And_Support_Matrix__c,
                    Influence_Label__c = apAssoc.Influence_And_Support_Matrix__r.Influence_Label__c,
                    Support_Label__c = apAssoc.Influence_And_Support_Matrix__r.Support_Label__c
                );

                result.put(mapId, apMatrix);
                continue;
            }

            // Check RM Association
            pq_Relationship_Map_Matrix_Association__c assoc = mapXmatrixAssoc.get(mapId);
            if (assoc != null) {
                pq_Influence_And_Support_Matrix__c matrix = new pq_Influence_And_Support_Matrix__c(
                    Id = assoc.Influence_And_Support_Matrix__c,
                    Influence_Label__c = assoc.Influence_And_Support_Matrix__r.Influence_Label__c,
                    Support_Label__c = assoc.Influence_And_Support_Matrix__r.Support_Label__c
                );

                result.put(mapId, matrix);
                continue;
            }

            // use default if nothings is binded
            result.put(mapId, defaultMatrix);
        }

        return result;
    }

    private Map<Id, pq_Account_Plan_Matrix_Association__c> getRMMatrixMapUsingAccountPlan(Set<Id> mapIds) {
        // Find maps tied to account plans
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(mapIds);
        Map<Id, Id> mapAccountPlan = new Map<Id, Id>();
        Map<Id, pq_Account_Plan_Matrix_Association__c> rmAPXMatrixAssoc = new Map<Id, pq_Account_Plan_Matrix_Association__c>();
        Set<Id> acctPlanIds = new Set<Id>();
        for (Relationship_Map__c rmMap : maps) {
            if (rmMap.pq_AccountPlanId__c != null) {
                mapAccountPlan.put(rmMap.pq_AccountPlanId__c, rmMap.Id);
                acctPlanIds.add(rmMap.pq_AccountPlanId__c);
            }
        }

        if (mapAccountPlan.size() > 0) {
            List<pq_Account_Plan_Matrix_Association__c> apMatrixAssocs = AccountPlanMatrixAssociationSelector.newInstance()
                .selectByAccountPlans(acctPlanIds);

            for (pq_Account_Plan_Matrix_Association__c apMatrixAssoc : apMatrixAssocs) {
                Id rmId = mapAccountPlan.get(apMatrixAssoc.Account_Plan__c);
                rmAPXMatrixAssoc.put(rmId, apMatrixAssoc);
            }
        }

        return rmAPXMatrixAssoc;
    }

    public Map<Id, pq_Influence_And_Support_Matrix__c> getMatrixesForAccountPlan(Set<Id> accountPlanIds) {
        Map<Id, RM_Chart_Setting__c> settingsMap = RMChartSettingService.getRelationshipMapSettingForObjects(
            accountPlanIds
        );

        List<pq_Account_Plan_Matrix_Association__c> matrixAssocs = AccountPlanMatrixAssociationSelector.newInstance()
            .selectByAccountPlans(accountPlanIds);

        pq_Influence_And_Support_Matrix__c defaultMatrix = InfluenceSupportMatrixSelector.newInstance().selectDefault();

        Map<Id, pq_Account_Plan_Matrix_Association__c> accountPlanXmatrixAssoc = new Map<Id, pq_Account_Plan_Matrix_Association__c>();

        for (pq_Account_Plan_Matrix_Association__c assoc : matrixAssocs) {
            accountPlanXmatrixAssoc.put(assoc.Account_Plan__c, assoc);
        }

        Map<Id, pq_Influence_And_Support_Matrix__c> result = new Map<Id, pq_Influence_And_Support_Matrix__c>();

        for (Id accountPlanId : accountPlanIds) {
            pq_Account_Plan_Matrix_Association__c assoc = accountPlanXmatrixAssoc.get(accountPlanId);
            RM_Chart_Setting__c setting = settingsMap.get(accountPlanId);
            if (assoc == null || setting.Is_Influence_Support_Global_Scope__c) {
                result.put(accountPlanId, defaultMatrix);
            } else {
                pq_Influence_And_Support_Matrix__c matrix = new pq_Influence_And_Support_Matrix__c(
                    Id = assoc.Influence_And_Support_Matrix__c,
                    Influence_Label__c = assoc.Influence_And_Support_Matrix__r.Influence_Label__c,
                    Support_Label__c = assoc.Influence_And_Support_Matrix__r.Support_Label__c
                );

                result.put(accountPlanId, matrix);
            }
        }

        return result;
    }

    public List<pq_Influence__c> getInfluencesByMatrixes(Set<Id> matrixIdSet) {
        List<pq_Influence_Matrix_Association__c> influenceAssocs = InfluenceMatrixAssociationSelector.newInstance()
            .selectByMatrixId(matrixIdSet);
        List<pq_Influence__c> result = new List<pq_Influence__c>();

        for (pq_Influence_Matrix_Association__c influenceAssoc : influenceAssocs) {
            result.add(
                new pq_Influence__c(
                    Id = influenceAssoc.Influence__c,
                    Name = influenceAssoc.Influence__r.Name,
                    Label__c = influenceAssoc.Influence__r.Label__c
                )
            );
        }

        return result;
    }

    public List<pq_Support__c> getSupportByMatrixes(Set<Id> matrixIdSet) {
        List<pq_Support_Matrix_Association__c> supportAssocs = SupportMatrixAssociationSelector.newInstance()
            .selectByMatrixId(matrixIdSet);
        List<pq_Support__c> result = new List<pq_Support__c>();

        for (pq_Support_Matrix_Association__c supportAssoc : supportAssocs) {
            result.add(
                new pq_Support__c(
                    Id = supportAssoc.Support__c,
                    Name = supportAssoc.Support__r.Name,
                    Label__c = supportAssoc.Support__r.Label__c,
                    Color__c = supportAssoc.Support__r.Color__c
                )
            );
        }

        return result;
    }

    public MatrixMember buildMatrixMemberForKS(
        Key_Stakeholder__c ks,
        Map<String, FieldMetaData> descFieldMap,
        RM_Chart_Setting__c setting,
        Map<Id, Id> reportsToMap,
        Map<Id, Contact> contactMap
    ) {
        List<MatrixMemberAdditionalField> additionalMemberFields = new List<MatrixMemberAdditionalField>();
        for (String af : descFieldMap.keySet()) {
            additionalMemberFields.add(
                new MatrixMemberAdditionalField(
                    af,
                    descFieldMap.get(af)?.label,
                    descFieldMap.get(af)?.displayType,
                    ks.get(af)
                )
            );
        }

        // Add reports to:
        Contact parent;
        Id reportsToId = null;
        if (setting.Is_Reports_To_Global_Scope__c) {
            Contact c = contactMap.get(ks.Contact__c);
            parent = contactMap.get(c.ReportsToId);
            reportsToId = c?.ReportsToId;
        } else {
            reportsToId = reportsToMap.get(ks.Contact__c);
            parent = contactMap.get(reportsToId);
        }

        // Add reports to field to additional info list
        additionalMemberFields.add(
            new MatrixMemberAdditionalField('reportsto', 'Reports To', 'id', reportsToId, parent?.Name)
        );

        MatrixMember mem = new MatrixMember(ks, additionalMemberFields);
        return mem;
    }

    public MatrixMember buildMatrixMemberForMapMember(
        Relationship_Map_Member__c rmm,
        Map<String, FieldMetaData> descFieldMap,
        RM_Chart_Setting__c setting,
        Map<Id, Id> reportsToMap,
        Map<Id, Contact> contactMap
    ) {
        List<MatrixMemberAdditionalField> additionalMemberFields = new List<MatrixMemberAdditionalField>();
        for (String af : descFieldMap.keySet()) {
            additionalMemberFields.add(
                new MatrixMemberAdditionalField(
                    af,
                    descFieldMap.get(af)?.label,
                    descFieldMap.get(af)?.displayType,
                    rmm.get(af)
                )
            );
        }

        // Add reports to:
        Contact parent;
        Id reportsToId = null;
        if (setting.Is_Reports_To_Global_Scope__c) {
            Contact c = contactMap.get(rmm.Contact__c);
            parent = contactMap.get(c.ReportsToId);
            reportsToId = c?.ReportsToId;
        } else {
            reportsToId = reportsToMap.get(rmm.Contact__c);
            parent = contactMap.get(reportsToId);
        }

        // Add reports to field to additional info list
        additionalMemberFields.add(
            new MatrixMemberAdditionalField('reportsto', 'Reports To', 'id', reportsToId, parent?.Name)
        );

        MatrixMember mem = new MatrixMember(rmm, additionalMemberFields);
        return mem;
    }
}