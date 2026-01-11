@IsTest
public class FeatureFlagControllerTest {
    @IsTest
    static void hasCrushAccessTest() {
        FeatureManagement.setPackageBooleanValue('Crush_Access', false);
        System.assertEquals(
            false,
            FeatureFlagController.hasCrushAccess(),
            'Flag should be false as it was set for this test'
        );
        FeatureManagement.setPackageBooleanValue('Crush_Access', true);
        System.assertEquals(
            true,
            FeatureFlagController.hasCrushAccess(),
            'Flag should be true as it was set for this test'
        );
    }

    @IsTest
    static void hasRelationshipMapAccessTest() {
        FeatureManagement.setPackageBooleanValue('Relationship_Map_Access', false);
        System.assertEquals(
            false,
            FeatureFlagController.hasRelationshipMapAccess(),
            'Flag should be false as it was set for this test'
        );
        FeatureManagement.setPackageBooleanValue('Relationship_Map_Access', true);
        System.assertEquals(
            true,
            FeatureFlagController.hasRelationshipMapAccess(),
            'Flag should be true as it was set for this test'
        );
    }

    @IsTest
    static void hasOpportunityPlanAccessTest() {
        FeatureManagement.setPackageBooleanValue('OppPlan_Access', false);
        System.assertEquals(
            false,
            FeatureFlagController.hasOpportunityPlanAccess(),
            'Flag should be false as it was set for this test'
        );
        FeatureManagement.setPackageBooleanValue('OppPlan_Access', true);
        System.assertEquals(
            true,
            FeatureFlagController.hasOpportunityPlanAccess(),
            'Flag should be true as it was set for this test'
        );
    }
}