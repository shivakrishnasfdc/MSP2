({
    loadFiltersAndData: function (component, pageNumber, recordsPerPage) {
        component.set('v.isLoading', true);
        this.loadStatusUpdatePickListValues(component, pageNumber, recordsPerPage);
        this.loadAccountPlanFilters(component);
        this.loadTaskRecordTypes(component);
    },

    loadTaskRecordTypes: function (component) {
        var action = component.get('c.getRecordTypeInfo');

        // CONFIGURE RESPONSE HANDLER
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                let optionsValues = [];
                let rtValues = response.getReturnValue();

                for (let i = 0; i < rtValues.length; i++) {
                    if (!rtValues[i].isMaster && rtValues[i].isActive && rtValues[i].isAvailable) {
                        optionsValues.push({
                            label: rtValues[i].name,
                            value: rtValues[i].recordTypeId
                        });

                        if (rtValues[i].isDefaultRecordTypeMapping) {
                            component.set('v.defaultRecordType', rtValues[i].recordTypeId);
                            component.set('v.recordTypeSelection', rtValues[i].recordTypeId);
                            component.set('v.disableRecordTypeSave', false);
                        }
                    }
                }

                component.set('v.recordTypeOptions', optionsValues);
            }
        });

        $A.enqueueAction(action);
    },

    loadAccountPlanFilters: function (component) {
        var action = component.get('c.getAccountPlanFilters');

        // CONFIGURE RESPONSE HANDLER
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var accountPlanFilters = response.getReturnValue();

                component.set('v.accountPlanFilters', accountPlanFilters);
                component.set('v.accountPlanFiltersSelected', this.getSelectedFilters(accountPlanFilters));
            }
        });

        $A.enqueueAction(action);
    },

    loadStatusUpdatePickListValues: function (component, pageNumber, recordsPerPage) {
        var action = component.get('c.getUpdateStatusPicklistValues');

        // CONFIGURE RESPONSE HANDLER
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var pickListResponse = response.getReturnValue();

                component.set('v.allStatusPickListValues', pickListResponse);
                this.setupStatusMap(component);
                this.loadFilterValues(component, pageNumber, recordsPerPage);
            } else {
                this.showError(component, response.getError()[0]);
            }
        });

        $A.enqueueAction(action);
    },

    loadFilterValues: function (component, pageNumber, recordsPerPage) {
        var action = component.get('c.getFilterValues');

        // Configure response handler
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var filterResponse = response.getReturnValue();

                component.set('v.filterArrays', filterResponse);
                component.set('v.latestFilters', this.getSelectedFilters(filterResponse));

                this.loadData(component, pageNumber, recordsPerPage);
            } else {
                this.showError(component, response.getError()[0]);
            }
        });

        $A.enqueueAction(action);
    },

    loadData: function (component, pageNumber, recordsPerPage) {
        var taskCountMethod;
        var taskCountMethodParams;
        var taskMethod;
        var taskMethodParams;

        var accountPlanRecordId = component.get('v.recordId');
        var filtersJson = JSON.stringify(component.get('v.latestFilters'));
        var accountPlanFiltersSelected = component.get('v.accountPlanFiltersSelected');

        var accountPlanFilterIds = accountPlanFiltersSelected.map(function (item) {
            return item.value;
        });

        // GET THE ACCOUNT PLAN LIST FROM THE RECORDID OR FILTERS FOR SPECIFIC ACCOUNT PLANS
        var accountPlanIds;

        if (accountPlanRecordId) {
            accountPlanIds = new Array(accountPlanRecordId);
        } else if (accountPlanFilterIds && accountPlanFilterIds.length > 0) {
            accountPlanIds = accountPlanFilterIds;
        }

        // IF THE RECORD ID EXISTS (IN ACCOUNT PLAN PAGE) or IF IN ACCOUNT PLAN TASKS TAB WITH ACCOUNT PLAN FILTERS
        // THEN USE THE METHODS THAT GETS FOR SPECIFIC ACCOUNT PLANS
        if (accountPlanIds) {
            taskCountMethod = 'c.getTaskCountForAccountPlan';
            taskCountMethodParams = {
                accountPlanIds: accountPlanIds,
                filtersJson: filtersJson
            };
            taskMethod = 'c.getTasksForAccountPlan';
            taskMethodParams = {
                accountPlanIds: accountPlanIds,
                pageNumber: pageNumber,
                recordsPerPage: recordsPerPage,
                filtersJson: filtersJson
            };
        } else {
            taskCountMethod = 'c.getTaskCountForAllAccountPlans';
            taskCountMethodParams = {
                filtersJson: filtersJson
            };
            taskMethod = 'c.getTasksForAllAccountPlans';
            taskMethodParams = {
                pageNumber: pageNumber,
                recordsPerPage: recordsPerPage,
                filtersJson: filtersJson
            };
        }
        if (pageNumber > 1) {
            component.set('v.isLoadingMore', true);
        } else {
            component.set('v.isLoading', true);
        }
        this.loadTaskCount(component, taskCountMethod, taskCountMethodParams, pageNumber, recordsPerPage);
        this.loadTasks(component, taskMethod, taskMethodParams, pageNumber, recordsPerPage);
    },

    loadTaskCount: function (component, method, params, pageNumber, recordsPerPage) {
        var action = component.get(method);

        action.setParams(params);

        // Configure response handler
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var taskCountResult = response.getReturnValue();

                component.set('v.totalRecords', taskCountResult);
                component.set('v.totalPages', Math.ceil(taskCountResult / recordsPerPage));
            }
        });

        $A.enqueueAction(action);
    },

    loadTasks: function (component, method, params, pageNumber) {
        var action = component.get(method);

        action.setParams(params);

        // CONFIGURE RESPONSE HANDLER
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var taskResult = response.getReturnValue();

                if (pageNumber <= 1) {
                    component.set('v.tempTasks', taskResult);
                } else {
                    var tasks = component.get('v.tasks');

                    tasks = tasks.concat(taskResult);
                    component.set('v.tempTasks', tasks);
                }
                var taskIds = taskResult.map(function (wrapper) {
                    return wrapper.taskRecord.Id;
                });

                this.loadUserRecordAccessForTasks(component, taskIds, pageNumber);
            } else {
                this.showError(component, response.getError()[0]);
            }
        });

        $A.enqueueAction(action);
    },

    loadUserRecordAccessForTasks: function (component, taskIds, pageNumber) {
        var action = component.get('c.getUserRecordAccessForTasks');

        action.setParams({ taskIds: taskIds });

        // Configure response handler
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();

                if (pageNumber <= 1) {
                    component.set('v.accessMap', result);
                } else {
                    var map = component.get('v.accessMap');

                    Object.assign(map, result);
                    component.set('v.accessMap', map);
                }

                var tasks = component.get('v.tempTasks');

                component.set('v.tasks', tasks);

                component.set('v.isLoading', false);
                component.set('v.isLoadingMore', false);
            } else {
                this.showError(component, response.getError()[0]);
            }
        });

        $A.enqueueAction(action);
    },

    deleteTask: function (component, taskId) {
        StrategyUtils.executeAction(component, 'c.deleteTask', {
            taskId: taskId
        }).then(
            $A.getCallback(function () {
                const tasks = component.get('v.tasks');
                const foundIndex = tasks.findIndex(function (item) {
                    return item.taskRecord.Id === taskId;
                });

                if (foundIndex > -1) {
                    tasks.splice(foundIndex, 1);
                }
                component.set('v.tasks', tasks);
                StrategyUtils.hideModal(component, 'deleteModal');
            })
        );
    },

    getSelectedFilters: function (inputFilters) {
        return inputFilters
            .reduce(function (previous, current) {
                return previous.concat(current.filters);
            }, [])
            .filter(function (filter) {
                return filter.isSelected;
            });
    },

    showError: function (component, error) {
        StrategyUtils.errorToast('An error occurred while loading data: ' + error.message);
        component.set('v.isLoading', false);
        component.set('v.isLoadingMore', false);
    },

    showViewModal: function (component) {
        component.set('v.canView', true);
        StrategyUtils.showModal(component, 'viewModal');
    },

    hideViewModal: function (component) {
        component.set('v.canView', false);
        StrategyUtils.hideModal(component, 'viewModal');
    },

    showStatusModal: function (component) {
        var radio = component.find('radio');

        radio.forEach(function (item) {
            item.set('v.checked', false);
        });
        var statusSaveButtonComponent = component.find('statusSaveButton');

        statusSaveButtonComponent.set('v.disabled', true);
        StrategyUtils.showModal(component, 'statusModal');
    },

    setupStatusMap: function (component) {
        var open = this.getOpenStatusPickListValues(component);
        var closed = this.getCloseStatusPickListValues(component);
        var statusMap = {};
        var mapFunction = function (item) {
            var value = item.value;
            var label = item.label;

            statusMap[value] = label;
        };

        open.forEach(mapFunction);
        closed.forEach(mapFunction);
        component.set('v.statusMap', statusMap);
    },

    getOpenStatusPickListValues: function (component) {
        var allStatuses = component.get('v.allStatusPickListValues');

        return allStatuses['open'];
    },

    getCloseStatusPickListValues: function (component) {
        var allStatuses = component.get('v.allStatusPickListValues');

        return allStatuses['closed'];
    },

    findAndUpdateTask: function (component, updatedTask) {
        const tasks = component.get('v.tasks');
        const foundIndex = tasks.findIndex(function (item) {
            // Check on updatedTask
            return item.taskRecord.Id === updatedTask.Id;
        });
        let wrapper = tasks[foundIndex];

        wrapper.taskRecord = updatedTask;
        tasks[foundIndex] = _.merge(_.cloneDeep(tasks[foundIndex]), wrapper);
        component.set('v.tasks', tasks);
    },

    upsertStatus: function (component, taskId, status) {
        var self = this;

        StrategyUtils.executeAction(component, 'c.upsertStatus', {
            taskId: taskId,
            status: status
        })
            .then(
                $A.getCallback(function (result) {
                    self.findAndUpdateTask(component, result);
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while updating the status.');
                    const tasks = component.get('v.tasks');

                    component.set('v.tasks', tasks);
                })
            );
    },

    createTask: function (component) {
        var isMobile = component.get('v.isMobile');
        var accountPlanId = component.get('v.recordId');
        var recordTypeId = component.get('v.recordTypeSelection');
        var params = {};

        if (isMobile) {
            if (accountPlanId) {
                params = { WhatId: accountPlanId };
            }
            sforce.one.createRecord('Task', null, params);
        } else {
            var createRecordEvent = $A.get('e.force:createRecord');

            if (createRecordEvent) {
                if (accountPlanId) {
                    params = {
                        entityApiName: 'Task',
                        defaultFieldValues: {
                            WhatId: accountPlanId
                        }
                    };
                } else {
                    params = {
                        entityApiName: 'Task'
                    };
                }

                if (recordTypeId) {
                    params.recordTypeId = recordTypeId;
                }

                createRecordEvent.setParams(params);
                createRecordEvent.fire();
            }
        }
    }
});