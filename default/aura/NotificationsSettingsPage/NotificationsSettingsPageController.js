({
    handleChange: function (component) {
        const compEvent = component.getEvent('SaveClickEvent');

        compEvent.fire();
    }
});