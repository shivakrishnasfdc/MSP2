({
    doInit: function (component, event, helper) {
        helper.setHeaderTextAndBackgroundColor(component);
        helper.handleIESupport(component);
        helper.checkIfData(component);
    },

    onDelete: function (component, event, helper) {
        component.set('v.currentState', 'DELETE');
        helper.applyElevation(component);
    },

    handleDeleteCancel: function (component, event, helper) {
        component.set('v.currentState', 'VIEW');
        helper.removeElevation(component);
    },

    handleDeleteConfirm: function (component) {
        var record = component.get('v.record');
        var deleteEvent = component.getEvent('onDeleteTileConfirmed');
        var eventParams = {
            id: record.id
        };

        deleteEvent.setParams(eventParams);
        deleteEvent.fire();
        component.set('v.currentState', 'VIEW');
    },

    handleEditStateChanged: function (component, event, helper) {
        var params = event.getParams();
        var state = params.state;

        if (state === 'endedit') {
            component.set('v.currentState', 'VIEW');
            helper.removeElevation(component);
        }
    },

    onEdit: function (component, event, helper) {
        component.set('v.currentState', 'EDIT');
        helper.applyElevation(component);
    }
});