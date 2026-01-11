({
    handleLoadErrorState: function (component, error) {
        const service = component.find('stringUtilService');

        component.set('v.stateTitle', $A.get('$Label.c.error_data_not_available'));
        component.set(
            'v.stateBody',
            service.formatLabel($A.get('$Label.c.error_data_not_available_details'), [
                $A.get('$Label.c.error_permission_or_system_error')
            ])
        );
        if (error.message) {
            component.set('v.errorMessage', error.message);
        }
        if (error.exceptionType) {
            component.set('v.errorType', error.exceptionType);
        }
    },

    handleActionErrorState: function (component, error) {
        const service = component.find('stringUtilService');

        component.set('v.stateTitle', $A.get('$Label.c.error_something_went_wrong'));
        component.set(
            'v.stateBody',
            service.formatLabel($A.get('$Label.c.error_action_unsuccessful_details'), [
                $A.get('$Label.c.error_permission_or_system_error')
            ])
        );
        if (!error.message && !error.exceptionType && error.pageErrors && error.pageErrors.length > 0) {
            error = error.pageErrors[0];
        }
        if (error.message) {
            component.set('v.errorMessage', error.message);
        }
        if (error.exceptionType) {
            component.set('v.errorType', error.exceptionType);
        }
    },

    showModal: function (component, modalComponent, modalComponentparams) {
        var modalService = component.find('modalService');

        modalService.presentDynamicModal(modalComponent, modalComponentparams, 'pqcrush');
    },

    closeModal: function (component) {
        var modalService = component.find('modalService');

        modalService.closeModal();
    },

    addItemToArray: function (component, attributeName, itemToAdd) {
        var list = component.get(attributeName);

        list.push(itemToAdd);

        component.set(attributeName, list);
    },

    removeItemFromArray: function (component, attributeName, itemToRemove) {
        var list = component.get(attributeName);

        var indexToRemove = list.indexOf(itemToRemove);

        if (indexToRemove !== -1) {
            list.splice(indexToRemove, 1);

            component.set(attributeName, list);
        }
    }
});