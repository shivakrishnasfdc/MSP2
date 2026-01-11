public with sharing class WhiteSpaceCollectionWrapper {
    @AuraEnabled
    public SObject collection { get; set; }
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public String name {
        get {
            return String.isEmpty(name) ? '[no label]' : name;
        }
        set;
    }
    @AuraEnabled
    public String parentObjectId { get; set; }
    @AuraEnabled
    public String relatedObjectId { get; set; }
    @AuraEnabled
    public List<String> groupedRelatedRecordIds { get; set; }

    public WhiteSpaceCollectionWrapper(SObject rowOrColumnObj) {
        this.collection = rowOrColumnObj;
        this.id = rowOrColumnObj.id;
        this.name = (String) rowOrColumnObj.get('Name');
    }

    public WhiteSpaceCollectionWrapper(SObject rowOrColumnObj, String relatedObjectId, String name) {
        this(rowOrColumnObj, relatedObjectId, name, null);
    }

    public WhiteSpaceCollectionWrapper(
        SObject rowOrColumnObj,
        String relatedObjectId,
        String name,
        List<String> groupedRelatedRecordIds
    ) {
        this.collection = rowOrColumnObj;
        this.id = rowOrColumnObj.Id;
        this.relatedObjectId = relatedObjectId;
        this.name = name;
        this.groupedRelatedRecordIds = groupedRelatedRecordIds;
    }

    public WhiteSpaceCollectionWrapper(
        SObject rowOrColumnObj,
        WhitespaceTemplateMappingWrapper mapping,
        SObject relatedObj
    ) {
        this.collection = rowOrColumnObj;
        this.id = rowOrColumnObj.Id;
        this.name = (String) rowOrColumnObj.get('Name');
        if (validMappingAndRelatedObj(mapping, relatedObj)) {
            Object tempName = relatedObj.get(mapping.labelFieldName);
            if (tempName != null) {
                this.name = String.valueOf(tempName);
            } else {
                this.name = '[no label]';
            }
            this.relatedObjectId = relatedObj.Id;
            if (String.isNotBlank(mapping.parentIdFieldName)) {
                this.parentObjectId = String.valueOf(relatedObj.get(mapping.parentIdFieldName));
            }
        }
    }

    private Boolean validMappingAndRelatedObj(WhitespaceTemplateMappingWrapper mapping, SObject relatedObj) {
        return mapping != null &&
            relatedObj != null &&
            mapping.objectName.toLowerCase() == relatedObj.getSObjectType().getDescribe().getName().toLowerCase();
    }
}