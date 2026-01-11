({
    init: function (component) {
        component.set('v.isLoading', true);

        let recordId = component.get('v.recordId');
        let objectType = component.get('v.sObjectName');

        if (objectType === 'pqcrush__PQ_Opportunity_Plan__c') {
            component.set('v.planId', recordId);
            component.set('v.isLoading', false);
            return;
        }

        const params = {
            opportunityId: recordId
        };

        StrategyUtils.executeAction(component, 'c.getPlanIdForOpportunityId', params)
            .then(
                $A.getCallback(function (planId) {
                    if (planId) {
                        component.set('v.planId', planId);
                    } else {
                        StrategyUtils.errorToast($A.get('$Label.c.Opp_Plan_No_Plan_Found_For_Opportunity'));
                    }
                    component.set('v.isLoading', false);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast(error.message);
                    component.set('v.isLoading', false);
                })
            );
    }
});