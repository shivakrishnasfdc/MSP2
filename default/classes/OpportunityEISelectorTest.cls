@isTest
private class OpportunityEISelectorTest {
    @isTest
    static void newInstanceTest() {
        OpportunityEffectivenessIndexSelector selector = OpportunityEffectivenessIndexSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {

        pq_Opportunity_Effectiveness_Index__c newItem1 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = Date.today(),
            Serialized_Won_Data__c = 'test1',
            Serialized_Lost_Data__c = 'test2'
        );

        pq_Opportunity_Effectiveness_Index__c newItem2 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = Date.today(),
            Serialized_Won_Data__c = 'test3',
            Serialized_Lost_Data__c = 'test4'
        );

        insert newItem1;
        insert newItem2;

        List<pq_Opportunity_Effectiveness_Index__c> result =  OpportunityEffectivenessIndexSelector.newInstance().selectById(new Set<Id>{ newItem1.Id, newItem2.Id });
        System.assertEquals(2, result.size());
    }

    @isTest
    static void selectByDateTest() {


        Date d = Date.today();
        pq_Opportunity_Effectiveness_Index__c newItem1 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d,
            Serialized_Won_Data__c = 'test1',
            Serialized_Lost_Data__c = 'test2'
        );

        pq_Opportunity_Effectiveness_Index__c newItem2 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d,
            Serialized_Won_Data__c = 'test3',
            Serialized_Lost_Data__c = 'test4'
        );

        insert newItem1;
        insert newItem2;

        List<pq_Opportunity_Effectiveness_Index__c> result =  OpportunityEffectivenessIndexSelector.newInstance().selectByDate(d);
        System.assertEquals(1, result.size());
        System.assertEquals(newItem1.Id, result[0].Id);
    }

    @isTest
    static void selectByStartDateTest() {
        Date d = Date.today();
        Date d1 = d.addDays(-1);
        Date d2 = d.addDays(-2);

        pq_Opportunity_Effectiveness_Index__c newItem1 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d,
            Serialized_Won_Data__c = 'test1',
            Serialized_Lost_Data__c = 'test2'
        );

        pq_Opportunity_Effectiveness_Index__c newItem2 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d1,
            Serialized_Won_Data__c = 'test3',
            Serialized_Lost_Data__c = 'test4'
        );

        pq_Opportunity_Effectiveness_Index__c newItem3 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d2,
            Serialized_Won_Data__c = 'test3',
            Serialized_Lost_Data__c = 'test4'
        );

        insert newItem1;
        insert newItem2;
        insert newItem3;

        List<pq_Opportunity_Effectiveness_Index__c> result =  OpportunityEffectivenessIndexSelector.newInstance().selectByStartDate(d1);
        System.assertEquals(2, result.size());
        System.assert((result[0].Id == newItem1.Id) || (result[0].Id == newItem2.Id));
        System.assert((result[1].Id == newItem1.Id) || (result[1].Id == newItem2.Id));
    }

    @isTest
    static void selectOneTest() {
        Date d = Date.today();
        Date d1 = d.addDays(-1);
        pq_Opportunity_Effectiveness_Index__c newItem1 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d,
            Serialized_Won_Data__c = 'test1',
            Serialized_Lost_Data__c = 'test2'
        );

        pq_Opportunity_Effectiveness_Index__c newItem2 = new pq_Opportunity_Effectiveness_Index__c(
            Date_of_Data__c = d1,
            Serialized_Won_Data__c = 'test3',
            Serialized_Lost_Data__c = 'test4'
        );

        insert newItem1;
        insert newItem2;

        pq_Opportunity_Effectiveness_Index__c result =  OpportunityEffectivenessIndexSelector.newInstance().selectOne();
        System.assertNotEquals(null, result);
        System.assertEquals(newItem1.Id, result.Id);
    }
}