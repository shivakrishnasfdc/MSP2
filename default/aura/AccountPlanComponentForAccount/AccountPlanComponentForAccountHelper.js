({
    getAccountPlansForAccount: function(component, accountId) {
        return StrategyUtils.executeAction(component, 'c.getAccountPlansForAccountIds', { accountIds: [accountId] })
            .then(
                $A.getCallback(function(result) {
                    component.set('v.accountPlans', result);
                    component.set('v.loaded', true);
                })
            )
            .catch(
                $A.getCallback(function(error) {
                    component.set('v.accountPlans', []);
                    component.set('v.loaded', true);
                    StrategyUtils.errorToast('Error retrieving account plans for account: ' + error.message);
                })
            );
    }
});