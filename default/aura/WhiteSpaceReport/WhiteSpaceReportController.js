({
    init: function (component, event, helper) {
        const service = component.find('whiteSpaceService');
        const recordId = component.get('v.recordId');

        component.set('v.isLoading', true);
        service
            .getWhiteSpaceObjectAccessForAccountPlan(recordId)
            .then(
                $A.getCallback(function (result) {
                    component.set('v.whiteSpaceObjectAccess', result);

                    return service.getFirstWhiteSpaceIdForAccountPlan(recordId);
                })
            )
            .then(
                $A.getCallback(function (result) {
                    component.set('v.whiteSpaceId', result);
                })
            )
            .catch(
                $A.getCallback(function (err) {
                    helper.handleLoadErrorState(component, err);
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                })
            );

        const createWhiteSpaceMenuItems = [
            {
                label: $A.get('$Label.c.Create_New_White_Space_Free_Form'),
                value: 'freeForm'
            },
            {
                label: $A.get('$Label.c.Create_New_White_Space_From_Template'),
                value: 'template'
            }
        ];

        component.set('v.createWhiteSpaceMenuItems', createWhiteSpaceMenuItems);
    },

    handleCreateButton: function (component, event, helper) {
        const selectedMenuItemValue = event.getParam('value');

        if (selectedMenuItemValue === 'freeForm') {
            const service = component.find('whiteSpaceService');
            const accountPlanId = component.get('v.recordId');

            component.set('v.isLoading', true);
            service
                .createWhiteSpace(accountPlanId, '', ['Row 1', 'Row 2', 'Row 3'], ['Column 1', 'Column 2', 'Column 3'])
                .then(
                    $A.getCallback(function (result) {
                        //component.set('v.whiteSpaceId', result.id);
                        helper.addItemToArray(component, 'v.whiteSpaceId', result.id);
                    })
                )
                .catch(
                    $A.getCallback(function (err) {
                        helper.handleActionErrorState(component, err);
                    })
                )
                .then(
                    $A.getCallback(function () {
                        component.set('v.isLoading', false);
                    })
                );
        } else if (selectedMenuItemValue === 'template') {
            helper.showModal(component, 'WhiteSpaceTemplatePicker', {
                accountPlanId: component.get('v.recordId')
            });
        }
    },

    handleApplicationEvent: function (component, event, helper) {
        let params = event.getParams();

        if (params.appEventKey === 'CLOSE_TEMPLATE_PICKER') {
            helper.closeModal(component);
        } else if (params.appEventKey === 'CREATE_WHITESPACE_FROM_TEMPLATE') {
            // Workaround due to issue with application events getting handled by duplicated handlers in memory
            // See https://salesforce.stackexchange.com/questions/223806/application-event-fired-multiple-times-multiple-copies-of-components-in-memory
            const accountPlanId = params.appEventValue ? params.appEventValue.accountPlanId : null;

            if (!accountPlanId || accountPlanId !== component.get('v.recordId')) {
                return;
            }

            var service = component.find('whiteSpaceService');
            const whiteSpace = params.appEventValue.whiteSpace;

            component.set('v.isLoading', true);
            helper.closeModal(component);
            service
                .createWhiteSpaceFromTemplate(whiteSpace)
                .then(
                    $A.getCallback(function (result) {
                        component.set('v.deletedWhiteSpaceId', null);
                        //component.set('v.whiteSpaceId', result.id);
                        helper.addItemToArray(component, 'v.whiteSpaceId', result.id);
                    })
                )
                .catch(
                    $A.getCallback(function (err) {
                        helper.handleActionErrorState(component, err);
                    })
                )
                .then(
                    $A.getCallback(function () {
                        component.set('v.isLoading', false);
                    })
                );
        }
    },

    handleError: function (component, event, helper) {
        const error = event.getParam('value');

        helper.handleLoadErrorState(component, error);
    },

    deleteWhiteSpace: function (component, event, helper) {
        const whiteSpaceId = event.getSource().get('v.recordId');

        if (!$A.util.isEmpty(whiteSpaceId)) {
            const service = component.find('whiteSpaceService');

            component.set('v.isLoading', true);
            service
                .deleteWhiteSpace(whiteSpaceId)
                .then(
                    $A.getCallback(function () {
                        component.set('v.deletedWhiteSpaceId', whiteSpaceId);
                        helper.removeItemFromArray(component, 'v.whiteSpaceId', whiteSpaceId);
                        component.set('v.errorMessage', null);
                        component.set('v.errorType', null);
                    })
                )
                .catch(
                    $A.getCallback(function (err) {
                        helper.handleActionErrorState(component, err);
                    })
                )
                .then(
                    $A.getCallback(function () {
                        component.set('v.isLoading', false);
                    })
                );
        }
    },

    undeleteWhiteSpace: function (component, event, helper) {
        component.set('v.isLoading', true);
        const service = component.find('whiteSpaceService');

        service
            .undeleteWhiteSpace(component.get('v.deletedWhiteSpaceId'))
            .then(
                $A.getCallback(function (result) {
                    component.set('v.deletedWhiteSpaceId', null);
                    //component.set('v.whiteSpaceId', result.id);
                    helper.addItemToArray(component, 'v.whiteSpaceId', result.id);
                })
            )
            .catch(
                $A.getCallback(function (err) {
                    helper.handleActionErrorState(component, err);
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                })
            );
    }
});