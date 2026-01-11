@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class CloneRelationshipMapExtension {
    private ApexPages.StandardController sc;

    public CloneRelationshipMapExtension(ApexPages.StandardController standardController) {
        standardController.addFields(new List<String>{ 'Name', 'OwnerId' });
        sc = standardController;
        Relationship_Map__c rm = (Relationship_Map__c) sc.getRecord();
        rm.OwnerId = UserInfo.getUserId();
    }

    public Pagereference cloneMap() {
        Relationship_Map__c rm = (Relationship_Map__c) sc.getRecord();
        List<Relationship_Map__c> clonedPlans = RelationshipMapCloneController.cloneRelationshipMap(
            rm.Id,
            rm.Name,
            rm.OwnerId,
            null
        );
        if (clonedPlans.size() == 0) {
            return null;
        } else if (rm.OwnerId == UserInfo.getUserId()) {
            return new Pagereference('/' + clonedPlans[0].Id);
        } else {
            Schema.DescribeSObjectResult result = Relationship_Map__c.SObjectType.getDescribe();
            return new Pagereference('/' + result.getKeyPrefix() + '/o');
        }
    }

    public Boolean getIsClassic() {
        return (UserInfo.getUiThemeDisplayed() == 'Theme3');
    }
}