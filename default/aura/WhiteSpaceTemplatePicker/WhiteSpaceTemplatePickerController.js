({
    handleSelection: function (component, event) {
        const templateId = event.getParam('value');

        component.set('v.selectedTemplateId', templateId);
        const templatePickerCmp = component.find('templatePickerLwc');
        const isValid = templatePickerCmp.isSelectionValid();

        component.set('v.canContinue', isValid);
    },

    handleCancel: function (component) {
        const appEvent = $A.get('e.c:PQApplicationEvent');

        appEvent.setParams({
            appEventKey: 'CLOSE_TEMPLATE_PICKER',
            appEventValue: {
                accountPlanId: component.get('v.accountPlanId')
            }
        });
        appEvent.fire();
    },

    handleContinue: function (component) {
        const appEvent = $A.get('e.c:PQApplicationEvent');
        const templatePickerCmp = component.find('templatePickerLwc');
        const newWs = templatePickerCmp.getWsRecordForCreate();

        appEvent.setParams({
            appEventKey: 'CREATE_WHITESPACE_FROM_TEMPLATE',
            appEventValue: {
                templateId: component.get('v.selectedTemplateId'),
                accountPlanId: component.get('v.accountPlanId'),
                whiteSpace: newWs
            }
        });
        appEvent.fire();
    },

    handleLoadState: function (component, event) {
        const isLoading = event.getParam('value');

        component.set('v.isLoading', isLoading);
    }
});