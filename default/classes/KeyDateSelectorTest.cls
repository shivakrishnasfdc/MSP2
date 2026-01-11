@isTest
private class KeyDateSelectorTest {
    public static final String ON_THE_DAY_OF = 'On the day of';
    public static final String ONE_DAY_BEFORE = '1 day before';
    public static final String TWO_DAYS_BEFORE = '2 days before';
    public static final String ONE_WEEK_BEFORE = '1 week before';
    public static final String TWO_WEEKS_BEFORE = '2 weeks before';

    private static final String ACCOUNT_PLAN_NAME = 'Account Plan 1';
    private static final String KEY_DATE_NAME = 'Deets';
    private static final String KEY_DATE2_NAME = 'Beets';

    private static final String USER_LAST_NAME = 'Smith';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User admin = TestDataFactory.createUser('user', USER_LAST_NAME, standardProfile.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CRUSH_Administrator'];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminUserPermissionSet.Id)
        };

        System.runAs(admin) {
            Account testAccount = new Account(Name = 'Account 1');
            insert testAccount;

            AccountPlans.bypassEmailTrigger = true;
            KeyDates.bypassEmailTrigger = true;
            Account_Plan__c accountPlan = TestDataFactory.createAccountPlan(ACCOUNT_PLAN_NAME, testAccount);
            Key_Date__c keyDate = TestDataFactory.createKeyDate(accountPlan, KEY_DATE_NAME);
            insert keyDate;
        }
    }

    @isTest
    static void selectByIdTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER_LAST_NAME LIMIT 1];

        System.runAs(admin) {
            // Given
            Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
            Key_Date__c keyDate = [
                SELECT Id, Name, Account_Plan__c, Date__c
                FROM Key_Date__c
                WHERE Account_Plan__c = :accountPlan.Id AND Name = :KEY_DATE_NAME
            ];

            // When
            Test.startTest();

            List<Key_Date__c> retrievedKeyDates = KeyDateSelector.newInstance().selectById(new Set<Id>{ keyDate.Id });

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedKeyDates.size());
            System.assertEquals(keyDate.Id, retrievedKeyDates.get(0).Id);
            System.assertEquals(keyDate.Account_Plan__c, retrievedKeyDates.get(0).Account_Plan__c);
            System.assertEquals(keyDate.Date__c, retrievedKeyDates.get(0).Date__c);
            System.assertEquals(keyDate.Name, retrievedKeyDates.get(0).Name);
        }
    }

    @isTest
    static void selectByAccountPlanIdTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER_LAST_NAME LIMIT 1];

        System.runAs(admin) {
            // Given
            Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
            Key_Date__c keyDate = [
                SELECT Id, Name, Account_Plan__c, Date__c
                FROM Key_Date__c
                WHERE Account_Plan__c = :accountPlan.Id AND Name = :KEY_DATE_NAME
            ];

            // When
            Test.startTest();

            List<Key_Date__c> retrievedKeyDates = KeyDateSelector.newInstance()
                .selectByAccountPlanId(new Set<Id>{ accountPlan.Id });

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedKeyDates.size());
            System.assertEquals(keyDate.Id, retrievedKeyDates.get(0).Id);
            System.assertEquals(keyDate.Account_Plan__c, retrievedKeyDates.get(0).Account_Plan__c);
            System.assertEquals(keyDate.Date__c, retrievedKeyDates.get(0).Date__c);
            System.assertEquals(keyDate.Name, retrievedKeyDates.get(0).Name);
        }
    }

    @isTest
    static void selectWithRemindersBetweenTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :USER_LAST_NAME LIMIT 1];

        System.runAs(admin) {
            KeyDates.bypassEmailTrigger = true;
            Account_Plan__c accountPlan = [SELECT Id FROM Account_Plan__c WHERE Name = :ACCOUNT_PLAN_NAME];
            Key_Date__c keyDate2 = TestDataFactory.createKeyDate(
                accountPlan,
                KEY_DATE2_NAME,
                Date.today().addDays(2),
                ''
            );
            insert keyDate2;
            Key_Date__c keyDate3 = TestDataFactory.createKeyDate(
                accountPlan,
                KEY_DATE2_NAME,
                Date.today().addDays(10),
                ON_THE_DAY_OF
            );
            insert keyDate3;
            Key_Date__c keyDate4 = TestDataFactory.createKeyDate(
                accountPlan,
                KEY_DATE2_NAME,
                Date.today().addDays(40),
                ON_THE_DAY_OF
            );
            insert keyDate4;
            Key_Date__c keyDate5 = TestDataFactory.createKeyDate(
                accountPlan,
                KEY_DATE2_NAME,
                Date.today().addDays(50),
                ON_THE_DAY_OF
            );
            insert keyDate5;

            Date fromDate = Date.today();
            Date toDate = fromDate.addDays(15);

            // When
            Test.startTest();

            List<Key_Date__c> retrievedKeyDates = KeyDateSelector.newInstance()
                .selectWithRemindersBetween(fromDate, toDate);

            Test.stopTest();

            // Then
            System.assertEquals(1, retrievedKeyDates.size());
        }
    }
}