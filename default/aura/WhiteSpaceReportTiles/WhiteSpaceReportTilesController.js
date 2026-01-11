({
    init: function (component, event, helper) {
        helper.handleWhiteSpaceResult(component, component.get('v.whiteSpace'));
        window.addEventListener(
            'resize',
            $A.getCallback(function () {
                if (component.isValid()) {
                    helper.updateGridWidth(component);
                }
            })
        );
    },

    updateWhitespace: function (component, event, helper) {
        helper.handleWhiteSpaceResult(component, component.get('v.whiteSpace'));
    },

    cellDataUpdated: function (component, event, helper) {
        event.stopPropagation();
        var params = event.getParams();
        var newCellData = params.newValue;

        helper.updateCellData(component, params.id, newCellData.info, newCellData.amountTypeAssociations);
    },

    cellDeleteConfirmed: function (component, event, helper) {
        event.stopPropagation();
        var params = event.getParams();
        var cellId = params.id;
        var service = component.find('whiteSpaceService');
        var preDeleteData = JSON.parse(JSON.stringify(component.get('v.whiteSpace')));

        helper.deleteCellData(component, cellId);
        service.deleteWhiteSpaceCell(cellId).catch(
            $A.getCallback(function (error) {
                StrategyUtils.errorToast('Error deleting white space cell: ' + error.message);
                helper.handleWhiteSpaceResult(component, preDeleteData);
                helper.createCellData(component, preDeleteData.id, preDeleteData.cells, preDeleteData.cellDisplayType);
            })
        );
    },

    fullScreenHandler: function (component, event) {
        const args = event.getParam('arguments');
        const isExpanding = args.isExpanding;

        if (isExpanding) {
            if ($A.util.isEmpty(component.get('v.originalLargeSizeColumns'))) {
                component.set('v.originalLargeSizeColumns', component.get('v.largeSizeColumns'));
            }
            component.set('v.largeSizeColumns', 8);
        } else {
            component.set('v.largeSizeColumns', component.get('v.originalLargeSizeColumns'));
        }
    }
});