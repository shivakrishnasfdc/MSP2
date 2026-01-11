@isTest
private class WSSummaryFormulaSelectorTest {
    @isTest
    static void selectByIdTest() {
        // Given
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('PlanA', testAccount);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');

        WS_Summary_Formula__c formula = new WS_Summary_Formula__c(
            Label__c = 'A + B',
            Formula__c = '{A} + {B}',
            Color__c = '#0080ff',
            White_Space__c = ws.Id
        );
        insert formula;

        List<WS_Summary_Formula__c> formulas = new WSSummaryFormulaSelector().selectById(new Set<Id>{ formula.Id });

        // Then
        System.assertEquals(1, formulas.size());
        System.assertEquals(formula.Id, formulas[0].Id);
    }

    @isTest
    static void selectByWhiteSpaceIdTest() {
        // Given
        Account testAccount = new Account(Name = 'Account 1');
        insert testAccount;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('PlanA', testAccount);
        White_Space__c ws = TestDataFactory.createWhiteSpace(ap, 'WS Name');
        White_Space__c ws2 = TestDataFactory.createWhiteSpace(ap, 'WS 2 Name');

        // Formula with WS ID
        WS_Summary_Formula__c formula = new WS_Summary_Formula__c(
            Label__c = 'A + B',
            Formula__c = '{A} + {B}',
            Color__c = '#0080ff',
            White_Space__c = ws.Id
        );
        insert formula;

        // Formula with WS ID
        WS_Summary_Formula__c formula2 = new WS_Summary_Formula__c(
            Label__c = 'C + D',
            Formula__c = '{C} + {D}',
            Color__c = '#0080ff',
            White_Space__c = ws.Id
        );
        insert formula2;

        // Formula with no WS ID but Apply to All True
        WS_Summary_Formula__c formula3 = new WS_Summary_Formula__c(
            Label__c = 'C + D',
            Formula__c = '{C} + {D}',
            Color__c = '#0080ff',
            White_Space__c = ws2.Id,
            Apply_To_All_Cross_Sell_Maps__c = true
        );
        insert formula3;

        // Formula that should not be pulled
        WS_Summary_Formula__c formula4 = new WS_Summary_Formula__c(
            Label__c = 'C + D',
            Formula__c = '{C} + {D}',
            Color__c = '#0080ff',
            White_Space__c = ws2.Id
        );
        insert formula4;

        List<WS_Summary_Formula__c> formulas = new WSSummaryFormulaSelector().selectByWhiteSpaceId(ws.Id);
        Set<Id> ids = new Set<Id>();
        for (WS_Summary_Formula__c form : formulas) {
            ids.add(form.Id);
        }

        // Then
        System.assertEquals(3, formulas.size());
        System.assert(!ids.contains(formula4.Id));
    }
}