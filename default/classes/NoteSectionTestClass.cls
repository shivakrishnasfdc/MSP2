@IsTest
public with sharing class NoteSectionTestClass {
    @IsTest
    public static void testcreateJson() {
        Test.startTest();
        Account acc = TestDataFactory.createAccount('Test Account');
        pqcrush__Account_Plan__c accPlan = TestDataFactory.createAccountPlan('Test Account Plan', acc);
        List<pqcrush__Account_Plan_Template__c> accPlanTemp = TestDataFactory.createAccountPlanTemplate();
        Id recordId = accPlan.Id;
        Id templateids = accPlanTemp[0].Id;
        List<pqcrush__NoteSection__c> notesSectionList = ShowNoteSection.createJson(recordId, templateids);
        System.assertNotEquals(null, notesSectionList, 'notesSectionList should not be null');
        Test.stopTest();
    }

    @IsTest
    public static void testupdateNoteSection() {
        Test.startTest();
        Account acc = TestDataFactory.createAccount('Test Account');
        pqcrush__Account_Plan__c accPlan = TestDataFactory.createAccountPlan('Test Account Plan', acc);
        List<pqcrush__Account_Plan_Template__c> accPlanTemp = TestDataFactory.createAccountPlanTemplate();
        Id recordId = accPlan.Id;
        Id templateids = accPlanTemp[0].Id;
        pqcrush__NoteSection__c notesRec = TestDataFactory.createNotesSection(recordId, templateids);
        Id notesid = notesRec.Id;
        List<pqcrush__NoteSection__c> notesSectionList = ShowNoteSection.updateNoteSection(notesid, '<p>helllo</p>');
        System.assertNotEquals(null, notesSectionList, 'notesSectionList should not be null');
        Test.stopTest();
    }
    @IsTest
    public static void testinsertNoteSection() {
        Test.startTest();
        Account acc = TestDataFactory.createAccount('Test Account');
        pqcrush__Account_Plan__c accPlan = TestDataFactory.createAccountPlan('Test Account Plan', acc);
        List<pqcrush__Account_Plan_Template__c> accPlanTemp = TestDataFactory.createAccountPlanTemplate();
        Id recordId = accPlan.Id;
        Id templateids = accPlanTemp[0].Id;
        Id userId = UserInfo.getUserId();
        List<pqcrush__NoteSection__c> notesSectionList = ShowNoteSection.insertNoteSection(
            recordId,
            templateids,
            '<p>helllo</p>',
            userId
        );
        System.assertNotEquals(null, notesSectionList, 'notesSectionList should not be null');
        Test.stopTest();
    }
}