({
    handleGetUserRecordAccess: function(component, event) {
        var args = event.getParam('arguments');
        var recordId = args.recordId;

        return StrategyUtils.executeAction(component, 'c.getUserRecordAccess', {
            recordId: recordId
        });
    }
});