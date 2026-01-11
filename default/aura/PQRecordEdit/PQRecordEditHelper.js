({
    fireAppEvent: function (event, recordId) {
        const appEvent = $A.get('e.c:PQApplicationEvent');

        appEvent.setParams({
            appEventKey: event,
            appEventValue: recordId
        });
        appEvent.fire();
    }
});