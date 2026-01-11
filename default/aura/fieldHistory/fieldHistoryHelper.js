({
    loadData: function (component) {
        var params = {
            accountPlanId: component.get('v.recordId')
        };

        return StrategyUtils.executeAction(component, 'c.getHistoryByAccountPlanId', params)
            .then(
                $A.getCallback(function (result) {
                    component.set('v.histories', result);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast('An error occurred while loading data: ' + error.message);
                })
            );
    },

    filterHistories: function (component) {
        const selectedFilter = component.get('v.selectedFilter');
        const histories = component.get('v.histories');

        let filteredHistories;

        if (selectedFilter) {
            filteredHistories = histories.filter(function (item) {
                return selectedFilter === item.parentObjectName;
            });
        } else {
            filteredHistories = histories;
        }
        component.set('v.filteredHistories', filteredHistories);
    }
});