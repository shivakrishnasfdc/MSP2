({
    editClicked: function (component) {
        component.set('v.editMode', true);
        component.set('v.oldValue', component.get('v.value'));

        // After the 100 millisecond set focus to input field
        window.setTimeout(
            $A.getCallback(function () {
                component.find('inputField').focus();
            }),
            100
        );
    },

    closePopover: function (component, event, helper) {
        helper.saveChange(component);
    },

    keyPressed: function (component, event, helper) {
        if (event.keyCode === 13) {
            helper.saveChange(component);
        }
    },

    deleteClicked: function (component) {
        var deleteEvent = component.getEvent('onDeleteClicked');
        var id = component.get('v.id');

        deleteEvent.setParams({
            id: id
        });
        deleteEvent.fire();
    }
});