({
    handleApplicationEvent: function (component, event, helper) {
        let requestModal = component.get('v.didRequestModal');

        if (!requestModal) {
            return;
        }
        component.set('v.didRequestModal', false);
        let params = event.getParams();

        switch (params.appEventKey) {
            case 'RM_EDIT_SETTINGS_SAVE_SUCCESS':
            case 'RM_EDIT_RECORD_SAVE_SUCCESS':
            case 'RM_CLOSE_EDIT_RECORD':
                helper.closeModal(component);
                break;
            default:
                break;
        }
        var orggraph = component.find('orggraph');

        if (orggraph) {
            orggraph.handleApplicationEvent(params.appEventKey, params.appEventValue);
        }
    },

    fireApplicationEvent: function (component, event, helper) {
        var eventName = event.getParam('name');
        var eventValue = event.getParam('value');
        var valueArray = Array.isArray(eventValue) ? eventValue : new Array(eventValue);
        var shouldRefresh = event.getParam('refreshViews');
        let eventService = helper.eventService(component);

        valueArray.forEach((value) => {
            eventService.fireAppEvent(eventName, value);
        });
        if (shouldRefresh) {
            $A.get('e.force:refreshView').fire();
        }
    },

    handleObjectViewerRequested: function (component, event, helper) {
        component.set('v.didRequestModal', true);
        var editId = event.getParam('objectId');
        var access = event.getParam('access');
        var label = event.getParam('objectLabel');
        var type = event.getParam('name');

        var title = label ? label : 'Edit';

        if (type === 'settings') {
            helper.viewSettings(component, title, editId, access);
        } else {
            helper.viewObject(component, title, editId, access);
        }
    },

    handleGraphError: function (component, event) {
        var error = event.getParam('error');

        if (error.message) {
            StrategyUtils.errorToast(error.message);
        } else if (error.body && error.body.message) {
            StrategyUtils.errorToast(error.body.message);
        } else if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
            let pageError = error.body.pageErrors[0];

            StrategyUtils.errorToast(pageError.message);
        }
    },

    handleCreateNewTask: function (component, event) {
        var isClassic = component.get('v.isClassic');
        var containerId = event.getParam('containerId');
        var contactId = event.getParam('contactId');
        var userId = event.getParam('userId');
        var entityApiName = 'Task';

        if (isClassic) {
            var createRecordEvent = $A.get('e.force:createRecord');

            if (createRecordEvent) {
                var params = {
                    entityApiName,
                    containerId,
                    contactId,
                    userId,
                    defaultFieldValues: {
                        WhatId: containerId,
                        WhoId: contactId,
                        OwnerId: userId
                    }
                };

                createRecordEvent.setParams(params);
                createRecordEvent.fire();
            }
        }
    }
});