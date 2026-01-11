({
    onUtilsLoaded: function (component) {
        var service = component.find('utilityForBrowserSupport');

        component.set('v.isBrowserIE', service.isBrowserIE());

        var utility = component.find('utilityForInputs');

        component.set('v.regexForInput', utility.getRegexForNonBlankString());
        component.set('v.regexForInputDescription', utility.getRegexForNonBlankStringDescription());
        component.set('v.originalWhitespaceObj', JSON.parse(JSON.stringify(component.get('v.whitespaceObj'))));
        component.set('v.isLoadingUtils', false);

        const selectedColumnRelatedObjectIds = component.get('v.whitespaceObj').columns.map(function (column) {
            return column.collection.pqcrush__Related_Object_Id__c;
        });

        component.set('v.selectedColumnRelatedObjectIds', selectedColumnRelatedObjectIds);

        const selectedRowRelatedObjectIds = component.get('v.whitespaceObj').rows.map(function (row) {
            return row.collection.pqcrush__Related_Object_Id__c;
        });

        component.set('v.selectedRowRelatedObjectIds', selectedRowRelatedObjectIds);
    },

    onRender: function (component) {
        component.set('v.afterRender', true);
    },

    rowUpdated: function (component, event, helper) {
        helper.updateRowColumnName(component, event, true);
    },

    columnUpdated: function (component, event, helper) {
        helper.updateRowColumnName(component, event, false);
    },

    onSaveClicked: function (component) {
        component.set('v.isSaving', true);
        var whitespaceObj = component.get('v.whitespaceObj');
        const wsColumns = whitespaceObj.columns.map(function (col) {
            return col.collection;
        });
        const wsRows = whitespaceObj.rows.map(function (row) {
            return row.collection;
        });
        var service = component.find('whiteSpaceService');

        service
            .updateWhiteSpaceRowsAndColumns(whitespaceObj.id, wsRows, wsColumns)
            .then(
                $A.getCallback(function (newWhiteSpaceObj) {
                    var changeEvent = component.getEvent('onChangesSaved');

                    changeEvent.setParams({
                        newValue: newWhiteSpaceObj
                    });
                    changeEvent.fire();
                    component.set('v.isSaving', false);
                    var closeEvent = component.getEvent('closeModal');

                    closeEvent.fire();
                })
            )
            .catch(
                $A.getCallback(function (err) {
                    StrategyUtils.errorToast('An error occurred while saving changes: ' + err.message);
                })
            );
    },

    onCancelClicked: function (component) {
        var closeEvent = component.getEvent('closeModal');

        closeEvent.fire();
    },

    deleteRowClicked: function (component, event, helper) {
        helper.deleteItem(component, event, true);
    },

    deleteColumnClicked: function (component, event, helper) {
        helper.deleteItem(component, event, false);
    },

    rowOrderChanged: function (component, event, helper) {
        helper.orderChanged(component, event, true);
    },

    columnOrderChanged: function (component, event, helper) {
        helper.orderChanged(component, event, false);
    },

    handleAddRowClick: function (component, event, helper) {
        var ws = component.get('v.whitespaceObj');
        const addRowCmp = component.find('addRow');
        const addObj = addRowCmp.get('v.value');

        helper.handleAddClick(component, ws.rows, addObj);

        // Clear Field
        addRowCmp.clearInput();
    },

    handleAddColumnClick: function (component, event, helper) {
        var ws = component.get('v.whitespaceObj');
        const addColumnCmp = component.find('addColumn');
        const addObj = addColumnCmp.get('v.value');

        helper.handleAddClick(component, ws.columns, addObj);

        // Clear Field
        addColumnCmp.clearInput();
    }
});