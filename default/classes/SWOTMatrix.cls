public with sharing class SWOTMatrix {
    @AuraEnabled
    public SWOT_Analysis__c[] items;

    @AuraEnabled
    public Id strengthRecordTypeId;

    @AuraEnabled
    public Id weaknessRecordTypeId;

    @AuraEnabled
    public Id opportunityRecordTypeId;

    @AuraEnabled
    public Id threatRecordTypeId;

    @AuraEnabled
    public boolean canCreate;

    @AuraEnabled
    public boolean canUpdate;

    @AuraEnabled
    public boolean canDelete;

    @AuraEnabled
    public String strengthLabel;

    @AuraEnabled
    public String weaknessLabel;

    @AuraEnabled
    public String opportunityLabel;

    @AuraEnabled
    public String threatLabel;

    public SWOTMatrix() {
        this(new List<SWOT_Analysis__c>{});
    }

    public SWOTMatrix(SWOT_Analysis__c[] items) {
        this.items = items;
        this.canCreate = true;
        this.canUpdate = true;
        this.canDelete = true;

        try {
            fflib_SecurityUtils.checkInsert(
                SWOT_Analysis__c.SObjectType,
                new List<SObjectField>{ SWOT_Analysis__c.Name, SWOT_Analysis__c.Description_Rich_Text__c }
            );
        } catch (Exception e) {
            this.canCreate = false;
        }

        try {
            fflib_SecurityUtils.checkUpdate(
                SWOT_Analysis__c.SObjectType,
                new List<SObjectField>{ SWOT_Analysis__c.Name, SWOT_Analysis__c.Description_Rich_Text__c }
            );
        } catch (Exception e) {
            this.canUpdate = false;
        }

        try {
            fflib_SecurityUtils.checkObjectIsDeletable(SWOT_Analysis__c.SObjectType);
        } catch (Exception e) {
            this.canDelete = false;
        }

        Map<String, Schema.RecordTypeInfo> recordTypesByName = SWOT_Analysis__c.SObjectType.getDescribe()
            .getRecordTypeInfosByDeveloperName();
        this.strengthRecordTypeId = recordTypesByName.get('Strength').getRecordTypeId();
        this.weaknessRecordTypeId = recordTypesByName.get('Weakness').getRecordTypeId();
        this.opportunityRecordTypeId = recordTypesByName.get('Opportunity').getRecordTypeId();
        this.threatRecordTypeId = recordTypesByName.get('Threat').getRecordTypeId();

        this.strengthLabel = recordTypesByName.get('Strength').getName();
        this.weaknessLabel = recordTypesByName.get('Weakness').getName();
        this.opportunityLabel = recordTypesByName.get('Opportunity').getName();
        this.threatLabel = recordTypesByName.get('Threat').getName();
    }
}