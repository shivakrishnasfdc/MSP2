@SuppressWarnings('PMD.NcssMethodCount,PMD.AvoidGlobalModifier')
global with sharing class AccountPlanCloneService {
    public static final String WHITE_SPACE_RELATIONSHIP_NAME = 'pqcrush__White_Spaces__r';
    public static final String TEAM_MEMBERS_RELATIONSHIP_NAME = 'pqcrush__Team_Members__r';
    public static final String OBJECTIVES_RELATIONSHIP_NAME = 'pqcrush__Objectives__r';
    public static final String SWOT_ANALYSIS_RELATIONSHIP_NAME = 'pqcrush__SWOT_Analysis__r';
    public static final String ACCOUNT_PLAN_OPPORTUNITIES_RELATIONSHIP_NAME = 'pqcrush__Account_Plan_Opportunities__r';
    public static final String KEY_DATES_RELATIONSHIP_NAME = 'pqcrush__Key_Dates__r';
    public static final String KEY_STAKEHOLDERS_RELATIONSHIP_NAME = 'pqcrush__Key_Stakeholders__r';
    public static final String KEY_STAKEHOLDER_LEADS_RELATIONSHIP_NAME = 'pqcrush__Key_Stakeholder_Leads__r';
    public static final String CUSTOM_RELATIONSHIP_LINE_RELATIONSHIP_NAME = 'pqcrush__Contact_Relationships__r';
    public static final String PLACEHOLDER_RELATIONSHIP_NAME = 'pqcrush__Map_Member_Placeholders__r';
    public static final String MATRIX_RELATIONSHIP_NAME = 'pqcrush__Account_Plans_that_use_this_matrix__r';
    public static final String ANCHOR_RELATIONSHIP_NAME = 'pqcrush__RM_Anchors__r';
    public static final String RM_SETTINGS_RELATIONSHIP_NAME = 'pqcrush__RM_Chart_Settings__r';
    public static final String NODE_COORDINATE_RELATIONSHIP_NAME = 'pqcrush__RM_Node_Coordinates__r';
    public static final String RM_GROUP_RELATIONSHIP_NAME = 'pqcrush__Relationship_Groups__r';
    public static final String RM_BADGE_ACCOUNT_PLAN_ASSOC_NAME = 'pqcrush__RM_Svg_Account_Plan_Associations__r';
    public static final String RM_BADGE_NODE_ASSOC_NAME = 'pqcrush__RM_Svg_Node_Associations__r';
    public static final String RELATIONSHIP_TYPE_ACCOUNT_PLAN_ASSOC_NAME = 'pqcrush__Relationship_Type_Account_Plan_Assocs__r';
    public static final String RELATIONSHIP_MAP_RELATIONSHIP_NAME = 'pqcrush__Relationship_Maps__r';

    @InvocableMethod(
        label='Clone Account Plans'
        description='Clones a list of account plans based on the data passed in to cloneWrappers'
    )
    global static List<Account_Plan__c> cloneAccountPlans(List<AccountPlanCloneWrapper> cloneWrappers) {
        return service().cloneAccountPlans(cloneWrappers);
    }

    private static AccountPlanCloneServiceImpl service() {
        return (AccountPlanCloneServiceImpl) Application.Service.newInstance(AccountPlanCloneServiceImpl.class);
    }
}