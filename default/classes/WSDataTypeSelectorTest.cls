@isTest
private class WSDataTypeSelectorTest {
    @isTest
    static void selectByIdTest() {
        // Given
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('PlanA', testAccount);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');
        White_Space__c ws2 = TestDataFactory.createWhiteSpace(ap, 'WS 2 Name');

        WS_Data_Type__c dt = new WS_Data_Type__c(
            Data_Type__c = 'Picklist',
            Picklist_Values__c = 'one',
            White_Space__c = ws.Id,
            Label__c = 'label1',
            Color__c = '#FFF'
        );
        insert dt;

        // Shouldn't return, not in queried data type set
        WS_Data_Type__c dt2 = new WS_Data_Type__c(
            Data_Type__c = 'Picklist',
            Picklist_Values__c = 'one',
            White_Space__c = ws2.Id,
            Label__c = 'label1',
            Color__c = '#FFF'
        );
        insert dt2;

        List<WS_Data_Type__c> dataTypes = new WSDataTypeSelector().selectById(new Set<Id>{ dt.Id });

        // Then
        System.assertEquals(1, dataTypes.size());
        System.assertEquals(dt.Id, dataTypes[0].Id);
    }

    @isTest
    static void selectByWhiteSpaceIdTest() {
        // Given
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('PlanA', testAccount);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');
        White_Space__c ws2 = TestDataFactory.createWhiteSpace(ap, 'WS 2  Name');

        WS_Data_Type__c dt1 = new WS_Data_Type__c(
            Data_Type__c = 'Picklist',
            Picklist_Values__c = 'one',
            White_Space__c = ws.Id,
            Label__c = 'label1',
            Color__c = '#FFF'
        );
        insert dt1;

        WS_Data_Type__c dt2 = new WS_Data_Type__c(
            Data_Type__c = 'Picklist',
            Picklist_Values__c = 'one',
            White_Space__c = null,
            Label__c = 'label1',
            Color__c = '#FFF',
            Apply_To_All_Cross_Sell_Maps__c = true
        );
        insert dt2;

        // Shouldn't return, not in queried WS
        WS_Data_Type__c dt3 = new WS_Data_Type__c(
            Data_Type__c = 'Picklist',
            Picklist_Values__c = 'one',
            White_Space__c = ws2.Id,
            Label__c = 'label1',
            Color__c = '#FFF'
        );
        insert dt3;

        List<WS_Data_Type__c> dataTypes = new WSDataTypeSelector().selectByWhiteSpaceId(ws.Id);

        // Then
        System.assertEquals(2, dataTypes.size());
    }
}