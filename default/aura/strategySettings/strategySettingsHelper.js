({
    saveKeyStakeholdersSettings: function (component) {
        var keyStakeholdersCmp = component.find('KeyStakeholderSettingsPage');

        if (keyStakeholdersCmp) {
            keyStakeholdersCmp.save();
        }
    },

    cancelKeyStakeholdersSettings: function (component) {
        var keyStakeholdersCmp = component.find('KeyStakeholderSettingsPage');

        if (keyStakeholdersCmp) {
            keyStakeholdersCmp.cancel();
        }
    }
});