({
    checkValidity: function (component) {
        if (component.get('v.isLookup')) {
            component.set('v.isValid', !$A.util.isEmpty(component.get('v.lookupValue')));
        } else {
            const textInput = component.find('textInput');

            if (textInput.checkValidity()) {
                textInput.reportValidity();
            }
            component.set('v.isValid', textInput.checkValidity() && textInput.get('v.value').length > 0);
        }
    },

    clearInput: function (component) {
        if (component.get('v.isLookup')) {
            component.set('v.lookupValue', null);
        } else {
            component.find('textInput').set('v.value', '');
            component.set('v.isValid', false);
        }
    },

    handleAdd: function (component) {
        let value = {};

        if (component.get('v.isLookup')) {
            const lookupValue = component.get('v.lookupValue');

            value = {
                name: lookupValue.title,
                relatedObjectId: lookupValue.id
            };
            const lookupIgnoreIds = component.get('v.lookupIgnoreIds');

            lookupIgnoreIds.push(lookupValue.id);
            component.set('v.lookupIgnoreIds', lookupIgnoreIds);
        } else {
            const inputValue = component.get('v.inputValue');

            value = {
                name: inputValue.trim(),
                relatedObjectId: null
            };
        }
        component.set('v.value', value);
        const onAddEvent = component.getEvent('onAdd');

        onAddEvent.fire();
    }
});