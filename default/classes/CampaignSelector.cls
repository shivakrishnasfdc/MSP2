public with sharing class CampaignSelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static CampaignSelector newInstance() {
        return (CampaignSelector) Application.Selector.newInstance(Campaign.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Campaign.Id, Campaign.Name, Campaign.IsActive };
    }

    public Schema.SObjectType getSObjectType() {
        return Campaign.sObjectType;
    }

    public override String getOrderBy() {
        return Campaign.Name.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/
}