({
    handleGetSupportFields: function (component) {
        return StrategyUtils.executeAction(component, 'c.getSupport', {});
    },

    handleGetOrgSettings: function (component) {
        return StrategyUtils.executeAction(component, 'c.getOrgSettings', {});
    },

    handleUpsertOrgSettings: function (component, event) {
        var args = event.getParam('arguments');

        return StrategyUtils.executeAction(component, 'c.upsertSettings', {
            settings: JSON.stringify(args.orgSettings)
        });
    }
});