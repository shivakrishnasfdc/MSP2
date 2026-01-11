@isTest
private class OpportunityListUserFilterSelectorTest {
    @isTest
    static void selectByAcountPlanAndUser() {
        // Given
        Id userId = UserInfo.getUserId();
        Account acct = new Account(Name = 'Account 1');
        insert acct;
        Account_Plan__c ap = TestDataFactory.createAccountPlan('planA', acct);

        Opportunity_List_User_Filter__c filter = new Opportunity_List_User_Filter__c(
            User__c = userId,
            AccountPlan__c = ap.id
        );
        insert filter;

        // When
        List<Opportunity_List_User_Filter__c> filters = new OpportunityListUserFilterSelector()
            .selectByAccountPlanAndUser(ap.id, userId);

        System.assertEquals(1, filters.size());
    }
}