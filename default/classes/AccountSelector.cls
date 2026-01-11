public with sharing class AccountSelector extends fflib_SObjectSelector {
    private static Map<Set<Id>, List<Account>> selectByIdcache = new Map<Set<Id>, List<Account>>();
    public static AccountSelector newInstance() {
        return (AccountSelector) Application.Selector.newInstance(Account.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account.Id,
            Account.Name,
            Account.Type,
            Account.Ownership,
            Account.Industry,
            Account.AnnualRevenue,
            Account.ParentId

        };
    }

    //Account Data
    public List<Account> selectByIds(Set<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            return new List<Account>();
        }
        if (selectByIdcache.containsKey(ids)) {
            return selectByIdcache.get(ids);
        }
        List<Account> result = (List<Account>) selectSObjectsById(ids);
        selectByIdcache.put(ids, result);
        System.debug('==selectByIds result==='+result);
        return result;
    }

    //Account Data
    public List<Account> selectByAccIdsAndSelectFieldsWithYourAccounts(Id accId) {
        if (accId == null) {
            return new List<Account>();
        }

        return getHierarchyAccountsList(accId);
    }

    public static List<Account> getHierarchyAccountsList(Id parentId) {
        List<Id> fullHierarchy = new List<Id>();
        List<Id> childAccIds = new List<Id>();
        childAccIds.add(parentId);
        fullHierarchy.add(parentId);
        for(Integer i=0; i<6 ; i++){
            List<Id> childHierarchy = new List<Id>();
        	childHierarchy = fetchChildAccounts(childAccIds);
            childAccIds.clear();
            if(childHierarchy.size() < 1){
                break;
            }
            else{
                childAccIds.addAll(childHierarchy);
                fullHierarchy.addAll(childHierarchy);
            }
        }
        
        return [SELECT Id, Name, ParentId, Parent.name FROM Account WHERE Id IN :fullHierarchy WITH SECURITY_ENFORCED];
    }
    
    private static List<Id> fetchChildAccounts(List<Id> hierarchy) {
        List<Account> children = [SELECT Id, Name FROM Account WHERE ParentId IN :hierarchy WITH SECURITY_ENFORCED];
        List<Id> childIds = new List<Id>();
        for (Account child : children) {
            childIds.add(child.Id);
            //fetchChildAccounts(child.Id, hierarchy);  // Recursive call to get deeper levels
        }
        return childIds;
    }

    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    public List<Account> selectById(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory();

        fflib_SObjectSelector userSelector = new UsersSelector();
        userSelector.configureQueryFactoryFields(query, 'OwnerId');
        query.setCondition('Id IN :ids');
        return (List<Account>) Database.query(query.toSOQL());
    }

    public List<Account> selectByIdAndSelectFields(Set<Id> ids, Set<String> queryFields) {
        System.debug('===selectByIdAndSelectFields called====');
        System.debug('===queryFields===='+queryFields);
        System.debug('===set ids===='+ids);
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        return Database.query(newQueryFactory().selectFields(queryFields).setCondition('Id IN :ids').toSOQL());
    }

    public List<Account> notSelectByIdAndSelectFields(Set<Id> ids, Set<String> queryFields) {
        System.debug('===notSelectByIdAndSelectFields called====');
        System.debug('===queryFields===='+queryFields);
        System.debug('===set ids===='+ids);
        if (queryFields == null) {
            queryFields = new Set<String>();
        }
        return Database.query(newQueryFactory().selectFields(queryFields).setCondition('Id  NOT IN :ids AND ParentId = null').toSOQL());
    }
}