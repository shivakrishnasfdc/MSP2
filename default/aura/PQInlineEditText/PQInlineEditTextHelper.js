({
    saveChange: function (component) {
        var newValue = component.get('v.value').trim();
        var oldValue = component.get('v.oldValue').trim();

        if (this.checkValidity(component, newValue)) {
            if (newValue !== oldValue) {
                var changeEvent = component.getEvent('onValueChanged');
                var id = component.get('v.id');

                changeEvent.setParams({
                    oldValue: oldValue,
                    newValue: newValue,
                    id: id
                });
                changeEvent.fire();
            }
            component.set('v.editMode', false);
        }
    },

    checkValidity: function (component, newValue) {
        var inputComp = component.find('inputField');

        // Fix for race issue in framework where blur event gets fired and handled after value is already saved and input component has been destroyed (CRUSH-516)
        if (!inputComp) {
            return false;
        }

        var validity = inputComp.get('v.validity');

        if (newValue.length >= 0 && validity.valid) {
            inputComp.reportValidity();

            return true;
        } else {
            return false;
        }
    }
});