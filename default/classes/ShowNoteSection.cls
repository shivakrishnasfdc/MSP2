public with sharing class ShowNoteSection {
    /**********************************
     * To Create Data of Notes Section *
     ***********************************/
    @AuraEnabled
    public static List<pqcrush__NoteSection__c> createJson(Id recordId, ID templateids) {
        List<pqcrush__NoteSection__c> notesList = new NoteSectionSelector()
            .getAllNoteSectionReletedToAccPlan(recordId, templateids);
        return notesList;
    }

    /********************************
     * Update Notes Section Records *
     ********************************/
    @AuraEnabled
    public static List<pqcrush__NoteSection__c> updateNoteSection(Id notesId, string message) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        Integer limitValue = 1;
        List<pqcrush__NoteSection__c> notesRecord = new NoteSectionSelector().updateNoteSection(notesId, limitValue);
        notesRecord[0].ID = notesId;
        notesRecord[0].pqcrush__Rich_Text_Area__c = message;
        uow.registerDirty(notesRecord);
        uow.commitWork();
        return new NoteSectionSelector().updateNoteSection(notesId, limitValue);
    }

    /********************************
     * Create Notes Section Records *
     ********************************/
    @AuraEnabled
    public static List<pqcrush__NoteSection__c> insertNoteSection(
        ID accountPlan,
        ID accountPlanTemp,
        string message,
        Id currentUserdata
    ) {
        List<pqcrush__NoteSection__c> notesInsert = new List<pqcrush__NoteSection__c>();
        pqcrush__NoteSection__c acc = new pqcrush__NoteSection__c();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());

        acc.pqcrush__Account_Plan__c = accountPlan;
        acc.pqcrush__Account_Plan_Template__c = accountPlanTemp;
        acc.pqcrush__User__c = currentUserdata;
        acc.pqcrush__Rich_Text_Area__c = message;
        notesInsert.add(acc);
        uow.registerNew(notesInsert);
        uow.commitWork();
        Id notesectionId = notesInsert[0].Id;
        List<pqcrush__NoteSection__c> noteRecord = new NoteSectionSelector().insertNoteSection(notesectionId);
        return noteRecord;
    }
}