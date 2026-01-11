@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class AccountPlanSelector extends fflib_SObjectSelector {
    public AccountPlanSelector() {
        super(false, true, false);
    }

    public static AccountPlanSelector newInstance() {
        return (AccountPlanSelector) Application.Selector.newInstance(Account_Plan__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account_Plan__c.Id,
            Account_Plan__c.Name,
            Account_Plan__c.Plan_Overview__c,
            Account_Plan__c.Plan_Overview_Title__c,
            Account_Plan__c.Account__c,
            Account_Plan__c.Status__c,
            Account_plan__c.OwnerId,
            Account_plan__c.Account_Plan_Score__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account_Plan__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/
    public List<pqcrush__Account_Plan__c> selectByLimit() {
        fflib_QueryFactory query = newQueryFactory().setLimit(5);

        return Database.query(query.toSOQL());
    }

    public List<pqcrush__Account_Plan__c> selectByName(String planName) {
        String escapedPlanName = String.escapeSingleQuotes(planName);
        fflib_QueryFactory query = newQueryFactory().setCondition('Name like \'%' + String.escapeSingleQuotes(planName) + '%\'');

        //query.addCondition('Name', fflib_QueryFactory.Operator.LIKE, '%' + planName + '%')

        // query.setLimit(i);

        return Database.query(query.toSOQL());
    }

    public List<pqcrush__Account_Plan__c> selectByIdWithName(String id) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id = :id');

        return Database.query(query.toSOQL());
    }

    public List<Account_Plan__c> selectById(Set<Id> ids) {
        return (List<Account_Plan__c>) selectSObjectsById(ids);
    }

    public List<Account_Plan__c> selectByIdAsSystem(Set<Id> ids) {
        return new SystemSelector().selectById(this, ids);
    }

    public List<Account_Plan__c> selectByStatus(String status) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Status__c = :status');
        return Database.query(query.toSOQL());
    }

    public List<Account_Plan__c> selectByAccountIds(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Account__c IN :ids');
        return Database.query(query.toSOQL());
    }

    public List<Account_Plan__c> selectByAccountIdsAsSystem(Set<Id> ids) {
        return new SystemSelector().selectByAccountIds(this, ids);
    }

    public List<Account_Plan__c> selectByIdWithHistory(Set<Id> ids) {
        try {
            fflib_QueryFactory queryFactory = newQueryFactory();
            FFLibHelper.subSelectHistories(queryFactory);

            return Database.query(queryFactory.setCondition('Id IN :ids').toSOQL());
        } catch (Exception e) {
            return new List<Account_Plan__c>();
        }
    }

    public List<Account_Plan__c> selectByIdWithTeamMembers(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id IN :ids');

        new TeamMemberSelector().addQueryFactorySubselect(query);
        return Database.query(query.toSOQL());
    }

    public List<Account_Plan__c> selectByIdWithSharesAsSystem(Set<Id> ids) {
        return new SystemSelector().selectByIdWithShares(this, ids);
    }

    public List<Account_Plan__c> selectByIdWithTeamMembersAdmin(Set<Id> ids) {
        return new SystemSelector().selectByIdWithTeamMembers(this, ids);
    }

    public List<Account_Plan__c> selectByIdWithAccountAndOwner(Set<Id> accountPlanIds) {
        fflib_QueryFactory accountPlanQueryFactory = newQueryFactory();
        AccountSelector.newInstance()
            .configureQueryFactoryFields(
                accountPlanQueryFactory,
                Account_Plan__c.Account__c.getDescribe().getRelationshipName()
            );
        UsersSelector.newInstance().configureQueryFactoryFields(accountPlanQueryFactory, 'Account__r.Owner');
        String condition = 'Id IN :accountPlanIds';
        return Database.query(accountPlanQueryFactory.setCondition(condition).toSOQL());
    }

    public List<Account_Plan__c> selectByIdWithAccountAndOwnerAndMasterAccountPlan(
        Set<Id> accountPlanIds,
        Id masterAccountPlanId
    ) {
        fflib_QueryFactory accountPlanQueryFactory = newQueryFactory();
        AccountSelector.newInstance()
            .configureQueryFactoryFields(
                accountPlanQueryFactory,
                Account_Plan__c.Account__c.getDescribe().getRelationshipName()
            );
        UsersSelector.newInstance().configureQueryFactoryFields(accountPlanQueryFactory, 'Account__r.Owner');
        String condition = 'Id IN :accountPlanIds';
        List<pqcrush__Master_Account_Plan_User_Setting__c> userSettings = MasterAccountPlanUserSettingSelector.newInstance()
            .selectForCurrentUserAndMasterAccountPlan(masterAccountPlanId);
        if (userSettings != null && userSettings.size() > 0) {
            if (userSettings[0].pqcrush__Show_Closed_Account_Plans__c == false) {
                condition += ' AND pqcrush__Status__c != \'Closed\'';
            }
        }
        return Database.query(accountPlanQueryFactory.setCondition(condition).toSOQL());
    }

    public List<Account_Plan__c> selectByAccountIdWithAccountAndOwner(Set<Id> accountIds, Id masterAccountPlanId) {
        fflib_QueryFactory accountPlanQueryFactory = newQueryFactory();
        AccountSelector.newInstance()
            .configureQueryFactoryFields(
                accountPlanQueryFactory,
                Account_Plan__c.Account__c.getDescribe().getRelationshipName()
            );
        UsersSelector.newInstance().configureQueryFactoryFields(accountPlanQueryFactory, 'Account__r.Owner');
        String condition = 'Account__c IN :accountIds';
        List<pqcrush__Master_Account_Plan_User_Setting__c> userSettings = MasterAccountPlanUserSettingSelector.newInstance()
            .selectForCurrentUserAndMasterAccountPlan(masterAccountPlanId);
        if (userSettings != null && userSettings.size() > 0) {
            if (userSettings[0].pqcrush__Show_Closed_Account_Plans__c == false) {
                condition += ' AND pqcrush__Status__c != \'Closed\'';
            }
        }
        return Database.query(accountPlanQueryFactory.setCondition(condition).toSOQL());
    }

    public List<Account_Plan__c> selectByOwnerIdAsSystem(Set<Id> ids) {
        return new SystemSelector().selectByOwnerId(this, ids);
    }

    public List<Account_Plan__c> selectAll() {
        return Database.query(newQueryFactory().toSOQL());
    }

    public List<Account_Plan__c> selectAllWithSharesAsSystem() {
        return new SystemSelector().selectAllWithShares(this);
    }

    public List<Account_Plan__c> selectClosedPlansById(Set<Id> ids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Id IN :ids AND pqcrush__Status__c = \'Closed\'');
        return Database.query(query.toSOQL());
    }

    public List<Account_Plan__c> selectSObjectsByIdWithHistory(Set<Id> ids) {
        try {
            fflib_QueryFactory queryFactory = newQueryFactory();
            FFLibHelper.subSelectHistories(queryFactory);

            return Database.query(queryFactory.setCondition('Id IN :ids').toSOQL());
        } catch (Exception e) {
            return new List<Account_Plan__c>();
        }
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    private with sharing class SystemSelector {
        public List<Account_Plan__c> selectById(AccountPlanSelector selector, Set<Id> ids) {
            return Database.query(selector.newQueryFactory(false, false, true).setCondition('id in :ids').toSOQL());
        }

        public List<Account_Plan__c> selectByOwnerId(AccountPlanSelector selector, Set<Id> ids) {
            return Database.query(
                selector.newQueryFactory(false, false, true).setCondition('OwnerId IN :ids').toSOQL()
            );
        }

        public List<Account_Plan__c> selectAllWithShares(AccountPlanSelector selector) {
            fflib_QueryFactory query = selector.newQueryFactory(false, false, true);
            new AccountPlanSharesSelector().ignoreCrud().addQueryFactorySubselect(query);
            return Database.query(query.toSOQL());
        }

        public List<Account_Plan__c> selectByAccountIds(AccountPlanSelector selector, Set<Id> ids) {
            return Database.query(
                selector.newQueryFactory(false, false, true).setCondition('Account__c IN :ids').toSOQL()
            );
        }

        public List<Account_Plan__c> selectByIdWithTeamMembers(AccountPlanSelector selector, Set<Id> ids) {
            Boolean assertCRUD = false;
            Boolean enforceFLS = false;
            Boolean includeSelectorFields = true;

            fflib_QueryFactory query = selector.newQueryFactory(assertCRUD, enforceFLS, includeSelectorFields)
                .setCondition('Id IN :ids');

            new TeamMemberSelector().ignoreCrud().addQueryFactorySubselect(query, true);
            return Database.query(query.toSOQL());
        }

        public List<Account_Plan__c> selectByIdWithShares(AccountPlanSelector selector, Set<Id> ids) {
            fflib_QueryFactory query = selector.newQueryFactory(false, false, true).setCondition('Id IN :ids');
            new AccountPlanSharesSelector().ignoreCrud().addQueryFactorySubselect(query);
            return Database.query(query.toSOQL());
        }
    }
}