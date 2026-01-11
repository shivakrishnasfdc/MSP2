({
    initHeaderOptions: function (component) {
        var amountTypes = component.get('v.record.displayFields');

        if ($A.util.isEmpty(amountTypes)) {
            return;
        }
        var opts = [];
        var noneLabel = '--' + $A.get('$Label.c.None') + '--';

        // Add a select option for no value
        opts.push({
            label: noneLabel,
            value: null
        });

        // Add each amount type as a select option
        amountTypes.forEach(function (option) {
            if (option.id) {
                opts.push({
                    label: option.displayName,
                    value: option.id,
                    selected: option.isPrimary
                });
            }
        });
        component.set('v.tileHeaderOptions', opts);
    },

    checkAllFieldsValid: function (component) {
        // Currently no way for info area to be invalid
        // And not easy to check validity without changing it's component
        // So skipping a check on it
        var amountAreas = component.find('wsAmountArea');

        if (Array.isArray(amountAreas) === false) {
            amountAreas = amountAreas ? [amountAreas] : [];
        }
        for (var i = 0; i < amountAreas.length; i++) {
            var amountArea = amountAreas[i];
            var amountAreaValidity = amountArea.get('v.validity');

            if (amountAreaValidity && amountAreaValidity.valid === false) {
                component.set('v.allFieldsValid', false);

                return;
            }
        }
        component.set('v.allFieldsValid', true);
    },

    triggerEditActionEvent: function (component, state) {
        var record = component.get('v.record');

        var actionEvent = component.getEvent('editAction');
        var eventParams = {
            id: record.id,
            state: state
        };

        actionEvent.setParams(eventParams);
        actionEvent.fire();
    }
});