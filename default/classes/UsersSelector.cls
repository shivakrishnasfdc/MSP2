/**
 * Class encapsulates query logic for User
 *
 * https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer
 **/
public with sharing class UsersSelector extends fflib_SObjectSelector {
    public static final Integer MAX_RESULT = 300;

    public static UsersSelector newInstance() {
        return (UsersSelector) Application.Selector.newInstance(User.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            User.Id,
            User.FirstName,
            User.LastName,
            User.Name,
            User.Title,
            User.Email,
            User.ManagerId,
            User.IsActive,
            User.FullPhotoUrl
        };
    }

    public Schema.SObjectType getSObjectType() {
        return User.sObjectType;
    }

    public override String getOrderBy() {
        return User.LastName.getDescribe().getName();
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<User> selectById(Set<Id> idSet) {
        return (List<User>) selectSObjectsById(idSet);
    }

    public List<User> selectByIdAsSystem(Set<Id> idSet) {
        return new SystemSelector().selectById(this, idSet);
    }

    public List<User> selectAll(Set<Id> excludeIds, Set<String> queryFields, Integer maxResult) {
        if (maxResult <= 0) {
            return new List<User>();
        }

        if (maxResult > MAX_RESULT) {
            maxResult = MAX_RESULT;
        }

        if (queryFields == null) {
            queryFields = new Set<String>();
        }

        queryFields.add('ManagerId');

        Set<String> queryFieldsEscaped = new Set<String>();
        for (String s : queryFields) {
            queryFieldsEscaped.add(String.escapeSingleQuotes(s));
        }

        return Database.query(
            newQueryFactory()
                .selectFields(queryFieldsEscaped)
                .setCondition('IsActive = true AND Id NOT IN :excludeIds')
                .setLimit(maxResult)
                .toSOQL()
        );
    }

    public List<User> selectByIdAndSelectFields(Set<Id> ids, Set<String> queryFields) {
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        queryFields.add('ManagerId');

        Set<String> queryFieldsEscaped = new Set<String>();
        for (String s : queryFields) {
            queryFieldsEscaped.add(String.escapeSingleQuotes(s));
        }

        return Database.query(newQueryFactory().selectFields(queryFieldsEscaped).setCondition('Id IN :ids').toSOQL());
    }

    public List<User> selectByManagerIds(Set<Id> idSet, Set<String> queryFields) {
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        queryFields.add('ManagerId');

        Set<String> queryFieldsEscaped = new Set<String>();
        for (String s : queryFields) {
            queryFieldsEscaped.add(String.escapeSingleQuotes(s));
        }

        return Database.query(
            newQueryFactory().selectFields(queryFieldsEscaped).setCondition('ManagerId IN :idSet').toSOQL()
        );
    }

    public List<User> selectByPermissionSetName(String permissionSetName) {
        return Database.query(
            newQueryFactory()
                .setCondition(
                    'Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :permissionsetName)'
                )
                .toSOQL()
        );
    }

    public List<User> selectByPermissionSetNameAdmin(String permissionSetName) {
        return new SystemSelector().selectByPermissionSetName(this, permissionsetName);
    }

    public Set<Id> selectActiveUserIdsAsSystem(Set<Id> userIds) {
        return new SystemSelector().selectActiveUserIds(this, userIds);
    }

    private with sharing class SystemSelector {
        private List<User> selectByPermissionSetName(UsersSelector selector, String permissionSetName) {
            return Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition(
                        'Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :permissionsetName)'
                    )
                    .toSOQL()
            );
        }

        private Set<Id> selectActiveUserIds(UsersSelector selector, Set<Id> userIds) {
            Set<Id> idSet = new Set<Id>();
            List<User> users = Database.query(
                selector.newQueryFactory(false, false, true).setCondition('Id IN :userIds AND IsActive = true').toSOQL()
            );
            if (users != null && users.size() > 0) {
                idSet = new Map<Id, User>(users).keySet();
            }
            return idSet;
        }

        public List<User> selectById(UsersSelector selector, Set<Id> idSet) {
            return Database.query(selector.newQueryFactory(false, false, true).setCondition('id in :idSet').toSOQL());
        }
    }

    /******************************
     *        SEARCH METHODS
     ******************************/

    public List<User> search(
        String searchTerm,
        Set<Id> excludedUserIds,
        Set<String> additionalFields,
        Integer maxResult
    ) {
        searchTerm = searchTerm.trim();

        if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
            return new List<User>();
        }

        if (maxResult <= 0) {
            return new List<User>();
        }

        if (maxResult > MAX_RESULT) {
            maxResult = MAX_RESULT;
        }

        Set<String> queryFieldsEscaped = new Set<String>();
        for (String s : additionalFields) {
            queryFieldsEscaped.add(String.escapeSingleQuotes(s));
        }

        SearchUtils searchUtils = new SearchUtils(sObjectType())
            .withSearchQuery(String.escapeSingleQuotes(searchTerm))
            .withLimit(maxResult)
            .withSelectFields(getSObjectFieldList())
            .withSelectFields(queryFieldsEscaped)
            .withWildcard();

        searchUtils.withCondition('IsActive = true AND Id NOT IN :excludedUserIds');

        List<SObject> results = Search.query(searchUtils.toSOSL())[0];
        return results;
    }
}