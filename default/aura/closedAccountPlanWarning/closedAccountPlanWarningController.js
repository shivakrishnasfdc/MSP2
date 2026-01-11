({
    init: function (component, event, helper) {
        helper.getUserRecordAccess(component);
    },

    handleRecordUpdated: function (component, event, helper) {
        var eventParams = event.getParams();

        if (eventParams.changeType === 'LOADED') {
            // Record is loaded
        } else if (eventParams.changeType === 'CHANGED') {
            helper.getUserRecordAccess(component);
        } else if (eventParams.changeType === 'REMOVED') {
            // Record is deleted
        } else if (eventParams.changeType === 'ERROR') {
            // There’s an error while loading, saving, or deleting the record
        }
    }
});