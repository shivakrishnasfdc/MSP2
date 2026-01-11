public with sharing class History implements Comparable {
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public Id createdById;

    @AuraEnabled
    public String createdByName;

    @AuraEnabled
    public Id parentId;

    @AuraEnabled
    public String parentName;

    @AuraEnabled
    public String parentObjectName;

    @AuraEnabled
    public String parentObjectLabel;

    @AuraEnabled
    public Datetime createdDateTime;

    @AuraEnabled
    public String fieldName;

    @AuraEnabled
    public String fieldLabel;

    @AuraEnabled
    public Object newValue;

    @AuraEnabled
    public Object oldValue;

    @AuraEnabled
    public String color;

    @AuraEnabled
    public String iconUrl;

    public History(SObject historyObject) {
        this.id = historyObject.Id;
        this.newValue = historyObject.get('NewValue');
        this.oldValue = historyObject.get('OldValue');
        this.createdDateTime = (Datetime) historyObject.get('CreatedDate');

        this.parentId = (Id) historyObject.get('ParentId');

        setupParentName(historyObject);

        this.createdById = (Id) historyObject.get('CreatedById');
        this.createdByName = (String) historyObject.getSObject('CreatedBy').get('Name');

        Schema.SObjectType parentObjectType = this.parentId.getSObjectType();
        this.parentObjectName = parentObjectType.getDescribe().getName();
        this.parentObjectLabel = parentObjectType.getDescribe().getLabel();

        this.fieldName = (String) historyObject.get('Field');
        Map<String, Schema.SObjectField> fieldMap = this.parentId.getSObjectType().getDescribe().fields.getMap();
        this.fieldLabel = fieldMap.containsKey(fieldName.toLowerCase())
            ? fieldMap.get(fieldName.toLowerCase()).getDescribe().getLabel()
            : null;
    }

    public Integer compareTo(Object compareTo) {
        History compareToHistory = (History) compareTo;

        if (this.createdDateTime < compareToHistory.createdDateTime) {
            return 1;
        } else if (this.createdDateTime > compareToHistory.createdDateTime) {
            return -1;
        }

        return 0;
    }

    private void setupParentName(SObject historyObject) {
        if (
            this.parentId.getSObjectType().getDescribe().getName() ==
            Account_Plan_Opportunity__c.SObjectType.getDescribe().getName()
        ) {
            this.parentName = (String) historyObject.getSObject('Parent').getSObject('Opportunity__r').get('Name');
        } else if (
            this.parentId.getSObjectType().getDescribe().getName() ==
            Key_Stakeholder__c.SObjectType.getDescribe().getName()
        ) {
            this.parentName = (String) historyObject.getSObject('Parent').getSObject('Contact__r').get('Name');
        } else if (
            this.parentId.getSObjectType().getDescribe().getName() ==
            Objective_Opportunity__c.SObjectType.getDescribe().getName()
        ) {
            this.parentName = (String) historyObject.getSObject('Parent').getSObject('Opportunity__r').get('Name');
        } else if (
            this.parentId.getSObjectType().getDescribe().getName() == Team_Member__c.SObjectType.getDescribe().getName()
        ) {
            this.parentName = (String) historyObject.getSObject('Parent').getSObject('User__r').get('Name');
        } else {
            this.parentName = (String) historyObject.getSObject('Parent').get('Name');
        }
    }
}