public with sharing class AccountPlanSharesSelector extends fflib_SObjectSelector {
    public static final String ACCOUNT_PLAN_TEAM_SHARE_REASON = Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c;
    public static final String ACCOUNT_TEAM_SHARE_REASON = Schema.Account_Plan__Share.RowCause.AccountTeam__c;
    public static final String ACCOUNT_PLAN_OWNER = 'owner';

    public AccountPlanSharesSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            true
        ); // Enforce Field level security
    }

    /******************************
     *      STATIC METHODS
     ******************************/

    public static AccountPlanSharesSelector newInstance() {
        return (AccountPlanSharesSelector) Application.Selector.newInstance(Account_Plan__Share.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account_Plan__Share.AccessLevel,
            Account_Plan__Share.ParentId,
            Account_Plan__Share.UserOrGroupId,
            Account_Plan__Share.RowCause
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account_Plan__Share.sObjectType;
    }

    public override String getOrderBy() {
        return Account_Plan__Share.UserOrGroupId.getDescribe().getName();
    }

    /******************************
     *       SELECT METHODS
     ******************************/

    /**
     * Returns a list of Account_Plan__Share records that correspond to the given
     * set of Account Plan Ids
     * @param idSet The account plans
     * @return List<Account_Plan__Share> The account plan shares
     */
    public List<Account_Plan__Share> selectByAccountPlanIdsAsSystem(Set<Id> accountPlanIds) {
        return new SystemSelector().selectByAccountPlanIds(this, accountPlanIds);
    }

    public List<Account_Plan__Share> selectTeamShareAndOwnersByIds(Set<Id> accountPlanIds) {
        return Database.query(
            newQueryFactory()
                .setCondition(
                    'ParentId IN :accountPlanIds ' +
                    'AND RowCause IN (:ACCOUNT_PLAN_TEAM_SHARE_REASON, :ACCOUNT_PLAN_OWNER)'
                )
                .toSOQL()
        );
    }

    public List<Account_Plan__Share> selectByAccoundPlanIdsAndUserIdsAsSystem(
        Set<Id> accountPlanIds,
        Set<Id> userIds,
        String rowCause
    ) {
        return new SystemSelector().selectByAccoundPlanIdsAndUserIds(this, accountPlanIds, userIds, rowCause);
    }

    /**
     * Returns a list of Account_Plan__Share records that correspond to the given
     * Team_Member__c objects (there should be a 1-to-1 mapping between the two).
     * @param  teamMembers A list of User to Account Plan junction objects.
     * @return             The corresponding Account_Plan__Share recrods for the team members.
     */
    public List<Account_Plan__Share> selectByTeamMembers(List<Team_Member__c> teamMembers) {
        Set<Id> accountPlanIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<Id, Set<Id>> userIdsByAccountPlanId = new Map<Id, Set<Id>>();

        for (Team_Member__c teamMember : teamMembers) {
            if (userIdsByAccountPlanId.get(teamMember.Account_Plan__c) == null) {
                userIdsByAccountPlanId.put(teamMember.Account_Plan__c, new Set<Id>());
            }

            accountPlanIds.add(teamMember.Account_Plan__c);
            userIds.add(teamMember.User__c);
            userIdsByAccountPlanId.get(teamMember.Account_Plan__c).add(teamMember.User__c);
        }

        /**
         * We still have to do some additional filtering after this query (because it can return
         * additional results in the scenario that is outlined below), but we'll use this result
         * set as a starting point for the final return values.
         *
         * Example scenario:
         *
         *   User ID | Account Plan ID
         *  ---------------------------
         *      1    |       A
         *      2    |       A      <----- target record
         *      1    |       B      <----- target record
         *      2    |       B
         *
         * Querying for the 2 target records will result in a WHERE clause that looks like
         *
         *     WHERE User ID in (1, 2) and Account Plan ID in (A, B)
         *
         * In this scenario that query would end up returning all records, so we have to
         * do some post processing after running the query.
         */
        List<Account_Plan__Share> initialResults = Database.query(
            newQueryFactory()
                .setCondition(
                    'ParentId IN :accountPlanIds ' +
                    'AND UserOrGroupId IN :userIds ' +
                    'AND RowCause = :ACCOUNT_PLAN_TEAM_SHARE_REASON'
                )
                .toSOQL()
        );

        List<Account_Plan__Share> finalResults = new List<Account_Plan__Share>();

        for (Account_Plan__Share share : initialResults) {
            Set<Id> userIdsForAccountPlan = userIdsByAccountPlanId.get(share.ParentId);

            // only include a record if that specific User/Account Plan combination was represented
            // by one of the Team_Member__c records that was passed in
            if (userIdsForAccountPlan != null && userIdsForAccountPlan.contains(share.UserOrGroupId)) {
                finalResults.add(share);
            }
        }

        return finalResults;
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    private with sharing class SystemSelector {
        public List<Account_Plan__Share> selectByAccoundPlanIdsAndUserIds(
            AccountPlanSharesSelector selector,
            Set<Id> accountPlanIds,
            Set<Id> userIds,
            String rowCause
        ) {
            return Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition(
                        'ParentId IN :accountPlanIds ' +
                        'AND UserOrGroupId in :userIds ' +
                        'AND RowCause = :rowCause'
                    )
                    .toSOQL()
            );
        }

        public List<Account_Plan__Share> selectByAccountPlanIds(
            AccountPlanSharesSelector selector,
            Set<Id> accountPlanIds
        ) {
            return Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition(
                        'ParentId IN :accountPlanIds ' +
                        'AND RowCause in (:ACCOUNT_PLAN_TEAM_SHARE_REASON, :ACCOUNT_TEAM_SHARE_REASON)'
                    )
                    .toSOQL()
            );
        }
    }
}