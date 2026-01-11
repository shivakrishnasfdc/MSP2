({
    handleRadioSelect: function (component) {
        const changeEvent = component.getEvent('onchange');
        var params = {
            value: component.get('v.id')
        };

        changeEvent.setParams(params);
        changeEvent.fire();
    }
});