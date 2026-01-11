@isTest
private class SettingServiceTest {
    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'Create';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };
    }

    @isTest
    static void getOrgSettingsWithoutCreateTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // Given
            CRUSH_Settings_Obj__c existingOrgSettings = new CRUSH_Settings_Obj__c(Type__c = 'Org');
            insert existingOrgSettings;

            // When
            CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();

            // Then
            System.assertEquals('Org', orgSettings.Type__c);
        }
    }

    @isTest
    static void getOrgSettingsWithCreateTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            CRUSH_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();

            // Then
            System.assertEquals('Org', orgSettings.Type__c);
        }
    }

    @isTest
    static void getCurrentUserSettingsWithExistingObj() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // Given
            CRUSH_Settings_Obj__c existingUserSettings = new CRUSH_Settings_Obj__c(
                User__c = adminUser.id,
                Type__c = 'User'
            );
            insert existingUserSettings;

            // When
            CRUSH_Settings_Obj__c userSettings = SettingService.getCurrentUserSettings();

            // Then
            System.assertEquals('User', userSettings.Type__c);
            System.assertEquals(adminUser.id, userSettings.User__c);
            System.assertEquals(existingUserSettings.id, userSettings.id);
        }
    }

    @isTest
    static void getCurrentUserSettingsWithoutExistingObj() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            CRUSH_Settings_Obj__c userSettings = SettingService.getCurrentUserSettings();

            // Then
            System.assertEquals('User', userSettings.Type__c);
            System.assertEquals(adminUser.id, userSettings.User__c);
            System.assertEquals(null, userSettings.id);
        }
    }

    @isTest
    static void getUserSettingsWithExistingObj() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // Given
            CRUSH_Settings_Obj__c existingUserSettings = new CRUSH_Settings_Obj__c(
                User__c = adminUser.id,
                Type__c = 'User'
            );
            insert existingUserSettings;

            // When
            CRUSH_Settings_Obj__c userSettings = SettingService.getUserSettings(adminUser.id);

            // Then
            System.assertEquals('User', userSettings.Type__c);
            System.assertEquals(adminUser.id, userSettings.User__c);
            System.assertEquals(existingUserSettings.id, userSettings.id);
        }
    }

    @isTest
    static void getUserSettingsWithoutExistingObj() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            CRUSH_Settings_Obj__c userSettings = SettingService.getUserSettings(adminUser.id);

            // Then
            System.assertEquals('User', userSettings.Type__c);
            System.assertEquals(adminUser.id, userSettings.User__c);
            System.assertEquals(null, userSettings.id);
        }
    }

    @isTest
    static void udpateSettingsNullTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            try {
                SettingService.updateCrossSellCreateObjectSettings(null);
                System.assert(true);
            } catch (Exception e) {
                System.assert(false);
            }
        }
    }

    @isTest
    static void updateCrossSellCreateObjectSettingsTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            SettingService.updateCrossSellCreateObjectSettings(true);
            CRUSH_Settings_Obj__c setting = [
                SELECT Id, Can_Create_Objects_In_Cross_Sell__c
                FROM CRUSH_Settings_Obj__c
                LIMIT 1
            ];

            // Then
            System.assertEquals(true, setting.Can_Create_Objects_In_Cross_Sell__c);
        }
    }

    @isTest
    static void updateUseDefaultAPScoringSettingsTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            SettingService.updateUseDefaultAPScoringSettings(true);
            CRUSH_Settings_Obj__c setting = [
                SELECT Id, Use_Default_Account_Plan_Score__c
                FROM CRUSH_Settings_Obj__c
                LIMIT 1
            ];

            // Then
            System.assertEquals(true, setting.Use_Default_Account_Plan_Score__c);

            // When
            SettingService.updateUseDefaultAPScoringSettings(false);
            setting = [SELECT Id, Use_Default_Account_Plan_Score__c FROM CRUSH_Settings_Obj__c LIMIT 1];

            // Then
            System.assertEquals(false, setting.Use_Default_Account_Plan_Score__c);
        }
    }

    @isTest
    static void updateUsePercentageAPScoringSettingsTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            SettingService.updateUsePercentageAPScoringSettings(true);
            CRUSH_Settings_Obj__c setting = [
                SELECT Id, Use_Percentage_Account_Plan_Score__c
                FROM CRUSH_Settings_Obj__c
                LIMIT 1
            ];

            // Then
            System.assertEquals(true, setting.Use_Percentage_Account_Plan_Score__c);

            // When
            SettingService.updateUsePercentageAPScoringSettings(false);
            setting = [SELECT Id, Use_Percentage_Account_Plan_Score__c FROM CRUSH_Settings_Obj__c LIMIT 1];

            // Then
            System.assertEquals(false, setting.Use_Percentage_Account_Plan_Score__c);
        }
    }

    @isTest
    static void updateAllowAddTaskFromObjectiveComponentTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            SettingService.updateAllowAddTaskFromObjectiveComponent(true);
            CRUSH_Settings_Obj__c setting = [
                SELECT Id, Allow_Add_Tasks_From_Objective_Component__c
                FROM CRUSH_Settings_Obj__c
                LIMIT 1
            ];

            // Then
            System.assertEquals(true, setting.Allow_Add_Tasks_From_Objective_Component__c);

            // When
            SettingService.updateAllowAddTaskFromObjectiveComponent(false);
            setting = [SELECT Id, Allow_Add_Tasks_From_Objective_Component__c FROM CRUSH_Settings_Obj__c LIMIT 1];

            // Then
            System.assertEquals(false, setting.Allow_Add_Tasks_From_Objective_Component__c);
        }
    }

    @isTest
    static void updateAllowTasksBasedObjStageFromObjectiveComponentTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            SettingService.updateAllowTasksBasedObjStageFromObjectiveComponent(true);
            CRUSH_Settings_Obj__c setting = [
                SELECT Id, Enable_Objective_Stage_Based_On_Tasks__c
                FROM CRUSH_Settings_Obj__c
                LIMIT 1
            ];

            // Then
            System.assertEquals(true, setting.Enable_Objective_Stage_Based_On_Tasks__c);

            // When
            SettingService.updateAllowTasksBasedObjStageFromObjectiveComponent(false);
            setting = [SELECT Id, Enable_Objective_Stage_Based_On_Tasks__c FROM CRUSH_Settings_Obj__c LIMIT 1];

            // Then
            System.assertEquals(false, setting.Enable_Objective_Stage_Based_On_Tasks__c);
        }
    }

    @isTest
    static void updateUseSystemTaskModalFromObjectiveComponentTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            SettingService.updateUseSystemTaskModalFromObjectiveComponent(true);
            CRUSH_Settings_Obj__c setting = [
                SELECT Id, Use_System_Create_Task_Modal__c
                FROM CRUSH_Settings_Obj__c
                LIMIT 1
            ];

            // Then
            System.assertEquals(true, setting.Use_System_Create_Task_Modal__c);

            // When
            SettingService.updateUseSystemTaskModalFromObjectiveComponent(false);
            setting = [SELECT Id, Use_System_Create_Task_Modal__c FROM CRUSH_Settings_Obj__c LIMIT 1];

            // Then
            System.assertEquals(false, setting.Use_System_Create_Task_Modal__c);
        }
    }

    @isTest
    static void updateWSFilterStringSettingNullTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // When
            SettingService.updateWSFilterStringSetting(null);
            CRUSH_Settings_Obj__c setting = [SELECT Id, WS_Object_Filter__c FROM CRUSH_Settings_Obj__c LIMIT 1];

            // Then
            System.assertEquals(null, setting.WS_Object_Filter__c, 'Saved filter string should be null');
        }
    }

    @isTest
    static void updateWSFilterStringSettingValueTest() {
        User adminUser = [SELECT Id FROM User WHERE LastName = :ADMIN_USER_LAST_NAME];
        System.runAs(adminUser) {
            // Given
            String filterString = 'Account\nContact\nOpportunity';

            // When
            SettingService.updateWSFilterStringSetting(filterString);
            CRUSH_Settings_Obj__c setting = [SELECT Id, WS_Object_Filter__c FROM CRUSH_Settings_Obj__c LIMIT 1];

            // Then
            System.assertEquals(filterString, setting.WS_Object_Filter__c, 'Saved filter string should match input');
        }
    }

    @isTest
    static void getObjectNameListFromFilterStringTest() {
        //Null test
        List<String> result = SettingService.getObjectNameListFromFilterString(null);
        System.assertEquals(0, result.size());

        //Empty string test
        result = SettingService.getObjectNameListFromFilterString('');
        System.assertEquals(0, result.size());

        //Single object test untrimmed
        result = SettingService.getObjectNameListFromFilterString('  Account  ');
        System.assertEquals(1, result.size());
        System.assertEquals('Account', result[0]);

        //Multiple object test
        result = SettingService.getObjectNameListFromFilterString('  Account\n Contact\n Opportunity  ');
        System.assertEquals(3, result.size());
        System.assertEquals('Account', result[0]);
        System.assertEquals('Contact', result[1]);
        System.assertEquals('Opportunity', result[2]);

        //Multiple Object unordered test
        result = SettingService.getObjectNameListFromFilterString('  Opportunity\n Contact\n Account  ');
        System.assertEquals(3, result.size());
        System.assertEquals('Account', result[0]);
        System.assertEquals('Contact', result[1]);
        System.assertEquals('Opportunity', result[2]);
    }

    @isTest
    static void getFilterStringFromObjectNameListTest() {
        //Null test
        String result = SettingService.getFilterStringFromObjectNameList(null);
        System.assertEquals(null, result);

        //Empty list test
        result = SettingService.getFilterStringFromObjectNameList(new List<String>());
        System.assertEquals(null, result);

        //List with empty values test
        result = SettingService.getFilterStringFromObjectNameList(new List<String>{ '', '  ' });
        System.assertEquals(null, result);

        //Single object test
        result = SettingService.getFilterStringFromObjectNameList(new List<String>{ '  Account  ' });
        System.assertEquals('Account', result);

        //Multiple object test
        result = SettingService.getFilterStringFromObjectNameList(
            new List<String>{ 'Account  ', ' Contact', '   Opportunity' }
        );
        System.assertEquals('Account\nContact\nOpportunity', result);

        //Multiple Object unordered test
        result = SettingService.getFilterStringFromObjectNameList(
            new List<String>{ 'Opportunity', 'Contact', 'Account' }
        );
        System.assertEquals('Account\nContact\nOpportunity', result);
    }
}