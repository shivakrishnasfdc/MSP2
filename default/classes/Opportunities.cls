@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class Opportunities extends fflib_SObjectDomain {
    public Opportunities(List<Opportunity> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static Opportunities newInstance(List<Opportunity> sObjectList) {
        return (Opportunities) Application.Domain.newInstance(sObjectList);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Opportunities(sObjectList);
        }
    }
    
    public override void onAfterInsert() {
        system.debug('onAfterInsert Opp: ');
        Application.bypassTrigger = true;
        OpportunityServiceImpl.createOpportunityPlan(Records);
    }
}