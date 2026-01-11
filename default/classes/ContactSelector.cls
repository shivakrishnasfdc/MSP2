public with sharing class ContactSelector extends fflib_SObjectSelector {
    public static final Integer MAX_RESULT = 300;
    /******************************
     *      STATIC METHODS
     ******************************/

    public static ContactSelector newInstance() {
        return (ContactSelector) Application.Selector.newInstance(Contact.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        /*** NOTE: Do not add ReportsToId as it causes issues ***/
        return new List<Schema.SObjectField>{ Contact.Id, Contact.FirstName, Contact.LastName, Contact.Name };
    }

    public Schema.SObjectType getSObjectType() {
        return Contact.sObjectType;
    }

    public override String getOrderBy() {
        return Contact.Name.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Contact> selectById(Set<Id> ids) {
        return (List<Contact>) selectSObjectsById(ids);
    }

    public List<Contact> selectByIdAndSelectFields(Set<Id> ids, Set<String> queryFields) {
        System.debug('===selectByIdAndSelectFields called====');
        System.debug('===queryFields===='+queryFields);
        System.debug('===set ids===='+ids);
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        return Database.query(newQueryFactory().selectFields(queryFields).setCondition('Id IN :ids').toSOQL());
    }

    public List<Contact> selectByReportsToId(Set<Id> ids, Set<String> queryFields) {
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        queryFields.add('ReportsToId');
        return Database.query(newQueryFactory().selectFields(queryFields).setCondition('ReportsToId IN :ids').toSOQL());
    }

    public List<Contact> selectByAccountIdWithAdditionalFields(
        Set<Id> excludedContactIds,
        Set<String> additionalFields,
        Integer maxResult,
        Set<Id> accountIds
    ) {
        System.debug('===selectByAccountIdWithAdditionalFields called==');
        if (maxResult <= 0) {
            return new List<Contact>();
        }

        if (maxResult > MAX_RESULT) {
            maxResult = MAX_RESULT;
        }

        fflib_QueryFactory query = newQueryFactory();
        if (accountIds != null && accountIds.size() > 0) {
            Set<Id> contactIds = AccountService.getContactIdsForAccount(accountIds); //NOPMD
            query.setCondition('Id NOT IN :excludedContactIds AND Id IN :contactIds');
        } else {
            query.setCondition('Id NOT IN :excludedContactIds');
        }
        query.selectFields(additionalFields);
        query.setLimit(maxResult);

        return Database.query(query.toSOQL());
    }

    public List<Contact> selectByAccountIdWithCustomCondition(
        Set<String> additionalFields,
        Set<Id> accountIds,
        Set<Id> excludedContactIds,
        Integer maxResult,
        String dynamicQuery
    ) {
        if (maxResult <= 0) {
            return new List<Contact>();
        }

        if (maxResult > MAX_RESULT) {
            maxResult = MAX_RESULT;
        }

        fflib_QueryFactory query = newQueryFactory();

        if (accountIds != null && accountIds.size() > 0) {
            if (dynamicQuery != '') {
                query.setCondition('Id NOT IN :excludedContactIds AND AccountId IN :accountIds AND ' + dynamicQuery);
            } else {
                query.setCondition('Id NOT IN :excludedContactIds AND AccountId IN :accountIds');
            }
        } else if (excludedContactIds != null && excludedContactIds.size() > 0) {
            if (dynamicQuery != '') {
                query.setCondition('Id NOT IN :excludedContactIds AND ' + dynamicQuery);
            } else {
                query.setCondition('Id NOT IN :excludedContactIds');
            }
        } else {
            if (dynamicQuery != '') {
                query.setCondition(dynamicQuery);
            }
        }
        query.selectFields(additionalFields);
        query.setLimit(maxResult);
        return Database.query(query.toSOQL());
    }

    /******************************
     *        SEARCH METHODS
     ******************************/

    public List<Contact> search(
        String searchTerm,
        Set<Id> excludedContactIds,
        Set<String> additionalFields,
        Integer maxResult,
        Set<Id> accountIds
    ) {
        System.debug('====search called==');
        searchTerm = searchTerm.trim();

        if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
            return new List<Contact>();
        }

        if (maxResult <= 0) {
            return new List<Contact>();
        }

        if (maxResult > MAX_RESULT) {
            maxResult = MAX_RESULT;
        }

        SearchUtils searchUtils = new SearchUtils(sObjectType())
            .withSearchQuery(SearchUtils.escapeSpecialCharacters(searchTerm))
            .withLimit(maxResult)
            .withSelectFields(getSObjectFieldList())
            .withSelectFields(additionalFields)
            .withWildcard();

        if (accountIds != null && accountIds.size() > 0) {
            Set<Id> contactIds = AccountService.getContactIdsForAccount(accountIds); //NOPMD
            searchUtils.withCondition('Id NOT IN :excludedContactIds AND Id IN :contactIds');
        } else {
            searchUtils.withCondition('Id NOT IN :excludedContactIds');
        }
        System.debug('===searchUtils=='+searchUtils);
        List<SObject> results = Search.query(searchUtils.toSOSL())[0];
        System.debug('===results=='+results);
        

        return results;
    }
}