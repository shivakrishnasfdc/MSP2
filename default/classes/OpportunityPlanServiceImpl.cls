public with sharing class OpportunityPlanServiceImpl {
    public Query getQueryForOpportunitiesWithoutPlans() {
        Query oppQuery = new Query(Opportunity.SObjectType, null);
        oppQuery.selectFields(new OpportunitySelector().getSObjectFieldList());
        oppQuery.addConditionNotIn(
            'Id',
            new Query(PQ_Opportunity_Plan__c.SObjectType, null).selectField('Opportunity__c')
        );
        System.debug('oppQuery: '+oppQuery);
        return oppQuery;
    }

    public List<PQ_Opportunity_Plan__c> createOpportunityPlans(List<Opportunity> opportunities) {
        if (opportunities == null || opportunities.size() == 0) {
            return new List<PQ_Opportunity_Plan__c>();
        }
        List<PQ_Opportunity_Plan__c> plans = new List<PQ_Opportunity_Plan__c>();
        for (Opportunity opp : opportunities) {
            String oppPlanName = 'Plan - ' + opp.Name;
            oppPlanName = oppPlanName.length() > 80 ? oppPlanName.substring(0, 80) : oppPlanName;
            PQ_Opportunity_Plan__c oppPlan = new PQ_Opportunity_Plan__c(Name = oppPlanName, Opportunity__c = opp.Id);
            plans.add(oppPlan);
        }

        fflib_ISObjectUnitOfWork uow = Application.OpportunityPlanUnitOfWork.newInstance();
        uow.registerNew(plans);
        uow.commitWork();
        return plans;
    }

    public List<Relationship_Map__c> getRelationshipMapsForOppPlanId(Id oppPlanId, Boolean createIfNeeded) {
        if (oppPlanId == null || oppPlanId.getSobjectType() != PQ_Opportunity_Plan__c.SObjectType) {
            return new List<Relationship_Map__c>();
        }
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance()
            .selectByOppPlanIds(new Set<Id>{ oppPlanId });
        if (maps.size() > 0) {
            Set<Id> mapIds = new Map<Id, Relationship_Map__c>(maps).keySet();
            updateOppPlanContactsForRelationshipMaps(mapIds, oppPlanId);
            return maps;
        }
        if (!createIfNeeded) {
            return new List<Relationship_Map__c>();
        }
        Relationship_Map__c createdMap = this.createRelationshipMapForOppPlanId(oppPlanId);
        return new List<Relationship_Map__c>{ createdMap };
    }

    public Relationship_Map__c createRelationshipMapForOppPlanId(Id oppPlanId) {
        if (oppPlanId == null || oppPlanId.getSobjectType() != PQ_Opportunity_Plan__c.SObjectType) {
            return null;
        }
        List<PQ_Opportunity_Plan__c> oppPlans = OpportunityPlanSelector.newInstance()
            .selectByIds(new Set<Id>{ oppPlanId });
        if (oppPlans.size() == 0) {
            return null;
        }
        PQ_Opportunity_Plan__c oppPlan = oppPlans[0];
        Relationship_Map__c newMap = new Relationship_Map__c(
            pq_Opportunity_Plan__c = oppPlanId,
            Name = oppPlan.Name,
            Type_Setting__c = 'pqcrush__PQ_Opportunity_Plan__c'
        );
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(newMap);
        uow.commitWork();

        updateOppPlanContactsForRelationshipMaps(new Set<Id>{ newMap.Id }, oppPlan);

        return newMap;
    }

    public Id getAccountIdForOppPlanId(Id oppPlanId) {
        if (oppPlanId == null || oppPlanId.getSobjectType() != PQ_Opportunity_Plan__c.SObjectType) {
            return null;
        }
        List<PQ_Opportunity_Plan__c> oppPlans = OpportunityPlanSelector.newInstance()
            .selectByIds(new Set<Id>{ oppPlanId });
        if (oppPlans.size() == 0) {
            return null;
        }
        PQ_Opportunity_Plan__c oppPlan = oppPlans[0];
        return oppPlan.Opportunity__r?.AccountId;
    }

    private void updateOppPlanContactsForRelationshipMaps(Set<Id> mapIds, Id oppPlanId) {
        if (
            mapIds == null ||
            mapIds.size() == 0 ||
            oppPlanId == null ||
            oppPlanId.getSobjectType() != PQ_Opportunity_Plan__c.SObjectType
        ) {
            return;
        }
        List<PQ_Opportunity_Plan__c> oppPlans = OpportunityPlanSelector.newInstance()
            .selectByIds(new Set<Id>{ oppPlanId });
        if (oppPlans.size() == 0) {
            return;
        }
        PQ_Opportunity_Plan__c plan = oppPlans[0];
        updateOppPlanContactsForRelationshipMaps(mapIds, plan);
    }

    private void updateOppPlanContactsForRelationshipMaps(Set<Id> mapIds, PQ_Opportunity_Plan__c plan) {
        //Get all contacts from opportunity
        Map<Id, OpportunityContactRole> rolesByContactId = getContactMapForOpportunityId(plan.Opportunity__c);
        Set<Id> roleContactIds = rolesByContactId.keySet();

        //Get history object for auto added to map
        Map<Id, Relationship_Map_Member_Auto_History__c> historyByContactId = getHistoryMapForRMIds(mapIds);
        Set<Id> historyContactIds = historyByContactId.keySet();

        //Get current map members
        Map<Id, List<Relationship_Map_Member__c>> membersByContactId = getMembersMapForMapIds(mapIds);
        Set<Id> mapContactIds = membersByContactId.keySet();

        Boolean anyChangesNeeded = false;

        //if contact is in opp but not in map and not in history, add to map and create history - added to opp role but not yet added to map
        List<Relationship_Map_Member__c> membersToAdd = new List<Relationship_Map_Member__c>();
        List<Relationship_Map_Member_Auto_History__c> historyToAdd = new List<Relationship_Map_Member_Auto_History__c>();
        Set<Id> contactIdsToAdd = new Set<Id>(rolesByContactId.keySet());
        contactIdsToAdd.removeAll(historyContactIds);
        contactIdsToAdd.removeAll(mapContactIds);
        for (Id contactId : contactIdsToAdd) {
            anyChangesNeeded = true;
            for (Id mapId : mapIds) {
                Relationship_Map_Member__c newMember = new Relationship_Map_Member__c(
                    Relationship_Map__c = mapId,
                    Contact__c = contactId
                );
                membersToAdd.add(newMember);
                Relationship_Map_Member_Auto_History__c newHistory = new Relationship_Map_Member_Auto_History__c(
                    RelationshipMapId__c = mapId,
                    ContactId__c = contactId
                );
                historyToAdd.add(newHistory);
            }
        }

        //if contact is not in opp but in map and in history, remove from map and remove history - was added to map automatically in past but removed from opp role since then
        List<Relationship_Map_Member__c> membersToRemove = new List<Relationship_Map_Member__c>();
        List<Relationship_Map_Member_Auto_History__c> historyToRemove = new List<Relationship_Map_Member_Auto_History__c>();
        Set<Id> contactIdsToRemove = new Set<Id>(membersByContactId.keySet());
        contactIdsToRemove.removeAll(roleContactIds);
        contactIdsToRemove.retainAll(historyContactIds);
        for (Id contactId : contactIdsToRemove) {
            anyChangesNeeded = true;
            membersToRemove.addAll(membersByContactId.get(contactId));
            historyToRemove.add(historyByContactId.get(contactId));
        }

        if (anyChangesNeeded) {
            saveOppPlanMemberChanges(membersToAdd, historyToAdd, membersToRemove, historyToRemove);
        }
    }

    private Map<Id, OpportunityContactRole> getContactMapForOpportunityId(Id opportunityId) {
        List<OpportunityContactRole> oppContacts = OpportunityContactRoleSelector.newInstance()
            .selectByOpportunityIds(new Set<Id>{ opportunityId });
        Map<Id, OpportunityContactRole> rolesByContactId = new Map<Id, OpportunityContactRole>();
        for (OpportunityContactRole role : oppContacts) {
            rolesByContactId.put(role.ContactId, role);
        }
        return rolesByContactId;
    }

    private Map<Id, Relationship_Map_Member_Auto_History__c> getHistoryMapForRMIds(Set<Id> mapIds) {
        List<Relationship_Map_Member_Auto_History__c> history = RMMAutoHistorySelector.newInstance()
            .selectByMapIds(mapIds);
        Map<Id, Relationship_Map_Member_Auto_History__c> historyByContactId = new Map<Id, Relationship_Map_Member_Auto_History__c>();
        for (Relationship_Map_Member_Auto_History__c hist : history) {
            historyByContactId.put(hist.ContactId__c, hist);
        }
        return historyByContactId;
    }

    private Map<Id, List<Relationship_Map_Member__c>> getMembersMapForMapIds(Set<Id> mapIds) {
        List<Relationship_Map_Member__c> members = RelationshipMapMemberSelector.newInstance().selectByMapIds(mapIds);
        Map<Id, List<Relationship_Map_Member__c>> membersByContactId = new Map<Id, List<Relationship_Map_Member__c>>();
        for (Relationship_Map_Member__c member : members) {
            if (!membersByContactId.containsKey(member.Contact__c)) {
                membersByContactId.put(member.Contact__c, new List<Relationship_Map_Member__c>());
            }
            membersByContactId.get(member.Contact__c).add(member);
        }
        return membersByContactId;
    }

    private void saveOppPlanMemberChanges(
        List<Relationship_Map_Member__c> membersToAdd,
        List<Relationship_Map_Member_Auto_History__c> historyToAdd,
        List<Relationship_Map_Member__c> membersToRemove,
        List<Relationship_Map_Member_Auto_History__c> historyToRemove
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        if (membersToAdd.size() > 0) {
            uow.registerNew(membersToAdd);
        }
        if (historyToAdd.size() > 0) {
            uow.registerNew(historyToAdd);
        }
        if (membersToRemove.size() > 0) {
            uow.registerDeleted(membersToRemove);
        }
        if (historyToRemove.size() > 0) {
            uow.registerDeleted(historyToRemove);
        }
        uow.commitWork();
    }

    public Boolean hasOpportunityPlanSetting(Id mapId) {
        if (mapId == null) {
            return false;
        }
        // Get map instance
        List<Relationship_Map__c> maps = RelationshipMapSelector.newInstance().selectByIds(new Set<Id>{ mapId });
        if (maps == null || maps.size() == 0) {
            return false;
        }
        if (maps[0].pq_Opportunity_Plan__c != null) {
            return true;
        }

        return false;
    }
}