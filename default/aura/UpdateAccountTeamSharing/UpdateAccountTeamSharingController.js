({
    init: function (component) {
        const accountPlanId = component.get('v.recordId');

        component.set('v.isLoading', true);
        StrategyUtils.executeAction(component, 'c.updateAccountPlanSharing', { accountPlanIds: [accountPlanId] })
            .then(
                $A.getCallback(function () {
                    StrategyUtils.successToast('Account Plan Sharing Updated!');
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while updating sharing.');
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                    $A.get('e.force:closeQuickAction').fire();
                })
            );
    }
});