public with sharing class OpportunityContactRoleSelector extends fflib_SObjectSelector {
    public static OpportunityContactRoleSelector newInstance() {
        return (OpportunityContactRoleSelector) Application.Selector.newInstance(OpportunityContactRole.SObjectType);
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OpportunityContactRole.Id,
            OpportunityContactRole.ContactId,
            OpportunityContactRole.OpportunityId,
            OpportunityContactRole.IsPrimary,
            OpportunityContactRole.Role
        };
    }

    public Schema.SObjectType getSObjectType() {
        return OpportunityContactRole.sObjectType;
    }

    public override String getOrderBy() {
        return 'Opportunity.LastModifiedDate ASC';
    }

    /******************************
     *      SELECT METHODS
     ******************************/

    public List<OpportunityContactRole> selectByContactId(Set<Id> contactIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('ContactId in :contactIds');

        fflib_SObjectSelector oppSelector = new OpportunitySelector();
        oppSelector.configureQueryFactoryFields(query, 'Opportunity');

        return Database.query(query.setLimit(20).toSOQL());
    }

    public List<OpportunityContactRole> selectByOpportunityIds(Set<Id> oppIdSet) {
        if (oppIdSet == null || oppIdSet.isEmpty()) {
            return new List<OpportunityContactRole>();
        }
        return Database.query(
            newQueryFactory()
                .selectField('Opportunity.Id')
                .selectField('Opportunity.IsWon')
                .selectField('Opportunity.IsClosed')
                .selectField('Opportunity.LastModifiedDate')
                .setCondition('OpportunityId IN :oppIdSet')
                .toSOQL()
        );
    }

    public List<OpportunityContactRole> selectByClosedOpportunitiesSince(DateTime dt) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Opportunity.Id')
            .selectField('Opportunity.IsWon')
            .selectField('Opportunity.IsClosed')
            .selectField('Opportunity.LastModifiedDate')
            .setCondition('Opportunity.LastModifiedDate > :dt AND Opportunity.IsClosed = true');
        return Database.query(query.toSOQL());
    }
}