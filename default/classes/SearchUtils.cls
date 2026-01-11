public with sharing class SearchUtils {
    /** @description Message to indicate the Search is constructed incorrectly when sObjectType is not provided */
    @TestVIsible
    private static final String SOBJECT_TYPE_REQUIRED = 'sObjectType is required for the search';
    /** @description Message to indicate the Search is constructed incorrectly when no value is specified in FIND clause */
    @TestVIsible
    private static final String SEARCH_QUERY_REQUIRED = 'Search query is required for the search';
    /** @description Message to indicate the Search is constructed incorrectly when no sObject field is specified */
    @TestVIsible
    private static final String FIELDS_REQUIRED = 'At least one field required to be returned from the search';

    /** @description The sObjectType to query/search */
    private sObjectType sObjType;
    /** @description The search group: search in all fields or just Name fields */
    private String searchGroup;
    /** @description The WHERE clause */
    @TestVisible
    private String conditionExpression;
    // @TestVisible
    // private UTIL_Where criteria;
    /** @description The LIMIT segment */
    private Integer limitRows;
    /** @description The search query applicable only when executeSearch() is to be applied */
    private String searchQuery;
    /** @description If true, the wildcard is added to searchQuery when executeSearch() is executed */
    private Boolean isWildcardSearch = false;
    /** @description The ORDER BY clause */
    private String orderBy;
    /** @description Fields to return from the query/search */
    @TestVisible
    private Set<String> selectFields {
        get {
            if (selectFields == null) {
                selectFields = new Set<String>{ 'Id' };
            }
            return selectFields;
        }
        set;
    }

    public SearchUtils(sObjectType sObjectType) {
        this.sObjType = sObjectType;
        this.searchGroup = 'ALL';
    }

    public SearchUtils withSearchQuery(String searchQuery) {
        this.searchQuery = searchQuery;
        return this;
    }

    public SearchUtils withCondition(String conditionExpression) {
        this.conditionExpression = conditionExpression;
        return this;
    }

    public SearchUtils withSelectFields(Set<Schema.sObjectField> sObjFields) {
        for (Schema.sObjectField sObjField : sObjFields) {
            selectFields.add(String.valueOf(sObjField));
        }
        return this;
    }

    public SearchUtils withSelectFields(List<Schema.sObjectField> sObjFields) {
        for (Schema.sObjectField sObjField : sObjFields) {
            selectFields.add(String.valueOf(sObjField));
        }
        return this;
    }

    public SearchUtils withSelectFields(Set<String> sObjFields) {
        for (String sObjField : sObjFields) {
            selectFields.add(sObjField);
        }
        return this;
    }

    public SearchUtils withLimit(Integer limitRows) {
        this.limitRows = limitRows;
        return this;
    }

    public SearchUtils withSearchGroup(String searchGroup) {
        this.searchGroup = searchGroup;
        return this;
    }

    public SearchUtils withWildcard() {
        isWildcardSearch = true;
        return this;
    }

    /*********************************************************************************************************
     * @description Searches for records based on the specified searchQuery
     * @return List<sObject>
     */
    public List<sObject> executeSearch() {
        String sosl = this.build();
        List<sObject> results = Search.query(sosl)[0];
        return results;
    }

    public String toSOSL() {
        String sosl = this.build();
        return sosl;
    }

    /*********************************************************************************************************
     * @description Builds the SOSL query
     * @return String
     */
    @TestVisible
    private String build() {
        validate();

        String searchText = this.searchQuery + (this.isWildcardSearch ? '*' : '');

        return String.format(
            'FIND \'\'{0}\'\' IN {1} FIELDS RETURNING {2}({3}{4}{5}){6}',
            new List<String>{
                searchText,
                this.searchGroup,
                String.valueOf(this.sObjType),
                String.join(new List<String>(this.selectFields), ', '),
                buildConditionExpression(),
                buildOrderBy(),
                buildLimit()
            }
        );
    }

    /*********************************************************************************************************
     * @description Validates the SOSL
     * @return void
     */
    private void validate() {
        if (this.sObjType == null) {
            throw new SoslException(SOBJECT_TYPE_REQUIRED);
        }
        if (String.isBlank(this.searchQuery)) {
            throw new SoslException(SEARCH_QUERY_REQUIRED);
        }
        if (this.selectFields == null || this.selectFields.isEmpty()) {
            throw new SoslException(FIELDS_REQUIRED);
        }
    }

    private String buildConditionExpression() {
        return String.isBlank(this.conditionExpression) ? '' : ' WHERE ' + this.conditionExpression;
    }

    private String buildLimit() {
        return this.limitRows == null ? '' : ' LIMIT ' + String.valueOf(this.limitRows);
    }

    private String buildOrderBy() {
        return String.isBlank(this.orderBy) ? '' : ' ORDER BY ' + this.orderBy;
    }

    public static String escapeSpecialCharacters(String s) {
        if (String.isBlank(s)) {
            return s;
        }

        return s.replaceAll('(?=[]\\[+&|!(){}^\"~*?:\\\\-])', '\\\\');
    }

    /** @description Search exception class */
    public class SoslException extends Exception {
    }
}