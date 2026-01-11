@isTest
private class ScheduleEmailKeyDateReminderBatchTest {
    public static final String USER_FIRST_NAME = 'user';
    public static final String USER_LAST_NAME = 'Standard1';

    public static final String ADMIN_PERMISSION = 'CRUSH_Administrator';
    public static final String ACCOUNT_PLAN1_NAME = 'Account Plan 1 Name';

    public static final String KEY_DATE1_NAME = 'Key Date 1';
    public static final String KEY_DATE_REMINDER_TEMPLATE_NAME = 'Key_Date_Reminder';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User admin = TestDataFactory.createUser(USER_FIRST_NAME, USER_LAST_NAME, standardProfile.Id);

        PermissionSet adminPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :ADMIN_PERMISSION];

        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminPermissionSet.Id)
        };
        insert permissionSets;

        System.runAs(admin) {
            Account a = new Account(Name = 'Account 1');
            insert a;

            Account_Plan__c accountPlan1 = TestDataFactory.createAccountPlan(ACCOUNT_PLAN1_NAME, a);
            TestDataFactory.createKeyDate(accountPlan1, KEY_DATE1_NAME, Date.today().addDays(1));
        }
    }

    @isTest
    static void scheduleKeyDateReminderNoDatesTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        List<Key_Date__c> keyDates = new List<Key_Date__c>();

        Date today = Date.today();
        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderOnDayOfTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Date today = Date.today();

        List<Key_Date__c> keyDates = new List<Key_Date__c>{
            new Key_Date__c(Date__c = today, Reminder__c = ScheduleEmailKeyDateReminderBatch.ON_THE_DAY_OF)
        };

        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 1))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderOnDayOfNegativeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Date today = Date.today();

        List<Key_Date__c> keyDates = new List<Key_Date__c>{
            new Key_Date__c(Date__c = today.addDays(2), Reminder__c = ScheduleEmailKeyDateReminderBatch.ON_THE_DAY_OF)
        };

        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderOneDayBeforeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Date today = Date.today();

        List<Key_Date__c> keyDates = new List<Key_Date__c>{
            new Key_Date__c(Date__c = today.addDays(1), Reminder__c = ScheduleEmailKeyDateReminderBatch.ONE_DAY_BEFORE)
        };

        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 1))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderOneDayBeforeNegativeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(5),
            ScheduleEmailKeyDateReminderBatch.ONE_DAY_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate };

        Date today = Date.today();
        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderTwoDaysBeforeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(2),
            ScheduleEmailKeyDateReminderBatch.TWO_DAYS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate };

        Date today = Date.today();
        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 1))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderTwoDaysBeforeNegativeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate1 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(5),
            ScheduleEmailKeyDateReminderBatch.TWO_DAYS_BEFORE
        );
        Key_Date__c keyDate2 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(1),
            ScheduleEmailKeyDateReminderBatch.TWO_DAYS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate1, keyDate2 };

        Date today = Date.today();
        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderOneWeekBeforeBeforeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(7),
            ScheduleEmailKeyDateReminderBatch.ONE_WEEK_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate };

        Date today = Date.today();
        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 1))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderOneWeekBeforeBeforeNegativeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate1 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(5),
            ScheduleEmailKeyDateReminderBatch.ONE_WEEK_BEFORE
        );
        Key_Date__c keyDate2 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(10),
            ScheduleEmailKeyDateReminderBatch.ONE_WEEK_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate1, keyDate2 };

        Date today = Date.today();
        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderTwoWeeksBeforeBeforeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(14),
            ScheduleEmailKeyDateReminderBatch.TWO_WEEKS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate };

        Date today = Date.today();
        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 1))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderTwoWeeksBeforeBeforeNegativeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate1 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(5),
            ScheduleEmailKeyDateReminderBatch.TWO_WEEKS_BEFORE
        );
        Key_Date__c keyDate2 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(20),
            ScheduleEmailKeyDateReminderBatch.TWO_WEEKS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate1, keyDate2 };

        Date today = Date.today();
        Date twoWeeksFromNow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, twoWeeksFromNow)).thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderThirtyDaysBeforeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(30),
            ScheduleEmailKeyDateReminderBatch.THIRTY_DAYS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate };

        Date today = Date.today();
        Date ninetydaysfromnow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, ninetydaysfromnow))
            .thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 1))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderThirtyDaysBeforeNegativeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate1 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(5),
            ScheduleEmailKeyDateReminderBatch.THIRTY_DAYS_BEFORE
        );
        Key_Date__c keyDate2 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(40),
            ScheduleEmailKeyDateReminderBatch.THIRTY_DAYS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate1, keyDate2 };

        Date today = Date.today();
        Date ninetydaysfromnow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, ninetydaysfromnow))
            .thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderSixtyDaysBeforeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(60),
            ScheduleEmailKeyDateReminderBatch.SIXTY_DAYS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate };

        Date today = Date.today();
        Date ninetydaysfromnow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, ninetydaysfromnow))
            .thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 1))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderSixtyDaysBeforeNegativeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate1 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(5),
            ScheduleEmailKeyDateReminderBatch.SIXTY_DAYS_BEFORE
        );
        Key_Date__c keyDate2 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(40),
            ScheduleEmailKeyDateReminderBatch.SIXTY_DAYS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate1, keyDate2 };

        Date today = Date.today();
        Date ninetydaysfromnow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, ninetydaysfromnow))
            .thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderNinetyNinetyDaysBeforeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(90),
            ScheduleEmailKeyDateReminderBatch.NINETY_DAYS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate };

        Date today = Date.today();
        Date ninetydaysfromnow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, ninetydaysfromnow))
            .thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 1))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }

    @isTest
    static void scheduleKeyDateReminderNinetyDaysBeforeNegativeTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SendEmailNotificationsImpl mockSendEmailService = (SendEmailNotificationsImpl) mocks.mock(
            SendEmailNotificationsImpl.class
        );
        KeyDateSelector mockKeyDateSelector = (KeyDateSelector) FFLibHelper.mockSelector(KeyDateSelector.class, mocks);

        Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailService);
        Application.Selector.setMock(mockKeyDateSelector);

        Account_Plan__c accountPlan1 = [SELECT Id FROM Account_Plan__c LIMIT 1];
        Key_Date__c keyDate1 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(5),
            ScheduleEmailKeyDateReminderBatch.NINETY_DAYS_BEFORE
        );
        Key_Date__c keyDate2 = TestDataFactory.createKeyDate(
            accountPlan1,
            KEY_DATE1_NAME,
            Date.today().addDays(40),
            ScheduleEmailKeyDateReminderBatch.NINETY_DAYS_BEFORE
        );

        List<Key_Date__c> keyDates = new List<Key_Date__c>{ keyDate1, keyDate2 };

        Date today = Date.today();
        Date ninetydaysfromnow = today.addDays(ScheduleEmailKeyDateReminderBatch.DAYSTOPULL);

        mocks.startStubbing();
        mocks.when(mockKeyDateSelector.selectWithRemindersBetweenAsSystem(today, ninetydaysfromnow))
            .thenReturn(keyDates);
        mocks.stopStubbing();

        // When
        Test.startTest();
        Database.executeBatch(new ScheduleEmailKeyDateReminderBatch());
        Test.stopTest();

        // Then
        try {
            ((SendEmailNotificationsImpl) mocks.verify(mockSendEmailService, 0))
                .sendReminderEmails(keyDates, KEY_DATE_REMINDER_TEMPLATE_NAME);
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
    }
}