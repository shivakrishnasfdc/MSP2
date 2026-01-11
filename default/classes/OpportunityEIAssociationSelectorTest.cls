@isTest
private class OpportunityEIAssociationSelectorTest {
    @isTest
    static void newInstanceTest() {
        OpportunityEIAssociationSelector selector = OpportunityEIAssociationSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByOpportunitiesTest() {

        Opportunity opp1 = new Opportunity(
            Name = 'Opp1',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        Opportunity opp2 = new Opportunity(
            Name = 'Opp2',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        insert new List<Opportunity>{ opp1, opp2 };
        
        pq_Opportunity_Effectiveness_Index__c index1 = new pq_Opportunity_Effectiveness_Index__c(
            Serialized_Lost_Data__c = '',
            Serialized_Won_Data__c = '',
            Total_Lost__c = 1,
            Total_Won__c = 2,
            Total_Won_With_Contact__c = 3,
            Total_Lost_With_Contact__c = 4
        );

        pq_Opportunity_Effectiveness_Index__c index2 = new pq_Opportunity_Effectiveness_Index__c(
            Serialized_Lost_Data__c = '',
            Serialized_Won_Data__c = '',
            Total_Lost__c = 12,
            Total_Won__c = 18,
            Total_Won_With_Contact__c = 20,
            Total_Lost_With_Contact__c = 24
        );

        insert new List<pq_Opportunity_Effectiveness_Index__c>{ index1, index2 };

        pq_Opportunity_Effectiveness_Association__c assoc1 = new pq_Opportunity_Effectiveness_Association__c(
            Opportunity_Effectiveness_Index__c = index1.Id,
            Opportunity__c = opp1.Id
        );

        pq_Opportunity_Effectiveness_Association__c assoc2 = new pq_Opportunity_Effectiveness_Association__c(
            Opportunity_Effectiveness_Index__c = index2.Id,
            Opportunity__c = opp2.Id
        );

        insert new List<pq_Opportunity_Effectiveness_Association__c>{ assoc1, assoc2 };


        List<pq_Opportunity_Effectiveness_Association__c> result =  OpportunityEIAssociationSelector.newInstance().selectByOpportunities(new Set<Id>{ opp1.Id });
        System.assertEquals(1, result.size());
        System.assertEquals(opp1.Id, result[0].Opportunity__c);
        System.assertEquals(index1.Id, result[0].Opportunity_Effectiveness_Index__c);
    }

    @isTest
    static void selectByOEITest() {

        Opportunity opp1 = new Opportunity(
            Name = 'Opp1',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        Opportunity opp2 = new Opportunity(
            Name = 'Opp2',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        insert new List<Opportunity>{ opp1, opp2 };
        
        pq_Opportunity_Effectiveness_Index__c index1 = new pq_Opportunity_Effectiveness_Index__c(
            Serialized_Lost_Data__c = '',
            Serialized_Won_Data__c = '',
            Total_Lost__c = 1,
            Total_Won__c = 2,
            Total_Won_With_Contact__c = 3,
            Total_Lost_With_Contact__c = 4
        );

        pq_Opportunity_Effectiveness_Index__c index2 = new pq_Opportunity_Effectiveness_Index__c(
            Serialized_Lost_Data__c = '',
            Serialized_Won_Data__c = '',
            Total_Lost__c = 12,
            Total_Won__c = 18,
            Total_Won_With_Contact__c = 20,
            Total_Lost_With_Contact__c = 24
        );

        insert new List<pq_Opportunity_Effectiveness_Index__c>{ index1, index2 };

        pq_Opportunity_Effectiveness_Association__c assoc1 = new pq_Opportunity_Effectiveness_Association__c(
            Opportunity_Effectiveness_Index__c = index1.Id,
            Opportunity__c = opp1.Id
        );

        pq_Opportunity_Effectiveness_Association__c assoc2 = new pq_Opportunity_Effectiveness_Association__c(
            Opportunity_Effectiveness_Index__c = index2.Id,
            Opportunity__c = opp2.Id
        );

        insert new List<pq_Opportunity_Effectiveness_Association__c>{ assoc1, assoc2 };


        List<pq_Opportunity_Effectiveness_Association__c> result =  OpportunityEIAssociationSelector.newInstance().selectByOEI(new Set<Id>{ index2.Id });
        System.assertEquals(1, result.size());
        System.assertEquals(opp2.Id, result[0].Opportunity__c);
        System.assertEquals(index2.Id, result[0].Opportunity_Effectiveness_Index__c);
    }
}