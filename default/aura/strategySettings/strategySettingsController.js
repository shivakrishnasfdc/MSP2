({
    init: function (component) {
        component.set('v.isLoading', true);

        StrategyUtils.executeAction(component, 'c.isKeyDateReminderJobStarted', {})
            .then(
                $A.getCallback(function (response) {
                    component.set('v.isKeyDateReminderJobStarted', response);
                    component.set('v.canScheduleKeyDateReminder', true);
                })
            )
            .catch(
                $A.getCallback(function () {
                    component.set('v.canScheduleKeyDateReminder', false);
                })
            );

        StrategyUtils.executeAction(component, 'c.isAccountPlanScoreHistoryJobStarted', {})
            .then(
                $A.getCallback(function (response) {
                    component.set('v.isAccountPlanScoreHistoryJobStarted', response);
                    component.set('v.canScheduleAccountPlanScoreHistoryJob', true);
                })
            )
            .catch(
                $A.getCallback(function () {
                    component.set('v.canScheduleAccountPlanScoreHistoryJob', false);
                })
            );

        StrategyUtils.executeAction(component, 'c.getOrgSettings', {})
            .then(
                $A.getCallback(function (orgSettings) {
                    component.set('v.settings', orgSettings);
                    component.set('v.originalSettings', StrategyUtils.cloneObject(orgSettings));

                    const navSet = [];

                    navSet.push(
                        { label: $A.get('$Label.c.Notifications'), name: 'notifications' },
                        { label: $A.get('$Label.c.General'), name: 'general' },
                        { label: $A.get('$Label.c.Cross_Sell_Map'), name: 'cross-sell' },
                        { label: $A.get('$Label.c.Relationship_Map'), name: 'keyStakeholders' },
                        { label: $A.get('$Label.c.Account_Relationship'), name: 'AccountRelationShip' },//Added By Navya START
                        { label: $A.get('$Label.c.Scheduled_Jobs'), name: 'scheduledJobs' },
                        { label: $A.get('$Label.c.Tasks'), name: 'tasks' }
                    );

                    if (!$A.util.isUndefinedOrNull(orgSettings.useAccountTeamPermissions)) {
                        navSet.push({ label: 'Account Plan Permissions', name: 'permissions' });
                    }

                    component.set('v.navSet', navSet);
                    component.set('v.isLoading', false);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast('An error occurred while loading the settings: ' + error.message);
                    component.set('v.isLoading', false);
                })
            );
    },

    saveHandler: function (component, event, helper) {
        var activeSection = component.get('v.activeSection');
        var settings = component.get('v.settings');
        var originalSettings = component.get('v.originalSettings');

        if (activeSection === 'keyStakeholders') {
            helper.saveKeyStakeholdersSettings(component);
        }

        if (
            activeSection !== 'keyStakeholders' ||
            settings.contactsAncestryLevels !== originalSettings.contactsAncestry_Levels
        ) {
            var params = {
                settings: JSON.stringify(settings)
            };

            component.set('v.isLoading', true);
            StrategyUtils.executeAction(component, 'c.upsertSettings', params)
                .then(
                    $A.getCallback(function (orgSettings) {
                        StrategyUtils.successToast('Settings updated!');
                        originalSettings.contactsAncestryLevels = settings.contactsAncestryLevels;
                        component.set('v.originalSettings', StrategyUtils.cloneObject(orgSettings));
                        component.set('v.isLoading', false);
                    })
                )
                .catch(
                    $A.getCallback(function (error) {
                        StrategyUtils.errorToast('An error occurred while saving the settings: ' + error.message);
                        component.set('v.isLoading', false);
                    })
                );
        }
    },

    cancelHandler: function (component, event, helper) {
        var activeSection = component.get('v.activeSection');

        switch (activeSection) {
            case 'keyStakeholders':
                helper.cancelKeyStakeholdersSettings(component);
                break;
            default:
                var originalSettings = component.get('v.originalSettings');

                component.set('v.settings', StrategyUtils.cloneObject(originalSettings));
                break;
        }
    },

    scheduleKeyDateReminderJobs: function (component) {
        StrategyUtils.executeAction(component, 'c.scheduleCrushJobs', {})
            .then(
                $A.getCallback(function () {
                    component.set('v.isKeyDateReminderJobStarted', true);
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while scheduling jobs.');
                })
            );
    },

    scheduleScoreJobs: function (component) {
        StrategyUtils.executeAction(component, 'c.scheduleAccountPlanScoreHistoryJobs', {})
            .then(
                $A.getCallback(function () {
                    component.set('v.isAccountPlanScoreHistoryJobStarted', true);
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while scheduling jobs.');
                })
            );
    },

    handleUpdateAllSharing: function (component) {
        component.set('v.isLoading', true);
        StrategyUtils.executeAction(component, 'c.updateAccountPlansSharing', {})
            .then(
                $A.getCallback(function () {
                    StrategyUtils.successToast('Account Plan Sharing Updated!');
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while updating sharing.');
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                })
            );
    },

    handleUserSelect: function (component) {
        const selection = component.find('userLookup').get('v.selection');
        var settings = component.get('v.settings');

        settings.accountPlanTransferUser = selection.id;
        component.set('v.settings', settings);
    }
});