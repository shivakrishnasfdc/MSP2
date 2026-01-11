({
    init: function (component, event, helper) {
        helper.showAndEnableFields(component);
        helper.loadAccountInfo(component);
    },

    handleUpdateAccount: function (component, event, helper) {
        if (helper.validateAccountForm(component)) {
            // Update account
            var account = component.get('v.account');

            helper.updateAccount(component, account);
        }
    },

    handleCancel: function () {
        $A.get('e.force:closeQuickAction').fire();
    }
});