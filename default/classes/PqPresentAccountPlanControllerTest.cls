@isTest
private class PqPresentAccountPlanControllerTest {
    @isTest
    public static void getListAndImage() {
        Test.startTest();
        pqcrush__Account_Plan__c acPlan = TestDataFactory.createAccountPlan('Test');
        list<pqcrush__Account_Plan_Template__c> actemplate = TestDataFactory.createAccountPlanTemplate();
        TestDataFactory.createTemplateSection(acPlan.Id, actemplate[0].Id);
        TestDataFactory.createContentVersion('Test', acPlan.id, 'b6jhjah26763bansdsajhdsmnd6747sanxmashdhasjd67483278');
        TestDataFactory.createContentVersion(
            'Test',
            actemplate[0].id,
            'b6jhjah26763bansdsajhdsmnd6747sanxmashdhasjd67483278'
        );
        PageReference pageRef = Page.PqPresentAccountPlan;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('planId', actemplate[0].id);
        ApexPages.currentPage().getParameters().put('recordId', acPlan.id);
        PqPresentAccountPlanController pqPresentpan = new PqPresentAccountPlanController();
        pqPresentpan.getListAndImage();
        System.assertNotEquals(0, actemplate.size(), 'Size of actemplate should not be 0');
        Test.stopTest();
    }
}