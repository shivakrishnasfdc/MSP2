@SuppressWarnings('PMD.NcssMethodCount,PMD.AvoidGlobalModifier')
global with sharing class RelationshipMapCloneService {
    public static final String MAP_MEMBER_RELATIONSHIP_NAME = 'pqcrush__Members__r';
    public static final String MAP_MEMBER_LEADS_RELATIONSHIP_NAME = 'pqcrush__Map_Member_Leads__r';
    public static final String CUSTOM_RELATIONSHIP_LINE_RELATIONSHIP_NAME = 'pqcrush__Contact_Relationships__r';
    public static final String PLACEHOLDER_RELATIONSHIP_NAME = 'pqcrush__Map_Member_Placeholders__r';
    public static final String ANCHOR_RELATIONSHIP_NAME = 'pqcrush__RM_Anchors__r';
    public static final String MATRIX_RELATIONSHIP_NAME = 'pqcrush__Relationship_Maps_that_use_this_matrix__r';
    public static final String RM_SETTINGS_RELATIONSHIP_NAME = 'pqcrush__RM_Chart_Settings__r';
    public static final String NODE_COORDINATE_RELATIONSHIP_NAME = 'pqcrush__RM_Node_Coordinates__r';
    public static final String RM_GROUP_RELATIONSHIP_NAME = 'pqcrush__Relationship_Groups__r';
    public static final String RM_BADGE_ACCOUNT_PLAN_ASSOC_NAME = 'pqcrush__RM_Svg_Map_Associations__r';
    public static final String RM_BADGE_NODE_ASSOC_NAME = 'pqcrush__RM_Svg_Node_Associations__r';
    public static final String RELATIONSHIP_TYPE_MAP_ASSOC_NAME = 'pqcrush__Relationship_Type_Map_Associations__r';

    @InvocableMethod(
        label='Clone Relationship Maps'
        description='Clones a list of Relationship Maps based on the data passed in to cloneWrappers'
    )
    global static List<Relationship_Map__c> cloneRelationshipMaps(List<RelationshipMapCloneWrapper> cloneWrappers) {
        return service().cloneRelationshipMaps(cloneWrappers, null, null, true);
    }

    public static List<Relationship_Map__c> cloneRelationshipMaps(
        List<RelationshipMapCloneWrapper> cloneWrappers,
        List<SObject> clonedRelatedObjs,
        Set<Schema.SObjectType> relatedObjectTypes,
        Boolean startBatches
    ) {
        return service().cloneRelationshipMaps(cloneWrappers, clonedRelatedObjs, relatedObjectTypes, startBatches);
    }

    private static RelationshipMapCloneServiceImpl service() {
        return (RelationshipMapCloneServiceImpl) Application.Service.newInstance(RelationshipMapCloneServiceImpl.class);
    }
}