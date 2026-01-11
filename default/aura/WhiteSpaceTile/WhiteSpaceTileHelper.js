({
    applyElevation: function (component) {
        component.set('v.isElevated', true);
    },

    removeElevation: function (component) {
        component.set('v.isElevated', false);
    },

    handleIESupport: function (component) {
        var service = component.find('utilityForBrowserSupport');

        component.set('v.isBrowserIE', service.isBrowserIE());
    },

    setHeaderTextAndBackgroundColor: function (component) {
        var data = component.get('v.record');

        component.set('v.headerTitle', data.headerText ? data.headerText : '');
        component.set('v.headerBackgroundColor', data.headerColor ? data.headerColor : '');
    },

    checkIfData: function (component) {
        var record = component.get('v.record');
        var hasData = record.displayFields.some(function (displayField) {
            return (
                displayField.data.length > 0 &&
                displayField.data.some(function (data) {
                    return !$A.util.isEmpty(data.value) && data.value !== 0;
                })
            );
        });

        component.set('v.hasData', hasData);
    }
});