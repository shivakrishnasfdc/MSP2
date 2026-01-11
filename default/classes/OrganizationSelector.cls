public with sharing class OrganizationSelector extends fflib_SObjectSelector {
    public static OrganizationSelector newInstance() {
        return (OrganizationSelector) Application.Selector.newInstance(Organization.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Organization.Id, Organization.DefaultAccountAccess };
    }

    public Schema.SObjectType getSObjectType() {
        return Organization.sObjectType;
    }

    /**
     * Returns the single Organization object wrapped in the OrganizationInfo class
     */
    public OrganizationInfo selectSingle() {
        List<Organization> orgList = Database.query(newQueryFactory().toSOQL());

        Organization myOrg = orgList.get(0);

        return new OrganizationInfo(myOrg);
    }
}