public with sharing class TeamMemberSelector extends AccountPlanChildSelector {
    public static final Set<String> HISTORY_FIELDS = new Set<String>{ 'Parent.User__r.Name' };

    public TeamMemberSelector() {
        super(
            false, // Do not include FieldSet fields
            true, // Enforce Object level security
            false
        ); // Enforce Field level security
    }

    /******************************
     *      STATIC METHODS
     ******************************/

    public static TeamMemberSelector newInstance() {
        return (TeamMemberSelector) Application.Selector.newInstance(Team_Member__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Team_Member__c.Id,
            Team_Member__c.Account_Plan__c,
            Team_Member__c.User__c,
            Team_Member__c.Role__c,
            Team_Member__c.CreatedDate
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Team_Member__c.sObjectType;
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<Team_Member__c> selectById(Set<Id> ids) {
        return (List<Team_Member__c>) selectSObjectsById(ids);
    }

    public List<Team_Member__c> selectByAccountPlanIds(Set<Id> accountPlanIds) {
        return Database.query(newQueryFactory().setCondition('Account_Plan__c IN :accountPlanIds').toSOQL());
    }

    public List<Team_Member__c> selectByAccountPlanIdsAsSystem(Set<Id> accountPlanIds) {
        return new SystemSelector().selectByAccountPlanIds(this, accountPlanIds);
    }

    public List<Team_Member__c> selectByAccountPlanIdAndUserIdAsSystem(Set<Id> accountPlanIds, Set<Id> userIds) {
        return new SystemSelector().selectByAccountPlanIdAndUserId(this, accountPlanIds, userIds);
    }

    /**
     * Returns items in records that are duplicates of records already in the system.
     * Records are considered duplicates if they have the same User__c and Account_Plan__c.
     * @param  records A list of Team_Member__c objects to check against existing records.
     * @return             Any of the original teamMember records that are duplicates.
     */
    public List<Team_Member__c> selectDuplicatesAsSystem(List<Team_Member__c> records) {
        return new SystemSelector().selectDuplicates(this, records);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    private with sharing class SystemSelector {
        private List<Team_Member__c> selectByAccountPlanIds(TeamMemberSelector selector, Set<Id> accountPlanIds) {
            return Database.query(
                selector.newQueryFactory(false, false, true).setCondition('Account_Plan__c IN :accountPlanIds').toSOQL()
            );
        }

        private List<Team_Member__c> selectByAccountPlanIdAndUserId(
            TeamMemberSelector selector,
            Set<Id> accountPlanIds,
            Set<Id> userIds
        ) {
            return Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition('Account_Plan__c IN :accountPlanIds AND User__c In :userIds')
                    .toSOQL()
            );
        }

        private List<Team_Member__c> selectDuplicates(TeamMemberSelector selector, List<Team_Member__c> records) {
            Set<Id> accountPlanIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Map<String, Team_Member__c> recordsByUniqueKey = new Map<String, Team_Member__c>();

            for (Team_Member__c teamMember : records) {
                accountPlanIds.add(teamMember.Account_Plan__c);
                userIds.add(teamMember.User__c);
                recordsByUniqueKey.put(TeamMembers.getUniqueKey(teamMember), teamMember);
            }

            List<Team_Member__c> potentialDuplicates = Database.query(
                selector.newQueryFactory(false, false, true)
                    .setCondition('User__c in :userIds ' + 'AND Account_Plan__c in :accountPlanIds')
                    .toSOQL()
            );

            List<Team_Member__c> duplicates = new List<Team_Member__c>();

            for (Team_Member__c potentialDuplicate : potentialDuplicates) {
                Team_Member__c duplicateMember = recordsByUniqueKey.get(TeamMembers.getUniqueKey(potentialDuplicate));

                if (duplicateMember != null && potentialDuplicate.Id != duplicateMember.Id) {
                    duplicates.add(duplicateMember);
                }
            }

            return duplicates;
        }
    }
}