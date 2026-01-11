@IsTest
private class ContinueDMLTest {
    private static final String ADMIN_LASTNAME = 'cdmltAdmin';
    private static final String USER_LASTNAME = 'cdmltUser';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String STANDARD_USER = 'Standard User';

    @testSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];

        User admin = TestDataFactory.createUser('User', ADMIN_LASTNAME, p.Id);
        TestDataFactory.createUser('User', USER_LASTNAME, p.Id);

        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];

        insert new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetId = adminUserPermissionSet.Id);
    }

    @IsTest
    private static void initializerTest() {
        ContinueDML result = new ContinueDML();
        System.assertNotEquals(null, result);
        System.assertEquals(false, result.bypassDmlChecks);

        ContinueDML result1 = new ContinueDML(true);
        System.assertNotEquals(null, result1);
        System.assertEquals(true, result1.bypassDmlChecks);

        ContinueDML result2 = new ContinueDML(false);
        System.assertNotEquals(null, result2);
        System.assertEquals(false, result2.bypassDmlChecks);
    }

    @IsTest
    private static void dmlInsertWithoutPermsTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];
        User theUser = [SELECT Id FROM User WHERE LastName = :USER_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            )
        };

        System.runAs(theUser) {
            try {
                ContinueDML dml = new ContinueDML();
                dml.dmlInsert(plans);
            } catch (Exception e) {
                System.assert(true, 'An error should be thrown for a user without the required permissions');
            }
        }

        List<Account_Plan__c> insertedPlans = [SELECT Id FROM Account_Plan__c WHERE Account__c = :testAccount.Id];
        system.assertEquals(0, insertedPlans.size());
    }

    @IsTest
    private static void dmlInsertWithoutPermsBypassDmlTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];
        User theUser = [SELECT Id FROM User WHERE LastName = :USER_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            )
        };

        System.runAs(theUser) {
            ContinueDML dml = new ContinueDML(true);
            dml.dmlInsert(plans);
        }

        List<Account_Plan__c> insertedPlans = [SELECT Id FROM Account_Plan__c WHERE Account__c = :testAccount.Id];
        system.assertEquals(
            0,
            insertedPlans.size(),
            'No error thrown, but nothing inserted since User does not have permission'
        );
    }

    @IsTest
    private static void dmlInsertWithPermsTest() {
        User theUser = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            )
        };

        System.runAs(theUser) {
            ContinueDML dml = new ContinueDML(true);
            dml.dmlInsert(plans);
        }

        List<Account_Plan__c> insertedPlans = [SELECT Id FROM Account_Plan__c WHERE Account__c = :testAccount.Id];
        system.assertEquals(2, insertedPlans.size(), 'No error thrown and both records inserted');
    }

    @IsTest
    private static void dmlInsertWithPermsBadRecordTest() {
        User theUser = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            ),
            new Account_Plan__c()
        };

        System.runAs(theUser) {
            ContinueDML dml = new ContinueDML(true);
            dml.dmlInsert(plans);
        }

        List<Account_Plan__c> insertedPlans = [SELECT Id FROM Account_Plan__c WHERE Account__c = :testAccount.Id];
        system.assertEquals(1, insertedPlans.size(), 'No error thrown and only the good record inserted');
    }

    @IsTest
    private static void dmlUpdateWithoutPermsTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];
        User theUser = [SELECT Id FROM User WHERE LastName = :USER_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            )
        };

        System.runAs(admin) {
            insert plans;
        }

        plans[0].status__c = 'Closed';
        plans[1].status__c = 'Closed';

        System.runAs(theUser) {
            try {
                ContinueDML dml = new ContinueDML();
                dml.dmlUpdate(plans);
                System.assert(false, 'Should not hit this due to error thrown');
            } catch (Exception e) {
                System.assert(true, 'An error should be thrown for a user without the required permissions');
            }
        }
    }

    @IsTest
    private static void dmlUpdateWithoutPermsBypassDmlTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];
        User theUser = [SELECT Id FROM User WHERE LastName = :USER_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            )
        };

        System.runAs(admin) {
            insert plans;
        }

        plans[0].status__c = 'Closed';
        plans[1].status__c = 'Closed';

        System.runAs(theUser) {
            ContinueDML dml = new ContinueDML(true);
            dml.dmlUpdate(plans);
        }

        List<Account_Plan__c> expectedPlans = [
            SELECT Id
            FROM Account_Plan__c
            WHERE Account__c = :testAccount.Id AND Status__c = 'Closed'
        ];
        system.assertEquals(
            0,
            expectedPlans.size(),
            'No error should be thrown but none of the records should be updated due to lack of permission'
        );
    }

    @IsTest
    private static void dmlUpdateWithPermsTest() {
        User theUser = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            )
        };

        System.runAs(theUser) {
            insert plans;
        }

        plans[0].status__c = 'Closed';
        plans[1].status__c = 'Closed';

        System.runAs(theUser) {
            ContinueDML dml = new ContinueDML();
            dml.dmlUpdate(plans);
        }

        List<Account_Plan__c> expectedPlans = [
            SELECT Id
            FROM Account_Plan__c
            WHERE Account__c = :testAccount.Id AND Status__c = 'Closed'
        ];
        system.assertEquals(2, expectedPlans.size(), 'No error should be thrown and both plans should be updated');
    }

    @IsTest
    private static void dmlUpdateWithPermsBadRecordTest() {
        User theUser = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            )
        };

        System.runAs(theUser) {
            insert plans;
        }

        plans[0].status__c = 'Closed';
        plans[1].status__c = 'Closed';
        plans[1].Account__c = null;

        System.runAs(theUser) {
            ContinueDML dml = new ContinueDML();
            dml.dmlUpdate(plans);
        }

        List<Account_Plan__c> expectedPlans = [
            SELECT Id
            FROM Account_Plan__c
            WHERE Account__c = :testAccount.Id AND Status__c = 'Closed'
        ];
        system.assertEquals(
            1,
            expectedPlans.size(),
            'No error should be thrown and only one plan updated since the other should have invalid data'
        );
    }

    @IsTest
    private static void dmlDeleteWithoutPermsTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];
        User theUser = [SELECT Id FROM User WHERE LastName = :USER_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            )
        };

        System.runAs(admin) {
            insert plans;
        }

        System.runAs(theUser) {
            try {
                ContinueDML dml = new ContinueDML();
                dml.dmlDelete(plans);
                System.assert(false, 'Should not hit this due to error thrown');
            } catch (Exception e) {
                System.assert(true, 'An error should be thrown for a user without the required permissions');
            }
        }

        List<Account_Plan__c> insertedPlans = [SELECT Id FROM Account_Plan__c WHERE Account__c = :testAccount.Id];
        system.assertEquals(2, insertedPlans.size(), 'Both plans should still exist');
    }

    @IsTest
    private static void dmlDeleteWithoutPermsBypassDmlTest() {
        User admin = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];
        User theUser = [SELECT Id FROM User WHERE LastName = :USER_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = admin.Id
            )
        };

        System.runAs(admin) {
            insert plans;
        }

        System.runAs(theUser) {
            ContinueDML dml = new ContinueDML(true);
            dml.dmlDelete(plans);
        }

        List<Account_Plan__c> insertedPlans = [SELECT Id FROM Account_Plan__c WHERE Account__c = :testAccount.Id];
        system.assertEquals(
            2,
            insertedPlans.size(),
            'No error should be thrown but none of the records should be deleted due to lack of permission'
        );
    }

    @IsTest
    private static void dmlDeleteWithPermsTest() {
        User theUser = [SELECT Id FROM User WHERE LastName = :ADMIN_LASTNAME];

        Account testAccount = new Account(Name = 'dmlist Account');
        insert testAccount;

        List<Account_Plan__c> plans = new List<Account_Plan__c>{
            new Account_Plan__c(
                Name = 'account plan C',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            ),
            new Account_Plan__c(
                Name = 'account plan D',
                Account__c = testAccount.Id,
                Status__c = 'Open',
                OwnerId = theUser.Id
            )
        };

        System.runAs(theUser) {
            insert plans;
            ContinueDML dml = new ContinueDML();
            dml.dmlDelete(plans);
        }

        List<Account_Plan__c> expectedPlans = [SELECT Id FROM Account_Plan__c WHERE Account__c = :testAccount.Id];
        system.assertEquals(0, expectedPlans.size(), 'No error should be thrown and all records should be deleted');
    }
}