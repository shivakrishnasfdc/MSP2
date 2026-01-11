@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class WhiteSpaceDisplayFieldDataWrapper {
    @AuraEnabled
    public Object value { get; set; }
    @AuraEnabled
    public String displayName { get; set; }
    @AuraEnabled
    public Id objectId { get; set; }
    @AuraEnabled
    public Id secondaryObjectId { get; set; }

    public WhiteSpaceDisplayFieldDataWrapper() {
    }

    public WhiteSpaceDisplayFieldDataWrapper(Object value, String displayName, Id objectId) {
        this(value, displayName, objectId, null);
    }

    public WhiteSpaceDisplayFieldDataWrapper(Object value, String displayName, Id objectId, Id secondaryObjectId) {
        this.value = value;
        this.displayName = displayName;
        this.objectId = objectId;
        this.secondaryObjectId = secondaryObjectId;
    }

    public WhiteSpaceDisplayFieldDataWrapper(String displayName, Id objectId) {
        this('', displayName, objectId);
    }

    public White_Space_Amount_Type_Association__c toAssociationWithDisplayFieldId(Id amountTypeId, Id cellId) {
        Schema.SObjectType type = null;
        if (objectId != null) {
            type = objectId.getSobjectType();
        }
        if (type == White_Space_Amount_Type_Association__c.SObjectType || type == null) {
            Decimal decimalValue = 0;
            if (value instanceof String) {
                String stringValue = (String) value;
                decimalValue = Decimal.valueOf(stringValue);
            } else {
                decimalValue = (Decimal) value;
            }
            return new White_Space_Amount_Type_Association__c(
                Id = objectId,
                pqcrush__Amount__c = decimalValue,
                pqcrush__White_Space_Amount_Type__c = amountTypeId,
                pqcrush__White_Space_Cell__c = cellId
            );
        }
        return null;
    }
}