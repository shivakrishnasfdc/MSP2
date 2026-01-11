({
    onCancel: function (component) {
        var closeEvent = component.getEvent('closeModal');

        closeEvent.fire();
    },

    onConfirm: function (component) {
        var closeEvent = component.getEvent('onPrimaryActionClicked');

        closeEvent.fire();
    }
});