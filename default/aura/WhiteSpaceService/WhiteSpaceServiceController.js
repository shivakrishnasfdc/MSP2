({
    handleGetFirstWhiteSpaceIdForAccountPlan: function (component, event) {
        const args = event.getParam('arguments');
        const accountPlanId = args.accountPlanId;

        return StrategyUtils.executeAction(component, 'c.getFirstWhiteSpaceIdForAccountPlan', {
            accountPlanId
        });
    },

    handleGetWhiteSpaceForAccountPlan: function (component, event) {
        var args = event.getParam('arguments');
        var accountPlanId = args.accountPlanId;

        return StrategyUtils.executeAction(component, 'c.getWhiteSpaceForAccountPlan', {
            accountPlanId: accountPlanId
        });
    },

    handleCreateWhiteSpace: function (component, event) {
        var args = event.getParam('arguments');

        var params = {
            accountPlanId: args.accountPlanId,
            name: args.name,
            rowNames: args.rowNames,
            columnNames: args.columnNames
        };

        return StrategyUtils.executeAction(component, 'c.createWhiteSpace', params);
    },

    handleCreateWhiteSpaceFromTemplate: function (component, event) {
        var args = event.getParam('arguments');

        var params = {
            ws: args.whiteSpace
        };

        return StrategyUtils.executeAction(component, 'c.createWhiteSpaceFromTemplate', params);
    },

    handleDeleteWhiteSpace: function (component, event) {
        const args = event.getParam('arguments');
        const params = {
            whiteSpaceId: args.whiteSpaceId
        };

        return StrategyUtils.executeAction(component, 'c.deleteWhiteSpace', params);
    },

    handleUndeleteWhiteSpace: function (component, event) {
        const args = event.getParam('arguments');
        const params = {
            whiteSpaceId: args.whiteSpaceId
        };

        return StrategyUtils.executeAction(component, 'c.undeleteWhiteSpace', params);
    },

    handleUpdateWhiteSpaceCell: function (component, event) {
        var args = event.getParam('arguments');
        var record = args.record;

        var params = {
            wrapper: record,
            whiteSpaceId: null
        };

        return StrategyUtils.executeAction(component, 'c.updateWhiteSpaceTile', params);
    },

    handleCreateWhiteSpaceCell: function (component, event) {
        var args = event.getParam('arguments');

        var params = {
            columnId: args.columnId,
            rowId: args.rowId,
            whiteSpaceId: args.whiteSpaceId
        };

        return StrategyUtils.executeAction(component, 'c.createWhiteSpaceTile', params);
    },

    handleDeleteWhiteSpaceCell: function (component, event) {
        var args = event.getParam('arguments');
        var cellId = args.cellId;

        var params = {
            tileId: cellId
        };

        return StrategyUtils.executeAction(component, 'c.deleteWhiteSpaceTile', params);
    },

    handleUpdateWhiteSpaceRowsAndColumns: function (component, event) {
        var args = event.getParam('arguments');
        var whiteSpaceId = args.whiteSpaceId;

        var params = {
            whiteSpaceId: whiteSpaceId,
            wsRows: JSON.stringify(args.wsRows),
            wsColumns: JSON.stringify(args.wsColumns)
        };

        return StrategyUtils.executeAction(component, 'c.updateWhiteSpaceRowsAndColumns', params);
    },

    handleGetWhiteSpaceObjectAccessForAccountPlan: function (component, event) {
        const args = event.getParam('arguments');
        const params = {
            accountPlanId: args.accountPlanId
        };

        return StrategyUtils.executeAction(component, 'c.getWhiteSpaceObjectAccessForAccountPlan', params);
    },

    handleGetSummaryFormulas: function (component, event) {
        const args = event.getParam('arguments');

        return StrategyUtils.executeAction(component, 'c.getSummaryFormulas', { whiteSpaceId: args.whiteSpaceId });
    },

    handleGetUserSetting: function (component, event) {
        var args = event.getParam('arguments');
        var whitespaceId = args.whitespaceId;

        return StrategyUtils.executeAction(component, 'c.getUserSetting', {
            whitespaceId: whitespaceId
        });
    },

    handleUpdateUserSetting: function (component, event) {
        var args = event.getParam('arguments');
        var setting = args.setting;

        return StrategyUtils.executeAction(component, 'c.updateUserSetting', {
            setting: setting
        });
    }
});