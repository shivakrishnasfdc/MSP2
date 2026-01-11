({
    init: function (component, event, helper) {
        component.set('v.isLoading', true);
        helper.loadData(component).then(
            $A.getCallback(function () {
                helper.filterHistories(component);
                component.set('v.isLoading', false);
            })
        );
    },

    filterHistories: function (component, event, helper) {
        helper.filterHistories(component);
    },

    handleApplicationEvent: function (component, event, helper) {
        if (event.getParam('appEventKey') === 'REFRESH_HISTORY') {
            helper.loadData(component).then(
                $A.getCallback(function () {
                    helper.filterHistories(component);
                })
            );
        }
    },

    // Updates history data when the account plan record is updated via the standard record page's edit button
    handleSystemRefreshEvent: function (component, event, helper) {
        helper.loadData(component).then(
            $A.getCallback(function () {
                helper.filterHistories(component);
            })
        );
    },

    loadMore: function (component) {
        component.set('v.iterationEnd', component.get('v.iterationEnd') + component.get('v.pageSize'));
    }
});