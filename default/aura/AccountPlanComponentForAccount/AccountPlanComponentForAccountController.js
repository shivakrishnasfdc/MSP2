({
    init: function (component, event, helper) {
        const accountId = component.get('v.recordId');

        helper.getAccountPlansForAccount(component, accountId);
    }
});