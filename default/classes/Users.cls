@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class Users extends fflib_SObjectDomain {
    public Users(List<User> sObjectList) {
        super(sObjectList);

        // Our trigger is not doing anything with User objects directly so doesn't need the check.
        // However if customer's code is doing something with Users having CRUD enabled can interfere with that.
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Users(sObjectList);
        }
    }
}