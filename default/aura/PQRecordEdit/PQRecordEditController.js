({
    handleCancel: function (component, event, helper) {
        helper.fireAppEvent(component.get('v.closeEventKey'));
    },

    handleSaveSuccess: function (component, event, helper) {
        helper.fireAppEvent(component.get('v.saveEventKey'), component.get('v.recordId'));
    },

    handleSave: function (component) {
        component.find('edit').get('e.recordSave').fire();
    },

    handleDetails: function (component) {
        var recordId = component.get('v.recordId');

        if (component.get('v.openNewTab')) {
            window.open('/' + recordId);
        } else {
            var navEvt = $A.get('e.force:navigateToSObject');

            if (navEvt) {
                navEvt.setParams({
                    recordId: recordId
                });
                navEvt.fire();
            }
        }
    }
});