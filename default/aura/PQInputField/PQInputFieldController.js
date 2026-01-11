({
    doInit: function (component, event, helper) {
        const value = component.get('v.fieldValue');
        const type = component.get('v.type');

        const formattedValue = component.find('dataFormatUtils').formatDataValue(value, type);

        component.set('v.value', formattedValue);
        if (type === 'boolean') {
            component.set('v.booleanValue', formattedValue);
        }
        window.setTimeout(
            $A.getCallback(function () {
                helper.autosize(component);
            }),
            100
        );
    },

    onTextInput: function (component, event, helper) {
        var updatedValue = event.target.value;

        component.set('v.fieldValue', updatedValue);
        helper.autosize(component);
    },

    onAmountFocus: function (component, event) {
        // Set value to empty if value is 0 for aesthetics

        // Also stupid fix for stupid firefox because
        // Lightning:input won't gain focus if there's a value
        // So need to clear it out then re-apply value
        if (!event || !event.getSource) {
            return;
        }
        var element = event.getSource();
        var val = element.get('v.value');

        element.set('v.value', null);
        if (parseInt(val) !== 0) {
            window.setTimeout(
                $A.getCallback(function () {
                    element.set('v.value', val);
                }),
                25
            );
        }
    },

    cleanupAmount: function (component, event) {
        if (!event || !event.getSource) {
            return;
        }

        // Set value to 0 if user clears out the amount
        if ($A.util.isEmpty(event.getSource().get('v.value'))) {
            event.getSource().set('v.value', 0);
        }
    },

    onValueChange: function (component, event) {
        if (!event || !event.getSource) {
            return;
        }
        var updatedValue = event.getSource().get('v.value');

        component.set('v.fieldValue', updatedValue);
    },

    // Prevents the value from changing when the user scrolls over a lightning:input number field
    preventValueChange: function (component, event) {
        event.preventDefault();
    }
});