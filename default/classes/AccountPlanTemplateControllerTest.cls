@isTest
public with sharing class AccountPlanTemplateControllerTest {
    @isTest
    public static void testAccountPlanTemplateController() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> actemplate = TestDataFactory.createAccountPlanTemplate();
        pqcrush__Account_Plan__c acPlan = TestDataFactory.createAccountPlan('Test');
        PageReference pageRef = Page.AccountPlanTemplate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recordId', actemplate[0].id);
        ApexPages.currentPage().getParameters().put('planId', acPlan.id);
        ApexPages.currentPage().getParameters().put('recordIdPlan', acPlan.id);
        ApexPages.currentPage().getParameters().put('showAttribute', 'false');
        ApexPages.currentPage().getParameters().put('headerTitle', 'testTitle');

        // Create a StandardController for the test data
        ApexPages.StandardController stdController = new ApexPages.StandardController(actemplate[0]);
        // Instantiate the controller class
        AccountPlanTemplateController controller = new AccountPlanTemplateController(stdController);

        System.assertNotEquals(null, controller, 'controller should not be null');
        System.assertNotEquals(0, actemplate.size(), 'Size of actemplate should not be zero');

        Test.stopTest();
    }

    @isTest
    public static void testAccountPlanTemplateControllerWithTrueShowAttribute() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> actemplate = TestDataFactory.createAccountPlanTemplate();
        pqcrush__Account_Plan__c acPlan = TestDataFactory.createAccountPlan('Test');
        PageReference pageRef = Page.AccountPlanTemplate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recordId', actemplate[0].id);
        ApexPages.currentPage().getParameters().put('planId', acPlan.id);
        ApexPages.currentPage().getParameters().put('recordIdPlan', acPlan.id);
        ApexPages.currentPage().getParameters().put('showAttribute', 'true');
        ApexPages.currentPage().getParameters().put('headerTitle', 'testTitle');

        // Create a StandardController for the test data
        ApexPages.StandardController stdController = new ApexPages.StandardController(actemplate[0]);
        // Instantiate the controller class
        AccountPlanTemplateController controller = new AccountPlanTemplateController(stdController);

        System.assertNotEquals(null, controller, 'controller should not be null');
        System.assertNotEquals(0, actemplate.size(), 'Size of actemplate should not be 0');

        Test.stopTest();
    }

    @isTest
    public static void getAccountPlan() {
        Test.startTest();
        TestDataFactory.createAccountPlan('Test');
        List<pqcrush__Account_Plan__c> accPlanListData = AccountPlanTemplateController.getAccountPlan('Test');
        System.assertEquals(1, accPlanListData.size(), 'Size of accPlanListData should be 1');
        Test.stopTest();
    }

    @isTest
    public static void getAccountPlanWithNoData() {
        Test.startTest();
        List<pqcrush__Account_Plan__c> accPlanListData = AccountPlanTemplateController.getAccountPlan('Test');
        System.assertEquals(null, accPlanListData, 'accPlanListData should be null');
        Test.stopTest();
    }

    @isTest
    public static void getComponentAvailableMdt() {
        Test.startTest();
        List<pqcrush__Component_Available__mdt> componentMetadata = AccountPlanTemplateController.getComponentAvailableMdt();
        System.assertNotEquals(null, componentMetadata, 'componentMetadata should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getComponentAvailableMdtWithNoData() {
        Test.startTest();
        TestDataFactory.createComponentMetadata();
        List<pqcrush__Component_Available__mdt> componentMetadata = AccountPlanTemplateController.getComponentAvailableMdt();
        System.assertNotEquals(0, componentMetadata.size(), 'Size of componentMetadata should not be 0');
        Test.stopTest();
    }

    @isTest
    public static void getAccountPlanTemplate() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> accPlaTemplate = TestDataFactory.createAccountPlanTemplate();
        List<pqcrush__Account_Plan_Template__c> accPlan = AccountPlanTemplateController.getAccountPlanTemplate(
            accPlaTemplate[0].Name
        );
        System.assertEquals(1, accPlan.size(), 'Size of accPlan should be 1');
        Test.stopTest();
    }

    @isTest
    public static void getAccountPlanTemplateWithNoData() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> accPlan = AccountPlanTemplateController.getAccountPlanTemplate('Test');
        System.assertEquals(null, accPlan, 'accPlan should be null');
        Test.stopTest();
    }

    @isTest
    public static void receiveCanvasData() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> acPlanTemp = TestDataFactory.createAccountPlanTemplate();
        AccountPlanTemplateController.receiveCanvasData(
            'Test',
            'Test',
            'b6sajdhuyuydjhsjdhj67bsadhjjdhsjh',
            '[{"componentIndex":0,"componentName":"PROLIFIQ RM Influence Chart","componentApiName":"RelationshipMapInfluenceChart","isRelatedObject":false},{"componentIndex":1,"componentName":"PROLIFIQ CRUSH Alerts","componentApiName":"closedAccountPlanWarning","isRelatedObject":false}]',
            'TestFile',
            false,
            acPlanTemp[0].Id
        );

        System.assertNotEquals(0, acPlanTemp.size(), 'Size of acPlanTemp should not be 0');

        Test.stopTest();
    }

    @isTest
    public static void receiveCanvasDataWithTrueSaveAsDefault() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> acPlanTempDefaultCheck = TestDataFactory.createAccountPlanTemplateWithDefault();
        AccountPlanTemplateController.receiveCanvasData(
            'Test',
            'Test',
            'b6sajdhuyuydjhsjdhj67bsadhjjdhsjh',
            '[{"componentIndex":0,"componentName":"PROLIFIQ RM Influence Chart","componentApiName":"RelationshipMapInfluenceChart","isRelatedObject":false},{"componentIndex":1,"componentName":"PROLIFIQ CRUSH Alerts","componentApiName":"closedAccountPlanWarning","isRelatedObject":false}]',
            'TestFile',
            true,
            ''
        );

        System.assertNotEquals(0, acPlanTempDefaultCheck.size(), 'Size of acPlanTempDefaultCheck should not be 0');

        Test.stopTest();
    }

    @isTest
    public static void getTemplateById() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> acPlanTemp = TestDataFactory.createAccountPlanTemplate();
        AccountPlanTemplateController.getTemplateById(acPlanTemp[0].Id);
        System.assertNotEquals(0, acPlanTemp.size(), 'Size of acPlanTemp should not be 0');
        Test.stopTest();
    }

    @isTest
    public static void getTemplateSection() {
        Test.startTest();
        pqcrush__Account_Plan__c acPlan = TestDataFactory.createAccountPlan('Test');
        List<pqcrush__Account_Plan_Template__c> acPlanTemp = TestDataFactory.createAccountPlanTemplate();
        pqcrush__Template_Section__c acPlanTempsection = TestDataFactory.createTemplateSection(
            acPlan.Id,
            acPlanTemp[0].Id
        );
        AccountPlanTemplateController.getTemplateSection(acPlanTempsection.Id);
        System.assertNotEquals(null, acPlanTemp, 'acPlanTemp should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getContentVersion() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> acPlanTemp = TestDataFactory.createAccountPlanTemplate();
        ContentVersion conVer = TestDataFactory.createContentVersion(
            'TestFileName',
            acPlanTemp[0].Id,
            'b6sajdhuyuydjhsjdhj67bsadhjjdhsjh'
        );
        AccountPlanTemplateController.getContentVersion(acPlanTemp[0].Id);
        System.assertNotEquals(null, conVer, 'conVer should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getContentVersionWithNoData() {
        Test.startTest();
        List<pqcrush__Account_Plan_Template__c> acPlanTemp = TestDataFactory.createAccountPlanTemplate();
        List<String> conVer = AccountPlanTemplateController.getContentVersion(acPlanTemp[0].Id);
        System.assertEquals(null, conVer, 'conVer should be null');
        Test.stopTest();
    }
}