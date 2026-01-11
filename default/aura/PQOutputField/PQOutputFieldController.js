({
    doInit: function (component) {
        const value = component.get('v.fieldValue');
        const type = component.get('v.displayType');
        const displayValue = component.find('dataFormatUtils').formatDataValue(value, type);

        component.set('v.displayValue', displayValue);
    }
});