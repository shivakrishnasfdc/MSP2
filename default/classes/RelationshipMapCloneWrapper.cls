@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class RelationshipMapCloneWrapper {
    @InvocableVariable(required=true)
    global Id mapId;

    @InvocableVariable
    global Id newRelatedObjId; //Important - setting directly will not setup the relatedField, either do that as well or use the init method

    @InvocableVariable
    global String newName;

    @InvocableVariable
    global Id newOwnerId;

    public Relationship_Map__c clonedMap;
    public Schema.SObjectType relatedFieldObjType;
    public Schema.SObjectField relatedField;

    public List<String> relationships {
        get {
            if (relationships == null || relationships.size() <= 0) {
                relationships = new List<String>{
                    RelationshipMapCloneService.MAP_MEMBER_RELATIONSHIP_NAME,
                    RelationshipMapCloneService.MAP_MEMBER_LEADS_RELATIONSHIP_NAME,
                    RelationshipMapCloneService.CUSTOM_RELATIONSHIP_LINE_RELATIONSHIP_NAME,
                    RelationshipMapCloneService.MATRIX_RELATIONSHIP_NAME,
                    RelationshipMapCloneService.PLACEHOLDER_RELATIONSHIP_NAME,
                    RelationshipMapCloneService.RM_SETTINGS_RELATIONSHIP_NAME,
                    RelationshipMapCloneService.RM_BADGE_ACCOUNT_PLAN_ASSOC_NAME,
                    RelationshipMapCloneService.RELATIONSHIP_TYPE_MAP_ASSOC_NAME
                };
            }
            return relationships;
        }
        set;
    }

    global RelationshipMapCloneWrapper() {
        this(null, null, null, null);
    }

    global RelationshipMapCloneWrapper(Id mapId, String name, Id ownerId, Id relatedObjId) {
        this.mapId = mapId;
        this.newName = name;
        this.newOwnerId = ownerId;
        this.newRelatedObjId = relatedObjId;
        setRelatedField();
    }

    public void validationCheck() {
        if (mapId == null) {
            throw Application.genericException('No map information passed when trying to clone a Relationship Map');
        }
    }

    private void setRelatedField() {
        this.relatedFieldObjType = null;
        this.relatedField = null;
        if (this.newRelatedObjId == null) {
            return;
        }
        Schema.SObjectType objType = this.newRelatedObjId.getSobjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        //Find field from the object
        Set<Schema.SObjectField> objRelationshipFields = SObjectService.relationshipsFromDescribeMatchingObjectType(
            objDescribe,
            pqcrush__Relationship_Map__c.sObjectType
        );
        if (objRelationshipFields != null && objRelationshipFields.size() > 0) {
            List<Schema.SObjectField> objFieldList = new List<Schema.SObjectField>(objRelationshipFields);
            this.relatedFieldObjType = objType;
            this.relatedField = objFieldList[0];
            return;
        }

        //Find field from the map
        objRelationshipFields = SObjectService.relationshipsFromDescribeMatchingObjectType(
            pqcrush__Relationship_Map__c.sObjectType.getDescribe(),
            objType
        );
        if (objRelationshipFields != null && objRelationshipFields.size() > 0) {
            List<Schema.SObjectField> objFieldList = new List<Schema.SObjectField>(objRelationshipFields);
            this.relatedFieldObjType = pqcrush__Relationship_Map__c.sObjectType;
            this.relatedField = objFieldList[0];
        }
    }

    global Boolean equals(Object obj) {
        if (obj == null || !(obj instanceof RelationshipMapCloneWrapper)) {
            return false;
        }

        RelationshipMapCloneWrapper other = (RelationshipMapCloneWrapper) obj;

        return other.mapId == this.mapId &&
            other.newRelatedObjId == this.newRelatedObjId &&
            other.newOwnerId == this.newOwnerId &&
            other.newName == this.newName;
    }

    global Integer hashCode() {
        String planString = String.valueOf(mapId);
        Integer planHash = planString == null ? 1 : planString.hashCode();

        String accountString = String.valueOf(newRelatedObjId);
        Integer accountHash = accountString == null ? 1 : accountString.hashCode();

        String ownerString = String.valueOf(newOwnerId);
        Integer ownerHash = ownerString == null ? 1 : ownerString.hashCode();

        Integer nameHash = newName == null ? 1 : newName.hashCode();

        return planHash * accountHash * ownerHash * nameHash;
    }
}