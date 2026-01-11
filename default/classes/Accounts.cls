@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class Accounts extends fflib_SObjectDomain {
    public Accounts(List<Account> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static Accounts newInstance(List<Account> sObjectList) {
        return (Accounts) Application.Domain.newInstance(sObjectList);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Accounts(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        Application.bypassTrigger = true;
        AccountServiceImpl.addParentId(Records);
    }
}