public with sharing class CampaignMemberSelector extends fflib_SObjectSelector {
    public static CampaignMemberSelector newInstance() {
        return (CampaignMemberSelector) Application.Selector.newInstance(CampaignMember.SObjectType);
    }

    /******************************
     *      QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CampaignMember.Id,
            CampaignMember.ContactId,
            CampaignMember.CampaignId,
            CampaignMember.Status
        };
    }

    public Schema.SObjectType getSObjectType() {
        return CampaignMember.sObjectType;
    }

    public override String getOrderBy() {
        return CampaignMember.LastModifiedById.getDescribe().getName() + ' DESC';
    }

    /******************************
     *      SELECT METHODS
     ******************************/

    public List<CampaignMember> selectByContactId(Set<Id> contactIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('ContactId in :contactIds');

        fflib_SObjectSelector contSelector = new ContactSelector();
        contSelector.configureQueryFactoryFields(query, 'Contact');

        fflib_SObjectSelector campSelector = new CampaignSelector();
        campSelector.configureQueryFactoryFields(query, 'Campaign');

        return Database.query(query.setLimit(20).toSOQL());
    }
}