@isTest
private class EventSelectorTest {
    @isTest
    static void newInstanceTest() {
        EventSelector selector = EventSelector.newInstance();

        System.assertNotEquals(null, selector);
    }

    @isTest
    static void selectByIdTest() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User someUser = TestDataFactory.createUser('FirstName', 'LastName', standardProfile.Id);

        Date e1d1 = Date.today();
        Date e1d2 = e1d1.addDays(7);
        Date e2d1 = e1d1.addDays(-4);
        Date e2d2 = e1d1.addDays(3);

        String s1 = 'Event 1';
        String s2 = 'Event 2';

        Event ev1 = new Event(Subject = s1, OwnerId = someUser.Id, StartDateTime = e1d1, EndDateTime = e1d2);
        insert ev1;
        Event ev2 = new Event(Subject = s2, OwnerId = someUser.Id, StartDateTime = e2d1, EndDateTime = e2d2);
        insert ev2;

        List<Event> result = EventSelector.newInstance().selectById(new Set<Id>{ ev1.Id, ev2.Id });
        System.assertEquals(2, result.size());
    }

    @isTest
    static void selectByWhatIdTest() {
        Account_Plan__c ap = TestDataFactory.createAccountPlan('Plan Name');
        Objective__c obj = new Objective__c(Name = 'obj test', Account_Plan__c = ap.Id);
        insert obj;

        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User someUser = TestDataFactory.createUser('FirstName', 'LastName', standardProfile.Id);

        Date e1d1 = Date.today();
        Date e1d2 = e1d1.addDays(7);
        Date e2d1 = e1d1.addDays(-4);
        Date e2d2 = e1d1.addDays(3);

        String s1 = 'Event 1';
        String s2 = 'Event 2';

        Event ev1 = new Event(
            Subject = s1,
            WhatId = obj.Id,
            OwnerId = someUser.Id,
            StartDateTime = e1d1,
            EndDateTime = e1d2
        );
        insert ev1;
        Event ev2 = new Event(
            Subject = s2,
            WhatId = obj.Id,
            OwnerId = someUser.Id,
            StartDateTime = e2d1,
            EndDateTime = e2d2
        );
        insert ev2;

        List<Event> result = EventSelector.newInstance().selectByWhatId(new Set<Id>{ obj.Id }, true, 2);
        System.assertEquals(2, result.size());
    }
}