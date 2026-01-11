({
    onRender: function (component) {
        const filterLabel = component.get('v.filterLabel');

        if (filterLabel) {
            component.set('v.finalLabel', component.get('v.filterLabel'));

            return;
        }

        var filters = component.get('v.filterArrays');
        const labelTitle = $A.get('$Label.c.Displaying');
        let finalLabel = '';

        filters.forEach((f) => {
            if (f.filters) {
                f.filters.forEach((fo) => {
                    if (fo.isSelected) {
                        finalLabel += fo.label + ', ';
                    }
                });
            }
        });

        if (finalLabel.length > 1) {
            finalLabel = finalLabel.slice(0, -2);
        }

        component.set('v.finalLabel', labelTitle + ': ' + finalLabel);
    },

    handleFilterButtonClick: function (component) {
        var filters = component.get('v.filterArrays');
        var copy = JSON.parse(JSON.stringify(filters));

        component.set('v.tempFilterArrays', copy);
        component.set('v.filtering', true);
    },

    handleFilterCancel: function (component, event, helper) {
        helper.closePopover(component);
    },

    handleRadioSelect: function (component, event) {
        var radioComponents = component.find('radio');
        var radioComponentName = event.getSource().get('v.name');
        var selectedRadio = event.getSource().get('v.value');
        var radiosToUnselect = radioComponents.filter(function (item) {
            return item.get('v.name') === radioComponentName && item.get('v.value') !== selectedRadio;
        });

        radiosToUnselect.forEach(function (item) {
            item.set('v.checked', false);
        });
    },

    handleFilterApply: function (component, event, helper) {
        var radioFilters = component.find('radio');
        var checkboxFilters = component.find('checkbox');
        var appliedFilters = [];
        var appliedFilterCount = 0;

        var filtersList = component
            .get('v.filterArrays')
            .map(function (filterArray) {
                return filterArray.filters;
            })
            .reduce(function (prev, curr) {
                return prev.concat(curr);
            });

        function _findCheckedFilters(item) {
            if (item.get('v.checked')) {
                var itemValue = item.get('v.value');
                var filterObj = filtersList.find(function (element) {
                    return element.value === itemValue;
                });

                appliedFilters.push(filterObj);
            }
        }

        var filters = component.get('v.tempFilterArrays');

        component.set('v.filterArrays', filters);

        if (radioFilters) {
            var radioArray = Array.isArray(radioFilters) ? radioFilters : new Array(radioFilters);

            radioArray.forEach(_findCheckedFilters);
        }

        if (checkboxFilters) {
            var checkBoxArray = Array.isArray(checkboxFilters) ? checkboxFilters : new Array(checkboxFilters);

            checkBoxArray.forEach(_findCheckedFilters);
        }

        appliedFilters.forEach(function (item) {
            if (!item.isDefault) {
                appliedFilterCount++;
            }
        });

        helper.updateFilterLabelWithCount(component, appliedFilterCount);

        var updateEvent = component.getEvent('updateAppliedFilters');

        updateEvent.setParams({
            filters: appliedFilters,
            name: component.get('v.name')
        });
        updateEvent.fire();

        helper.closePopover(component);
    }
});