@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class FeatureFlagController {
    @AuraEnabled
    public static Boolean hasCrushAccess() {
        return System.FeatureManagement.checkPackageBooleanValue('pqcrush__Crush_Access');
    }

    @AuraEnabled
    public static Boolean hasRelationshipMapAccess() {
        return System.FeatureManagement.checkPackageBooleanValue('pqcrush__Relationship_Map_Access');
    }

    @AuraEnabled
    public static Boolean hasOpportunityPlanAccess() {
        return System.FeatureManagement.checkPackageBooleanValue('pqcrush__OppPlan_Access');
    }

    @AuraEnabled
    public static Boolean isLicensed() {
        Boolean isPkgInstalled = new SystemSelector().isPackagedInstalled();
        if (isPkgInstalled) {
            return UserInfo.isCurrentUserLicensed('pqcrush');
        }
        return true;
    }

    private with sharing class SystemSelector {
        public Boolean isPackagedInstalled() {
            List<PackageLicense> pkgs = [SELECT Id, Status FROM PackageLicense WHERE NamespacePrefix = 'pqcrush' WITH SECURITY_ENFORCED];
            if (pkgs != null && pkgs.size() > 0) {
                return true;
            }
            return false;
        }
    }
}