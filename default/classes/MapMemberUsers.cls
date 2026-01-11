@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class MapMemberUsers extends fflib_SObjectDomain {
    public MapMemberUsers(List<Map_Member_User__c> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static MapMemberUsers newInstance(List<Map_Member_User__c> sObjectList) {
        return (MapMemberUsers) Application.Domain.newInstance(sObjectList);
    }

    public static String getUniqueKey(Map_Member_User__c member) {
        return String.valueOf(member.Relationship_Map__c) + String.valueOf(member.User__c);
    }

    /******************************
     *   TRIGGER HANDLER METHODS
     ******************************/

    public override void onValidate() {
        checkDuplicates();
    }

    public override void onValidate(Map<Id, SObject> existingRecords) {
        checkDuplicates();
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private void checkDuplicates() {
        for (
            Map_Member_User__c duplicateMember : MapMemberUserSelector.newInstance().selectDuplicatesAsSystem(Records)
        ) {
            duplicateMember.addError(System.Label.error_duplicate_hierarchy_member);
        }
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new MapMemberUsers(sObjectList);
        }
    }
}