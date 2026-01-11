public with sharing class LeadSelector extends fflib_SObjectSelector {
    public static final Integer MAX_RESULT = 300;

    public static LeadSelector newInstance() {
        return (LeadSelector) Application.Selector.newInstance(Lead.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Lead.Id,
            Lead.Company,
            Lead.Status,
            Lead.FirstName,
            Lead.LastName,
            Lead.Name,
            Lead.ConvertedContactId
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Lead.sObjectType;
    }

    public override String getOrderBy() {
        return Lead.LastName.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Lead> selectById(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :ids');
        query.selectFields(getAdditionalFields());
        return Database.query(query.toSOQL());
    }

    public List<Lead> selectNonConvertedWithAdditionalFields(
        Set<Id> excludedIds,
        Set<String> additionalFields,
        Integer maxResult
    ) {
        if (maxResult <= 0) {
            return new List<Lead>();
        }

        if (maxResult > MAX_RESULT) {
            maxResult = MAX_RESULT;
        }

        Set<String> allAdditionalFields = new Set<String>();
        allAdditionalFields.addAll(additionalFields);
        allAdditionalFields.addAll(getAdditionalFields());

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id NOT IN :excludedIds AND ConvertedContactId = null');
        query.selectFields(allAdditionalFields);
        query.setLimit(maxResult);

        return Database.query(query.toSOQL());
    }

    /******************************
     *        SEARCH METHODS
     ******************************/

    public List<Lead> search(String searchTerm, Set<Id> excludedIds, Set<String> additionalFields, Integer maxResult) {
        searchTerm = searchTerm.trim();

        if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
            return new List<Lead>();
        }

        if (maxResult <= 0) {
            return new List<Lead>();
        }

        if (maxResult > MAX_RESULT) {
            maxResult = MAX_RESULT;
        }

        SearchUtils searchUtils = new SearchUtils(sObjectType())
            .withSearchQuery(SearchUtils.escapeSpecialCharacters(searchTerm))
            .withLimit(maxResult)
            .withCondition('Id NOT IN :excludedIds AND ConvertedContactId = null')
            .withSelectFields(getSObjectFieldList())
            .withSelectFields(additionalFields)
            .withWildcard();

        List<SObject> results = Search.query(searchUtils.toSOSL())[0];
        return results;
    }

    private Set<String> getAdditionalFields() {
        Set<String> result = new Set<String>();
        if (Schema.sObjectType.Lead.fields.Email.isAccessible()) {
            result.add('Email');
        }

        if (Schema.sObjectType.Lead.fields.Title.isAccessible()) {
            result.add('Title');
        }

        return result;
    }
}