({
    handleChange: function (component) {
        let selections = {
            selectedAmountTypes: component.get('v.selectedAmountTypes'),
            selectedRows: component.get('v.selectedRows'),
            selectedColumns: component.get('v.selectedColumns')
        };

        var selectEvt = component.getEvent('onselect');

        selectEvt.setParams({ selections });
        selectEvt.fire();
    }
});