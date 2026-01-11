({
    doInit: function (component) {
        var service = component.find('utilityForBrowserSupport');

        component.set('v.supportsGridElement', !service.isBrowserIE());
    },

    addHandler: function (component) {
        const records = component.get('v.records');

        const columnId = component.get('v.columnId');
        const rowId = component.get('v.rowId');
        const whiteSpaceId = component.get('v.whiteSpaceId');

        const service = component.find('whiteSpaceService');

        service
            .createWhiteSpaceCell(whiteSpaceId, rowId, columnId)
            .then(
                $A.getCallback(function (result) {
                    records.push(result);
                    component.set('v.records', records);
                })
            )
            .catch(
                $A.getCallback(function (err) {
                    StrategyUtils.errorToast('An error occurred while saving changes: ' + err.message);
                })
            );
    },

    cellDeleteConfirmed: function (component, event) {
        var params = event.getParams();
        var recordId = params.id;
        var records = component.get('v.records');

        const result = records.filter(function (record) {
            return record.id !== recordId;
        });

        component.set('v.records', result);
    },

    handleOnEdit: function (component, event) {
        var params = event.getParams();
        var recordId = params.id;
        var state = params.state;

        if (state === 'beginedit') {
            component.set('v.isEditing', true);
        } else {
            component.set('v.isEditing', false);
        }

        var records = component.get('v.records');

        records.forEach(function (record) {
            if (record.id === recordId && state === 'beginedit') {
                record.editing = true;
            } else {
                record.editing = false;
            }
        });

        component.set('v.records', records);
    }
});