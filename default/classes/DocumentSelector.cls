public with sharing class DocumentSelector extends fflib_SObjectSelector {
    public DocumentSelector() {
        super(false, true, false);
    }

    public static DocumentSelector newInstance() {
        return (DocumentSelector) Application.Selector.newInstance(Document.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Document.Id, Document.Name };
    }

    public Schema.SObjectType getSObjectType() {
        return Document.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Document> selectByFolderName(Set<String> folderNames) {
        return Database.query(newQueryFactory().setCondition('Folder.Name in :folderNames').toSOQL());
    }
}