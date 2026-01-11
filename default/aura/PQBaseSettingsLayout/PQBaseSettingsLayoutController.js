({
    navigationChangeHandler: function (component, event) {
        component.set('v.activeSection', event.getParam('name'));
    }
});