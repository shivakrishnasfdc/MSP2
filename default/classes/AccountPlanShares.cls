@SuppressWarnings('PMD.ApexDangerousMethods')
public with sharing class AccountPlanShares extends fflib_SObjectDomain {
    public static final String ACCESS_READ_WRITE = 'Edit';
    public static final String ACCESS_READ_ONLY = 'Read';

    public AccountPlanShares(List<Account_Plan__Share> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    /******************************
     *       STATIC METHODS
     ******************************/

    public static AccountPlanShares newInstance(List<Account_Plan__Share> sObjectList) {
        return (AccountPlanShares) Application.Domain.newInstance(sObjectList);
    }

    public static String getUniqueKey(Account_Plan__Share shareRecord) {
        return String.valueOf(shareRecord.ParentId) + String.valueOf(shareRecord.UserOrGroupId);
    }

    public static String calculateAccessLevel(Team_Member__c teamMember) {
        if (teamMember.Role__c == TeamMembers.ROLE_READ_WRITE || teamMember.Role__c == TeamMembers.ROLE_OWNER) {
            return ACCESS_READ_WRITE;
        }

        return ACCESS_READ_ONLY;
    }

    public static String calculateAccessLevel(Team_Member__c teamMember, Account_Plan__c accountPlan) {
        if (teamMember.User__c == accountPlan.OwnerId) {
            return ACCESS_READ_WRITE;
        } else if (accountPlan.Status__c == AccountPlans.STATUS_CLOSED) {
            return ACCESS_READ_ONLY;
        }

        return calculateAccessLevel(teamMember);
    }

    /******************************
     *       PUBLIC METHODS
     ******************************/

    public void setReadOnly(fflib_ISObjectUnitOfWork unitOfWork) {
        for (Account_Plan__Share record : (List<Account_Plan__Share>) records) {
            record.AccessLevel = 'Read';
        }

        unitOfWork.registerDirty(records);
    }

    /******************************
     *       INNER CLASSES
     ******************************/

    /**
     * This is a workaround for the lack of reflection in Apex.
     */
    public with sharing class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AccountPlanShares(sObjectList);
        }
    }
}