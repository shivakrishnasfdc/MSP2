@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class Contacts extends fflib_SObjectDomain {
    public Contacts(List<Contact> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static Contacts newInstance(List<Contact> sObjectList) {
        return (Contacts) Application.Domain.newInstance(sObjectList);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Contacts(sObjectList);
        }
    }
    
    public override void onAfterInsert() {
        Application.bypassTrigger = true;
        ContactServiceImpl.createRelationMapMember(Records);
    }
}