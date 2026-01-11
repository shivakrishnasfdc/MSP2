public with sharing class NoteSectionSelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/
    public static NoteSectionSelector newInstance() {
        return (NoteSectionSelector) Application.Selector.newInstance(pqcrush__NoteSection__c.SobjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SobjectField> getSobjectFieldList() {
        return new List<Schema.SobjectField>{
            pqcrush__NoteSection__c.Id,
            pqcrush__NoteSection__c.pqcrush__Account_Plan__c,
            pqcrush__NoteSection__c.pqcrush__Account_Plan_Template__c,
            pqcrush__NoteSection__c.pqcrush__User__c,
            pqcrush__NoteSection__c.pqcrush__User__r.Name,
            pqcrush__NoteSection__c.pqcrush__Rich_Text_Area__c,
            pqcrush__NoteSection__c.LastModifiedDate
        };
    }
    public Schema.SObjectType getSObjectType() {
        return pqcrush__NoteSection__c.SobjectType;
    }

    public List<pqcrush__NoteSection__c> getAllNoteSectionReletedToAccPlan(Id recordId, Id templateids) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('pqcrush__User__r.Name');
        query.setCondition('pqcrush__Account_Plan__c =:recordId AND pqcrush__Account_Plan_Template__c =:templateids');
        return (List<pqcrush__NoteSection__c>) Database.query(query.toSOQL());
    }
    public List<pqcrush__NoteSection__c> updateNoteSection(Id notesId, Integer limitValue) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id = :notesId');
        query.setLimit(limitValue);
        return (List<pqcrush__NoteSection__c>) Database.query(query.toSOQL());
    }
    public List<pqcrush__NoteSection__c> insertNoteSection(Id notesectionId) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('pqcrush__User__r.Name');
        query.setCondition('Id = :notesectionId');
        return (List<pqcrush__NoteSection__c>) Database.query(query.toSOQL());
    }
}