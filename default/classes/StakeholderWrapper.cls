public with sharing class StakeholderWrapper implements IRelationshipMapObject {
    Key_Stakeholder__c stakeholder;

    public Id id() {
        return stakeholder.Id;
    }

    public Id contactId() {
        return stakeholder.pqcrush__Contact__c;
    }

    public String contactFirstName() {
        return stakeholder.pqcrush__ContactFirstName__c;
    }

    public String contactLastName() {
        return stakeholder.pqcrush__ContactLastName__c;
    }

    public Id parentId() {
        return stakeholder.pqcrush__ReportsToId__c;
    }

    public String objectName() {
        return Key_Stakeholder__c.sObjectType.getDescribe().getName();
    }

    public String influence() {
        return String.valueOf(stakeholder.pqcrush__InfluenceId__r.Name);
    }

    public String support() {
        return String.valueOf(stakeholder.pqcrush__SupportId__r.Name);
    }

    public String supportColor() {
        return String.valueOf(stakeholder.pqcrush__SupportId__r.Color__c);
    }

    public Object get(String key) {
        return stakeholder.get(key);
    }

    public stakeholderWrapper(Key_Stakeholder__c keyStakeholder) {
        this.stakeholder = keyStakeholder;
    }
}