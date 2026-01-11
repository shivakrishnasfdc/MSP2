@isTest
private class RMSvgSelectorTest {
    @isTest
    static void newInstanceTest() {
        RMSvgSelector selector = RMSvgSelector.newInstance();
        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');
        Set<Id> svgIdSet = new Set<Id>{ svg1.Id, svg2.Id };

        Test.startTest();
        List<RM_Svg__c> result = new RMSvgSelector().selectById(svgIdSet);
        Test.stopTest();

        // Then the admin user should get back all three account plans
        System.assertEquals(2, result.size());
        for (RM_Svg__c rmSvg : result) {
            System.assert(svgIdSet.contains(rmSvg.Id));
        }
    }

    @isTest
    static void selectByRelationshipMapsTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('my plan');

        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('mymap');
        rm.Type_Setting__c = 'pqcrush__Account_Plan__c';
        rm.pq_AccountPlanId__c = ap.Id;

        Relationship_Map__c rm2 = TestDataFactory.createRelationshipMap('mymap2');

        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');
        RM_Svg__c svg3 = TestDataFactory.createRMSvg('test3');

        TestDataFactory.createRMSvgMapAssociation(rm, svg1);
        TestDataFactory.createRMSvgAccountPlanAssociation(ap, svg3);
        TestDataFactory.createRMSvgMapAssociation(rm2, svg2);

        Test.startTest();
        List<RM_Svg__c> result = new RMSvgSelector().selectByRelationshipMaps(new Set<Id>{ rm.Id }, true, ap.Id);
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assert(svg1.Id == result[0].Id || svg3.Id == result[0].Id);
        System.assert(svg3.Id == result[1].Id || svg3.Id == result[1].Id);
    }

    @isTest
    static void selectByAccountPlansTest() {
        Application.bypassTrigger = true;
        Account newAccount = TestDataFactory.createAccount('testAccount');
        Account_Plan__c plan = TestDataFactory.createAccountPlan('myplan', newAccount);
        Account_Plan__c plan2 = TestDataFactory.createAccountPlan('myplan2', newAccount);

        RM_Svg__c svg1 = TestDataFactory.createRMSvg('test1');
        RM_Svg__c svg2 = TestDataFactory.createRMSvg('test2');
        RM_Svg__c svg3 = TestDataFactory.createRMSvg('test3');

        TestDataFactory.createRMSvgAccountPlanAssociation(plan, svg1);
        TestDataFactory.createRMSvgAccountPlanAssociation(plan, svg3);
        TestDataFactory.createRMSvgAccountPlanAssociation(plan2, svg2);

        Test.startTest();
        List<RM_Svg__c> result = new RMSvgSelector().selectByAccountPlans(new Set<Id>{ plan.Id });
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assert(svg1.Id == result[0].Id || svg3.Id == result[0].Id);
        System.assert(svg3.Id == result[1].Id || svg3.Id == result[1].Id);
    }
}