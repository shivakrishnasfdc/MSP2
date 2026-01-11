({
    upClicked: function (component) {
        var index = component.get('v.index');

        if (index > 0) {
            var changeEvent = component.getEvent('onOrderChanged');

            changeEvent.setParams({
                index: index,
                newIndex: index - 1
            });
            changeEvent.fire();
        }
    },

    downClicked: function (component) {
        var index = component.get('v.index');
        var isLastItem = component.get('v.isLastItem');

        if (!isLastItem) {
            var changeEvent = component.getEvent('onOrderChanged');

            changeEvent.setParams({
                index: index,
                newIndex: index + 1
            });
            changeEvent.fire();
        }
    },

    onEditTextValueChanged: function (component, event) {
        var index = component.get('v.index');

        var changeEvent = component.getEvent('onValueChanged');

        changeEvent.setParams({
            index: index,
            newValue: event.getParams().newValue
        });
        changeEvent.fire();
    },

    onEditTextDelete: function (component) {
        var index = component.get('v.index');

        var changeEvent = component.getEvent('onDelete');

        changeEvent.setParams({
            index: index
        });
        changeEvent.fire();
    }
});