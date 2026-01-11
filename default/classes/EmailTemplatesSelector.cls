public with sharing class EmailTemplatesSelector extends fflib_SObjectSelector {
    public static EmailTemplatesSelector newInstance() {
        return (EmailTemplatesSelector) Application.Selector.newInstance(EmailTemplate.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ EmailTemplate.Id, EmailTemplate.DeveloperName };
    }

    public Schema.SObjectType getSObjectType() {
        return EmailTemplate.sObjectType;
    }

    public List<EmailTemplate> selectById(Set<ID> idSet) {
        return (List<EmailTemplate>) selectSObjectsById(idSet);
    }

    public List<EmailTemplate> selectByDeveloperNames(List<String> developerNames) {
        return Database.query(newQueryFactory().setCondition('DeveloperName IN :developerNames').toSOQL());
    }
}