@isTest
private class EventWrapperTest {
    @isTest
    static void eventTest() {
        Id eId = fflib_IDGenerator.generate(Event.SObjectType);

        String subject = 'abc';
        String description = 'abc';
        Datetime activityDateTime = Date.today();
        Datetime startDateTime = Date.today();
        Datetime endDateTime = Date.today().addDays(10);
        Id ownerId = fflib_IDGenerator.generate(User.SObjectType);
        String ownerName = 'me';
        Id whatId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id whoId = fflib_IDGenerator.generate(Contact.SObjectType);
        String whoName = 'me';
        String type = '';
        String eventSubType = '';

        EventWrapper wrapper = new EventWrapper(
            eId,
            type,
            eventSubType,
            subject,
            description,
            activityDateTime,
            startDateTime,
            endDateTime,
            ownerId,
            ownerName,
            whatId,
            whoId,
            whoName
        );

        System.assertEquals(eId, wrapper.id);
        System.assertEquals(type, wrapper.type);
        System.assertEquals(eventSubType, wrapper.eventSubType);
        System.assertEquals(subject, wrapper.subject);
        System.assertEquals(description, wrapper.description);
        System.assertEquals(activityDateTime, wrapper.activityDateTime);
        System.assertEquals(startDateTime, wrapper.startDateTime);
        System.assertEquals(startDateTime, wrapper.startDateTime);
        System.assertEquals(ownerId, wrapper.ownerId);
        System.assertEquals(ownerName, wrapper.ownerName);
        System.assertEquals(whatId, wrapper.whatId);
        System.assertEquals(whoId, wrapper.whoId);
        System.assertEquals(whoName, wrapper.whoName);
    }

    @isTest
    static void convertTest() {
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

        Event e1 = [
            SELECT
                Id,
                Subject,
                Description,
                OwnerId,
                Owner.Name,
                Type,
                EventSubType,
                ActivityDateTime,
                StartDateTime,
                EndDateTime,
                WhatId,
                WhoId,
                Who.Name
            FROM Event
            WHERE Id = :ev1.Id
        ];
        Event e2 = [
            SELECT
                Id,
                Subject,
                Description,
                OwnerId,
                Owner.Name,
                Type,
                EventSubType,
                ActivityDateTime,
                StartDateTime,
                EndDateTime,
                WhatId,
                WhoId,
                Who.Name
            FROM Event
            WHERE Id = :ev2.Id
        ];

        List<EventWrapper> result = EventWrapper.convert(new List<Event>{ e1, e2 });
        System.assertEquals(2, result.size());

        System.assertEquals(e1.Id, result[0].id);
        System.assertEquals(s1, result[0].subject);
        System.assertEquals(e1d1, result[0].startDateTime);
        System.assertEquals(e1d2, result[0].endDateTime);
        System.assertEquals('FirstName LastName', result[0].ownerName);

        System.assertEquals(e2.Id, result[1].id);
        System.assertEquals(s2, result[1].subject);
        System.assertEquals(e2d1, result[1].startDateTime);
        System.assertEquals(e2d2, result[1].endDateTime);
        System.assertEquals('FirstName LastName', result[1].ownerName);
    }

    @isTest
    static void convertNullTest() {
        List<EventWrapper> result = EventWrapper.convert(null);
        System.assertEquals(0, result.size());
    }
}