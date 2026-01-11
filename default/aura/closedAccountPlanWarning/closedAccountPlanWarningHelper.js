({
    getUserRecordAccess: function(component) {
        var params = {
            accountPlanId: component.get('v.recordId')
        };

        StrategyUtils.executeAction(component, 'c.getUserRecordAccess', params).then(function(recordAccess) {
            component.set('v.recordAccess', recordAccess);
        });
    }
});