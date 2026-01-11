@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class Tasks extends PQSObjectDomainExt {
    public Tasks(List<Task> records) {
        super(records);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static Tasks newInstance(List<Task> sObjectList) {
        return (Tasks) Application.Domain.newInstance(sObjectList);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Tasks(sObjectList);
        }
    }
}