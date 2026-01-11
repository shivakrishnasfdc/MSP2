({
    loadAccountInfo: function (component) {
        // Prepare the action to load account record
        var action = component.get('c.getAccountByAccountPlanId');

        action.setParams({ accountPlanId: component.get('v.recordId') });

        // Configure response handler
        action.setCallback(this, function (response) {
            component.set('v.isLoading', false);
            this.showForm(component, 'mainForm');
            var state = response.getState();

            if (component.isValid() && state === 'SUCCESS') {
                component.set('v.account', response.getReturnValue());
            }
        });
        component.set('v.isLoading', true);
        $A.enqueueAction(action);
    },

    showAndEnableFields: function (component) {
        var action = component.get('c.getAccountDescribeFields');
        var fieldsToCheck = ['Name', 'Industry', 'Type', 'Ownership', 'AnnualRevenue'];

        action.setParams({ fieldsToCheck: fieldsToCheck });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === 'SUCCESS') {
                this.processFields(component, JSON.parse(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
    },

    processFields: function (component, describeFields) {
        for (var i = 0; i < describeFields.length; i++) {
            switch (describeFields[i].name) {
                case 'Name':
                    this.handleFormAndField(component, describeFields[i], 'accountNameForm', 'accountName');
                    break;
                case 'Type':
                    this.handleForms(component, describeFields[i], 'accountTypeInputForm', 'accountTypeOutputForm');
                    break;
                case 'Industry':
                    this.handleForms(
                        component,
                        describeFields[i],
                        'accountIndustryInputForm',
                        'accountIndustryOutputForm'
                    );
                    break;
                case 'Ownership':
                    this.handleForms(
                        component,
                        describeFields[i],
                        'accountOwnershipInputForm',
                        'accountOwnershipOutputForm'
                    );
                    break;
                case 'AnnualRevenue':
                    this.handleFormAndField(component, describeFields[i], 'accountAnnualRevenueForm', 'annualRevenue');
                    break;
                default:
                    break;
            }
        }
    },

    updateAccount: function (component, account) {
        var action = component.get('c.upsertAccount');

        action.setParams({
            account: account
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === 'SUCCESS') {
                StrategyUtils.successToast('Account updated!');
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },

    validateAccountForm: function (component) {
        // Simplistic error checking
        var validAccount = true;

        // Name must not be blank
        var nameField = component.find('accountName');
        var accountName = nameField.get('v.value');

        if ($A.util.isEmpty(accountName)) {
            validAccount = false;
            nameField.set('v.errors', [
                // Prettier-ignore
                { message: "Account name can't be blank." }
            ]);
        } else {
            nameField.set('v.errors', null);
        }

        // Annual Revenue must be set, must be a positive number
        var annualRevenueField = component.find('annualRevenue');
        var annualRevenue = annualRevenueField.get('v.value');

        if ($A.util.isEmpty(annualRevenue) || isNaN(annualRevenue)) {
            validAccount = false;
            annualRevenueField.set('v.errors', [{ message: 'Enter an annual revenue amount.' }]);
        } else {
            // If the amount looks good, unset any errors...
            annualRevenueField.set('v.errors', null);
        }

        return validAccount;
    },

    handleForms: function (component, describeField, editableFormName, nonEditableFormName) {
        if (describeField.isAccessible) {
            describeField.isUpdateable
                ? this.showForm(component, editableFormName)
                : this.showForm(component, nonEditableFormName);
        }
    },

    handleFormAndField: function (component, describeField, formName, fieldName) {
        if (describeField.isAccessible) {
            this.showForm(component, formName);
            if (describeField.isUpdateable) {
                var field = component.find(fieldName);

                field.set('v.disabled', 'false');
            }
        }
    },

    showForm: function (component, fieldName) {
        var form = component.find(fieldName);

        $A.util.removeClass(form, 'slds-hide');
    }
});