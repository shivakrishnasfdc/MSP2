({
    init: function (component) {
        component.set('v.isLoading', true);
        StrategyUtils.executeAction(component, 'c.getOrgSettings', {})
            .then(
                $A.getCallback(function (orgSettings) {
                    component.set('v.orgNotificationsEnabled', orgSettings.enableNotifications);
                    StrategyUtils.executeAction(component, 'c.getCurrentUserSettings', {}).then(
                        $A.getCallback(function (userSettings) {
                            component.set('v.settings', userSettings);
                            component.set('v.originalSettings', JSON.parse(JSON.stringify(userSettings)));
                        })
                    );
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while loading the settings.');
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                })
            );
    },

    saveHandler: function (component) {
        var settings = component.get('v.settings');

        var params = {
            settings: JSON.stringify(settings)
        };

        component.set('v.isLoading', true);
        StrategyUtils.executeAction(component, 'c.upsertSettings', params)
            .then(
                $A.getCallback(function (userSettings) {
                    StrategyUtils.successToast('Settings updated!');
                    component.set('v.originalSettings', JSON.parse(JSON.stringify(userSettings)));
                    component.set('v.settings', userSettings);
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while saving the settings.');
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                })
            );
    }
});