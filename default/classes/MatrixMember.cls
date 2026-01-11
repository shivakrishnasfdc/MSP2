@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
public with sharing class MatrixMember {
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public Id personId;

    @AuraEnabled
    public String firstName;

    @AuraEnabled
    public String lastName;

    @AuraEnabled
    public String name;

    @AuraEnabled
    public String influenceLabel;

    @AuraEnabled
    public String supportLabel;

    @AuraEnabled
    public String influenceOverrideValue;

    @AuraEnabled
    public String supportOverrideValue;

    @AuraEnabled
    public String influence;

    @AuraEnabled
    public String support;

    @AuraEnabled
    public String supportColor;

    @AuraEnabled
    public String title;

    @AuraEnabled
    public String containerName;

    @AuraEnabled
    public Id containerId;

    @AuraEnabled
    public Boolean containerIsClosed;

    @AuraEnabled
    public Boolean isUsingGlobalInfluence;

    @AuraEnabled
    public datetime createdDate;

    @AuraEnabled
    public List<MatrixMemberAdditionalField> additionalFields;

    public MatrixMember(Key_Stakeholder__c keyStakeholder) {
        this.id = keyStakeholder.Id;
        this.personId = keyStakeholder.Contact__c;
        this.firstName = keyStakeholder.Contact__r.FirstName;
        this.lastName = keyStakeholder.Contact__r.LastName;
        this.name = keyStakeholder.Contact__r.Name;
        this.influence = keyStakeholder.InfluenceId__r.Name;
        this.support = keyStakeholder.SupportId__r.Name;
        this.supportColor = keyStakeholder.SupportId__r.Color__c;

        Map<String, Object> contactMap = keyStakeholder?.Contact__r?.getPopulatedFieldsAsMap();
        this.title = (String) contactMap?.get('Title');

        this.containerName = keyStakeholder.Account_Plan__r.Name;
        this.containerId = keyStakeholder.Account_Plan__c;
        this.containerIsClosed = keyStakeholder.Account_Plan__r.Status__c == 'Closed';
        this.isUsingGlobalInfluence = false;
    }

    public MatrixMember(Key_Stakeholder__c keyStakeholder, String influence, String support) {
        this(keyStakeholder);
        this.influence = influence;
        this.support = support;
    }

    public MatrixMember(Key_Stakeholder__c keyStakeholder, List<MatrixMemberAdditionalField> additionalFields) {
        this(keyStakeholder);
        this.additionalFields = additionalFields;
    }

    public MatrixMember(
        Key_Stakeholder__c keyStakeholder,
        String influence,
        String support,
        List<MatrixMemberAdditionalField> additionalFields
    ) {
        this(keyStakeholder);
        this.influence = influence;
        this.support = support;
        this.additionalFields = additionalFields;
    }

    public MatrixMember(Relationship_Map_Member__c mapMember) {
        this.id = mapMember.Id;
        this.personId = mapMember.Contact__c;
        this.firstName = mapMember.Contact__r.FirstName;
        this.lastName = mapMember.Contact__r.LastName;
        this.name = mapMember.Contact__r.Name;
        this.influence = mapMember.InfluenceId__r.Name;
        this.support = mapMember.SupportId__r.Name;
        this.influenceOverrideValue = mapMember.InfluenceId__r.Label__c;
        this.supportOverrideValue = mapMember.SupportId__r.Label__c;
        this.supportColor = mapMember.SupportId__r.Color__c;

        Map<String, Object> contactMap = mapMember.Contact__r?.getPopulatedFieldsAsMap();
        this.title = (String) contactMap?.get('Title');

        this.containerName = mapMember.Relationship_Map__r.Name;
        this.containerId = mapMember.Relationship_Map__c;
        this.containerIsClosed = false;
        this.isUsingGlobalInfluence = false;
        this.createdDate = mapMember.CreatedDate;
    }

    public MatrixMember(Relationship_Map_Member__c mapMember, String influence, String support) {
        this(mapMember);
        this.influence = influence;
        this.support = support;
    }

    public MatrixMember(Relationship_Map_Member__c mapMember, List<MatrixMemberAdditionalField> additionalFields) {
        this(mapMember);
        this.additionalFields = additionalFields;
    }

    public MatrixMember(
        Relationship_Map_Member__c mapMember,
        String influence,
        String support,
        List<MatrixMemberAdditionalField> additionalFields
    ) {
        this(mapMember);
        this.influence = influence;
        this.support = support;
        this.additionalFields = additionalFields;
    }
}