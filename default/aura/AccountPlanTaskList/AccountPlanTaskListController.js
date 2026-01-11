({
    init: function (component, event, helper) {
        var accountPlanId = component.get('v.recordId');
        var pageNumber = component.get('v.pageNumber');
        var recordsPerPage = component.get('v.recordsPerPage');
        var showAccountPlanName = true;

        // Check if component will have account plan Id reference or not.
        if (accountPlanId) {
            showAccountPlanName = false;
        }
        component.set('v.showAccountPlanName', showAccountPlanName);

        helper.loadFiltersAndData(component, pageNumber, recordsPerPage);
    },

    reloadData: function (component, event, helper) {
        var pageNumber = 1;
        var loadedPages = component.get('v.pageNumber');
        var loadedRecordsPerPage = component.get('v.recordsPerPage');
        var recordsPerPage = loadedPages * loadedRecordsPerPage;

        helper.loadData(component, pageNumber, recordsPerPage);
    },

    onViewCancel: function (component, event, helper) {
        helper.hideViewModal(component);
    },

    onDeleteCancel: function (component) {
        StrategyUtils.hideModal(component, 'deleteModal');
    },

    onStatusCancel: function (component) {
        var tasks = component.get('v.tasks');

        component.set('v.tasks', tasks);
        StrategyUtils.hideModal(component, 'statusModal');
    },

    onNewTaskCancel: function (component) {
        StrategyUtils.hideModal(component, 'recordTypeModal');
    },

    onStatusSave: function (component, event, helper) {
        const taskId = component.get('v.taskId');
        const selectedStatus = component.get('v.statusSelected');

        StrategyUtils.executeAction(component, 'c.upsertStatus', {
            taskId: taskId,
            status: selectedStatus
        })
            .then(
                $A.getCallback(function (result) {
                    helper.findAndUpdateTask(component, result);
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while updating the status.');
                    const tasks = component.get('v.tasks');

                    component.set('v.tasks', tasks);
                })
            );
        StrategyUtils.hideModal(component, 'statusModal');
    },

    onDeleteConfirm: function (component, event, helper) {
        helper.deleteTask(component, event.target.value);
    },

    handleRadioSelect: function (component, event) {
        var selectedRadio = event.getSource().get('v.value');

        component.set('v.statusSelected', selectedRadio);

        var statusSaveButtonComponent = component.find('statusSaveButton');

        statusSaveButtonComponent.set('v.disabled', false);
    },

    handleRecordTypeChange: function (component) {
        component.set('v.disableRecordTypeSave', false);
    },

    onRecordTypeContinue: function (component, event, helper) {
        var combo = component.find('recordTypeCombo');
        let recordTypeId = combo.get('v.value');

        component.set('v.recordTypeSelection', recordTypeId);
        StrategyUtils.hideModal(component, 'recordTypeModal');
        helper.createTask(component);
    },

    handleCreateTask: function (component, event, helper) {
        var recordTypeOptions = component.get('v.recordTypeOptions');
        var isClassic = component.get('v.isClassic');

        if (!isClassic && recordTypeOptions && recordTypeOptions.length > 1) {
            StrategyUtils.showModal(component, 'recordTypeModal');
        } else {
            helper.createTask(component);
        }
    },

    handleTaskAction: function (component, event, helper) {
        var taskId = event.getParam('taskId');
        var action = event.getParam('action');

        component.set('v.taskId', taskId);

        switch (action) {
            case 'checked':
                var closedStatuses = helper.getCloseStatusPickListValues(component);

                if (closedStatuses.length === 1) {
                    var closedStatus = closedStatuses[0].value;

                    helper.upsertStatus(component, taskId, closedStatus);
                } else if (closedStatuses.length > 1) {
                    component.set('v.statusPickListValues', closedStatuses);
                    helper.showStatusModal(component);
                }
                break;
            case 'unChecked':
                var openStatuses = helper.getOpenStatusPickListValues(component);

                if (openStatuses.length === 1) {
                    var openStatus = openStatuses[0].value;

                    helper.upsertStatus(component, taskId, openStatus);
                } else if (openStatuses.length > 1) {
                    component.set('v.statusPickListValues', openStatuses);
                    helper.showStatusModal(component);
                }
                break;
            case 'edit':
                var editRecordEvent = $A.get('e.force:editRecord');

                if (editRecordEvent) {
                    var params = {
                        recordId: taskId
                    };

                    editRecordEvent.setParams(params);
                    editRecordEvent.fire();
                }
                break;
            case 'view':
                helper.showViewModal(component);
                break;
            case 'delete':
                StrategyUtils.showModal(component, 'deleteModal');
                break;
        }
    },

    handleUpdateAppliedFilters: function (component, event, helper) {
        var pageNumber = 1;

        component.set('v.pageNumber', pageNumber);
        var recordsPerPage = component.get('v.recordsPerPage');

        var filterName = event.getParam('name');
        var appliedFilters = event.getParam('filters');

        if (filterName === component.get('v.taskFilterName')) {
            component.set('v.latestFilters', appliedFilters);
        } else if (filterName === component.get('v.accountPlanFilterName')) {
            component.set('v.accountPlanFiltersSelected', appliedFilters);
        }

        helper.loadData(component, pageNumber, recordsPerPage);
    },

    nextPage: function (component, event, helper) {
        var pageNumber = component.get('v.pageNumber') + 1;

        component.set('v.pageNumber', pageNumber);
        var recordsPerPage = component.get('v.recordsPerPage');

        helper.loadData(component, pageNumber, recordsPerPage);
    }
});