public with sharing class OpportunityEffectivenessIndexSelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static OpportunityEffectivenessIndexSelector newInstance() {
        return (OpportunityEffectivenessIndexSelector) Application.Selector.newInstance(pq_Opportunity_Effectiveness_Index__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            pq_Opportunity_Effectiveness_Index__c.Id,
            pq_Opportunity_Effectiveness_Index__c.Date_of_Data__c,
            pq_Opportunity_Effectiveness_Index__c.Serialized_Lost_Data__c,
            pq_Opportunity_Effectiveness_Index__c.Serialized_Won_Data__c,
            pq_Opportunity_Effectiveness_Index__c.Total_Won__c,
            pq_Opportunity_Effectiveness_Index__c.Total_Lost__c,
            pq_Opportunity_Effectiveness_Index__c.Total_Won_With_Contact__c,
            pq_Opportunity_Effectiveness_Index__c.Total_Lost_With_Contact__c,
            pq_Opportunity_Effectiveness_Index__c.Rolling_Serialized_Lost_Data__c,
            pq_Opportunity_Effectiveness_Index__c.Rolling_Serialized_Won_Data__c,
            pq_Opportunity_Effectiveness_Index__c.Rolling_Total_Lost__c,
            pq_Opportunity_Effectiveness_Index__c.Rolling_Total_Won__c,
            pq_Opportunity_Effectiveness_Index__c.Rolling_Total_Lost_With_Contact__c,
            pq_Opportunity_Effectiveness_Index__c.Rolling_Total_Won_With_Contact__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return pq_Opportunity_Effectiveness_Index__c.sObjectType;
    }

    public override String getOrderBy() {
        return pq_Opportunity_Effectiveness_Index__c.Date_of_Data__c.getDescribe().getName() + ' DESC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<pq_Opportunity_Effectiveness_Index__c> selectById(Set<Id> ids) {
        return Database.query(newQueryFactory().setCondition('Id IN :ids').toSOQL());
    }

    public List<pq_Opportunity_Effectiveness_Index__c> selectByDate(Date day) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Date_of_Data__c = :day').setLimit(1);
        return Database.query(query.toSOQL());
    }

    public List<pq_Opportunity_Effectiveness_Index__c> selectByStartDate(Date startDate) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Date_of_Data__c >= :startDate');
        return Database.query(query.toSOQL());
    }

    // Getting 1 (the latest one, order by date desc above)
    public pq_Opportunity_Effectiveness_Index__c selectOne() {
        fflib_QueryFactory query = newQueryFactory().setLimit(1);
        List<pq_Opportunity_Effectiveness_Index__c> oeiList = Database.query(query.toSOQL());
        if (oeiList != null && oeiList.size() == 1) {
            return oeiList[0];
        }
        return null;
    }
}