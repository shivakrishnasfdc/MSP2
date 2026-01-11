@isTest
private class OpportunityEffectivenessDataTest {
    @isTest
    static void instanceTest() {
        OpportunityEffectivenessData result = new OpportunityEffectivenessData();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void convertNullTest() {
        pq_Opportunity_Effectiveness_Index__c input = null;
        OpportunityEffectivenessData result = OpportunityEffectivenessData.convert(input);
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.lostMap);
        System.assertNotEquals(null, result.wonMap);
    }

    @isTest
    static void convertTest1() {
        pq_Opportunity_Effectiveness_Index__c input = new pq_Opportunity_Effectiveness_Index__c(
            Serialized_Lost_Data__c = '',
            Serialized_Won_Data__c = '',
            Total_Lost__c = 12,
            Total_Won__c = 18,
            Total_Won_With_Contact__c = 20,
            Total_Lost_With_Contact__c = 24
        );

        OpportunityEffectivenessData result = OpportunityEffectivenessData.convert(input);

        System.assertNotEquals(null, result);
        System.assertEquals(12, result.totalLost);
        System.assertEquals(18, result.totalWon);
        System.assertEquals(20, result.wonWithContact);
        System.assertEquals(24, result.lostWithContact);

        System.assertNotEquals(null, result.lostMap);
        System.assertNotEquals(null, result.wonMap);
    }

    @isTest
    static void convertTest2() {
        pq_Opportunity_Effectiveness_Index__c input = new pq_Opportunity_Effectiveness_Index__c(
            Serialized_Lost_Data__c = '{"Business User":27,"Decision Maker":10,"Influencer":32}',
            Serialized_Won_Data__c = '{"Decision Maker":43,"Influencer":36,"Business User":31}',
            Total_Lost__c = 12,
            Total_Won__c = 18,
            Total_Won_With_Contact__c = 20,
            Total_Lost_With_Contact__c = 24
        );

        OpportunityEffectivenessData result = OpportunityEffectivenessData.convert(input);

        System.assertNotEquals(null, result);
        System.assertEquals(12, result.totalLost);
        System.assertEquals(18, result.totalWon);
        System.assertEquals(20, result.wonWithContact);
        System.assertEquals(24, result.lostWithContact);

        System.assertNotEquals(null, result.lostMap);
        System.assertNotEquals(null, result.wonMap);

        System.assertEquals(27, result.lostMap.get('Business User'));
        System.assertEquals(10, result.lostMap.get('Decision Maker'));
        System.assertEquals(32, result.lostMap.get('Influencer'));
        System.assertEquals(43, result.wonMap.get('Decision Maker'));
        System.assertEquals(36, result.wonMap.get('Influencer'));
        System.assertEquals(31, result.wonMap.get('Business User'));
    }

    @isTest
    static void convertRollingNullTest() {
        pq_Opportunity_Effectiveness_Index__c input = null;
        OpportunityEffectivenessData result = OpportunityEffectivenessData.convertForRollingData(input);
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.lostMap);
        System.assertNotEquals(null, result.wonMap);
    }

    @isTest
    static void convertForRollingDataTest() {
        pq_Opportunity_Effectiveness_Index__c input = new pq_Opportunity_Effectiveness_Index__c(
            Rolling_Serialized_Lost_Data__c = '{"Business User":27,"Decision Maker":10,"Influencer":32}',
            Rolling_Serialized_Won_Data__c = '{"Decision Maker":43,"Influencer":36,"Business User":31}',
            Rolling_Total_Lost__c = 12,
            Rolling_Total_Won__c = 18,
            Rolling_Total_Won_With_Contact__c = 20,
            Rolling_Total_Lost_With_Contact__c = 24
        );

        OpportunityEffectivenessData result = OpportunityEffectivenessData.convertForRollingData(input);

        System.assertNotEquals(null, result);
        System.assertEquals(12, result.totalLost);
        System.assertEquals(18, result.totalWon);
        System.assertEquals(20, result.wonWithContact);
        System.assertEquals(24, result.lostWithContact);

        System.assertNotEquals(null, result.lostMap);
        System.assertNotEquals(null, result.wonMap);

        System.assertEquals(27, result.lostMap.get('Business User'));
        System.assertEquals(10, result.lostMap.get('Decision Maker'));
        System.assertEquals(32, result.lostMap.get('Influencer'));
        System.assertEquals(43, result.wonMap.get('Decision Maker'));
        System.assertEquals(36, result.wonMap.get('Influencer'));
        System.assertEquals(31, result.wonMap.get('Business User'));
    }
}