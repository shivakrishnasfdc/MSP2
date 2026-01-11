@isTest
private class WhiteSpaceAmountTypeSelectorTest {
    public static final String USER1_FIRST_NAME = 'admin';
    public static final String USER1_LAST_NAME = 'adam';

    public static final String USER2_FIRST_NAME = 'standard';
    public static final String USER2_LAST_NAME = 'suzie';

    public static final String USER3_FIRST_NAME = 'creator';
    public static final String USER3_LAST_NAME = 'cal';

    public static final String CRUSH_STANDARD_USER = 'CRUSH_Standard_User';
    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';
    public static final String CRUSH_ACCOUNT_PLAN_CREATOR = 'CRUSH_Account_Plan_Creator';

    public static final String STANDARD_USER = 'Standard User';

    public static final String ACTIVE_AMOUNT_TYPE_NAME = 'testActive';
    public static final String INACTIVE_AMOUNT_TYPE_NAME = 'testInactive';

    @testSetup
    static void testSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :STANDARD_USER];
        User adminAdam = TestDataFactory.createUser(USER1_FIRST_NAME, USER1_LAST_NAME, p.Id);
        User standardSuzie = TestDataFactory.createUser(USER2_FIRST_NAME, USER2_LAST_NAME, p.Id);
        User creatorCal = TestDataFactory.createUser(USER3_FIRST_NAME, USER3_LAST_NAME, p.Id);

        PermissionSet standardUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_STANDARD_USER];
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR];
        PermissionSet creatorUserPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :CRUSH_ACCOUNT_PLAN_CREATOR
        ];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = standardSuzie.Id, PermissionSetId = standardUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = adminAdam.Id, PermissionSetId = adminUserPermissionSet.Id),
            new PermissionSetAssignment(AssigneeId = creatorCal.Id, PermissionSetId = creatorUserPermissionSet.Id)
        };

        System.runAs(creatorCal) {
            TestDataFactory.createWhiteSpaceAmountType(ACTIVE_AMOUNT_TYPE_NAME);
            TestDataFactory.createWhiteSpaceAmountType(INACTIVE_AMOUNT_TYPE_NAME, false);
        }
    }

    @isTest
    private static void selectAllTest() {
        // Given
        White_Space_Amount_Type__c expectedAmountType = [
            SELECT Id, Name, IsActive__c
            FROM White_Space_Amount_Type__c
            WHERE Name = :ACTIVE_AMOUNT_TYPE_NAME
        ];
        // When
        List<White_Space_Amount_Type__c> result = new WhiteSpaceAmountTypeSelector().selectAll();

        // Then
        System.assertEquals(1, result.size());
        System.assertEquals(expectedAmountType.name, result[0].name);
        System.assertEquals(expectedAmountType.id, result[0].id);
        System.assert(result[0].IsActive__c);
    }

    @isTest
    private static void selectAllOnlyReturnsActiveRecordsTest() {
        // Given
        White_Space_Amount_Type__c amountType = [
            SELECT Id, Name, IsActive__c
            FROM White_Space_Amount_Type__c
            WHERE Name = :ACTIVE_AMOUNT_TYPE_NAME
        ];
        amountType.IsActive__c = false;
        update amountType;
        // When
        List<White_Space_Amount_Type__c> result = new WhiteSpaceAmountTypeSelector().selectAll();

        // Then
        System.assertEquals(0, result.size());
    }

    @isTest
    private static void selectByIdOnlyReturnsActiveRecordsTest() {
        // Given
        Set<Id> amountTypeIds = new Map<Id, White_Space_Amount_Type__c>(
                (List<White_Space_Amount_Type__c>) [SELECT Id FROM White_Space_Amount_Type__c]
            )
            .keySet();

        // When
        List<White_Space_Amount_Type__c> result = new WhiteSpaceAmountTypeSelector().selectById(amountTypeIds);

        // Then
        System.assertEquals(1, result.size());
        System.assertEquals(ACTIVE_AMOUNT_TYPE_NAME, result[0].name);
        System.assert(result[0].IsActive__c);
    }

    @isTest
    private static void selectInactiveReturnsInactiveActiveRecordsTest() {
        // When
        List<White_Space_Amount_Type__c> result = new WhiteSpaceAmountTypeSelector().selectInactive();

        // Then
        System.assertEquals(1, result.size());
        System.assertEquals(INACTIVE_AMOUNT_TYPE_NAME, result[0].name);
    }
}