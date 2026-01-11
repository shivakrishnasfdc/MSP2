public with sharing class OrganizationInfo {
    public Id organizationId { get; set; }
    public String accountAccess { get; set; }

    public OrganizationInfo(Organization org) {
        this.organizationId = org.Id;
        this.accountAccess = org.DefaultAccountAccess;
    }
}