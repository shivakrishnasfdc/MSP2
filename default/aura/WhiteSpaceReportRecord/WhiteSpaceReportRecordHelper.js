({
    loadData: function (component) {
        const recordId = component.get('v.recordId');

        component.set('v.isLoading', true);
        StrategyUtils.executeAction(component, 'c.getWhiteSpace', {
            whiteSpaceId: recordId
        })
            .then(
                $A.getCallback(function (result) {
                    component.set('v.whiteSpace', result.whiteSpace);
                    component.set('v.whiteSpaceObjectAccess', result.permissions);
                })
            )
            .catch(
                $A.getCallback((error) => {
                    this.handleLoadErrorState(component, error);
                    const evt = component.getEvent('onError');

                    evt.setParams({
                        value: error
                    });
                    evt.fire();
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                })
            );
    },

    handleWhiteSpaceResult: function (component, whiteSpace) {
        component.set('v.whiteSpace', whiteSpace);
    },

    showModal: function (component, modalComponent, modalComponentparams) {
        const modalService = component.find('modalService');

        modalService.presentDynamicModal(modalComponent, modalComponentparams, 'pqcrush');
    },

    closeModal: function (component) {
        const modalService = component.find('modalService');

        modalService.closeModal();
    },

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
    }
});