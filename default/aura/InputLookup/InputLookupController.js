({
    init: function (component) {
        if (!$A.util.isEmpty(component.get('v.selectedRecordId'))) {
            StrategyUtils.executeAction(component, 'c.getCurrentSelectionResultObj', {
                id: component.get('v.selectedRecordId'),
                displayFieldName: component.get('v.displayFieldApiName')
            })
                .then(
                    $A.getCallback(function (returnValue) {
                        component.set('v.selection', returnValue);
                    })
                )
                .catch(
                    $A.getCallback(function (error) {
                        StrategyUtils.errorToast(error.message);
                    })
                );
        }
    },

    search: function (component) {
        const params = {
            type: component.get('v.objectType'),
            searchString: component.get('v.searchTerm'),
            displayFieldName: component.get('v.displayFieldApiName'),
            selectedIds: component.get('v.ignoreIds')
        };

        StrategyUtils.executeAction(component, 'c.searchSObject', params)
            .then(
                $A.getCallback(function (returnValue) {
                    component.set('v.searchResults', returnValue);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast(error.message);
                })
            );
    },

    onInput: function (component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        const newSearchTerm = event.target.value;

        helper.updateSearchTerm(component, newSearchTerm);
    },

    onResultClick: function (component, event, helper) {
        const recordId = event.currentTarget.id;

        helper.selectResult(component, recordId);
    },

    onComboboxClick: function (component) {
        // Hide combobox immediatly
        const blurTimeout = component.get('v.blurTimeout');

        if (blurTimeout) {
            window.clearTimeout(blurTimeout);
        }
        component.set('v.hasFocus', false);
    },

    onFocus: function (component, event, helper) {
        component.set('v.focusedIndex', -1);

        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        component.set('v.hasFocus', true);
    },

    onBlur: function (component, event, helper) {
        // Prevent action if selection is not allowed
        if (!helper.isSelectionAllowed(component)) {
            return;
        }

        // Delay hiding combobox so that we can capture selected result
        const blurTimeout = window.setTimeout(
            $A.getCallback(function () {
                component.set('v.hasFocus', false);
                component.set('v.blurTimeout', null);
            }),
            300
        );

        component.set('v.blurTimeout', blurTimeout);
    },

    onClearSelection: function (component, event, helper) {
        helper.clearSelection(component);
    },

    onKeyDown: function (component, event, helper) {
        var keyCode = event.keyCode,
            focusedIndex = component.get('v.focusedIndex'),
            oldFocusedIndex = focusedIndex,
            results = component.get('v.searchResults');

        switch (keyCode) {
            case helper.ARROW_UP:
                focusedIndex -= 1;
                break;
            case helper.ARROW_DOWN:
                focusedIndex += 1;
                break;
            case helper.ENTER:
                if (!$A.util.isEmpty(results[focusedIndex])) {
                    helper.selectResult(component, results[focusedIndex].id);

                    return;
                }
                if (results.length === 1 && !$A.util.isEmpty(results[0])) {
                    helper.selectResult(component, results[0].id);

                    return;
                }
                break;
            case helper.ESCAPE:
                component.set('v.hasFocus', false);
                break;
        }

        if (focusedIndex !== oldFocusedIndex) {
            if (focusedIndex < 0) {
                focusedIndex = results.length - 1;
            } else if (focusedIndex >= results.length) {
                focusedIndex = 0;
            }

            var options = component.find('result');

            $A.util.addClass(options[focusedIndex], 'slds-has-focus');
            $A.util.removeClass(options[oldFocusedIndex], 'slds-has-focus');
        }

        component.set('v.focusedIndex', focusedIndex);
    }
});