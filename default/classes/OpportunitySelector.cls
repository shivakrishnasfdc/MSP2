public with sharing class OpportunitySelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static OpportunitySelector newInstance() {
        return (OpportunitySelector) Application.Selector.newInstance(Opportunity.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Opportunity.Id,
            Opportunity.Name,
            Opportunity.Amount,
            Opportunity.IsClosed,
            Opportunity.LastModifiedDate
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Opportunity.sObjectType;
    }

    public override String getOrderBy() {
        return Opportunity.Amount.getDescribe().getName() + ' DESC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/
  
}