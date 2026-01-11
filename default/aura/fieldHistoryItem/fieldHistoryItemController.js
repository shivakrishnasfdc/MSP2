({
    init: function (component) {
        var history = component.get('v.history');

        component.set('v.hasValues', history.oldValue || history.newValue);
    },

    navigateRecord: function (component, event) {
        var navEvent = $A.get('e.force:navigateToSObject');

        navEvent.setParams({
            recordId: event.target.rel,
            slideDevName: 'detail'
        });

        navEvent.fire();
    }
});