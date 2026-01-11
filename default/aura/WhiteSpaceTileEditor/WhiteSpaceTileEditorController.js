({
    doInit: function (component, event, helper) {
        helper.triggerEditActionEvent(component, 'beginedit');
        var record = component.get('v.record');

        var recordDirty = JSON.parse(JSON.stringify(record));

        recordDirty.displayFields.forEach(function (df) {
            if (!df.data) {
                df.data = [];
            }
            if (df.data.length === 0) {
                df.data.push({ value: 0, displayName: df.displayName, objectId: null });
            }
        });
        component.set('v.recordDirty', recordDirty);
        helper.initHeaderOptions(component);
    },

    handleHeaderValueChanged: function (component) {
        var recordDirty = component.get('v.recordDirty');
        var dirtyDisplayFields = recordDirty.displayFields;
        var newValue = component.find('wsLabelSelect').get('v.value');

        dirtyDisplayFields.forEach(function (option) {
            option.isPrimary = option.id ? newValue && option.id === newValue : false;
        });
    },

    onSave: function (component, event, helper) {
        var updatedRecord = component.get('v.recordDirty');

        updatedRecord.displayFields.forEach(function (df) {
            df.data = df.data.filter(function (dataItem) {
                return dataItem.value !== 0 || dataItem.objectId !== null; // Only include items with a value or that pre-existed
            });
        });
        var service = component.find('wsService');

        service
            .updateWhiteSpaceCell(updatedRecord)
            .then(
                $A.getCallback(function (result) {
                    var oldRecord = component.get('v.record');
                    var newRecord = result;

                    component.set('v.record', newRecord);
                    var changeEvent = component.getEvent('onCellDataChanged');
                    var eventParams = {
                        newValue: newRecord,
                        oldValue: oldRecord,
                        id: newRecord.id
                    };

                    changeEvent.setParams(eventParams);
                    changeEvent.fire();
                    helper.triggerEditActionEvent(component, 'endedit');
                })
            )
            .catch(
                $A.getCallback(function (err) {
                    StrategyUtils.errorToast(err.message);
                })
            );
    },

    onCancel: function (component, event, helper) {
        helper.triggerEditActionEvent(component, 'endedit');
    }
});