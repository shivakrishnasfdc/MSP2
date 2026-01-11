({
    handleFireApplicationEvent: function (component, event) {
        const params = event.getParam('arguments');
        const appEvent = $A.get('e.c:PQApplicationEvent');

        appEvent.setParams({
            appEventKey: params.eventKey,
            appEventValue: params.eventValue
        });
        appEvent.fire();
    }
});