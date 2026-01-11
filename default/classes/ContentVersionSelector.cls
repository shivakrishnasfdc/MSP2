public with sharing class ContentVersionSelector extends fflib_SObjectSelector {
    /******************************
     *      STATIC METHODS
     ******************************/

    public static ContentVersionSelector newInstance() {
        return (ContentVersionSelector) Application.Selector.newInstance(ContentVersion.SObjectType);
    }
    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ContentVersion.Id,
            ContentVersion.ContentDocumentId,
            ContentVersion.FirstPublishLocationId,
            ContentVersion.VersionData,
            ContentVersion.FileExtension,
            ContentVersion.Title
        };
    }
    public Schema.SObjectType getSObjectType() {
        return ContentVersion.sObjectType;
    }
    /******************************
     *        SELECT METHODS
     ******************************/

    public List<ContentVersion> selectByFirstPublishLocationIdAndDescription(
        Id recordId,
        string description,
        Integer limitValue
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('FirstPublishLocationId = :recordId AND Description=:description');
        query.setLimit(limitValue);
        return (List<ContentVersion>) Database.query(query.toSOQL());
    }
    public List<ContentVersion> selectByFirstPublishLocationIdAndDescriptionWithoutLimit(
        Id recordId,
        Id currentUserId,
        string description
    ) {
        Integer limitValue = 1;
        fflib_QueryFactory query = newQueryFactory();
        query.addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING, false);
        query.setCondition(
            'FirstPublishLocationId = :recordId AND  Description=:description AND CreatedById=:currentUserId'
        );
        query.setLimit(limitValue);
        return (List<ContentVersion>) Database.query(query.toSOQL());
    }
}