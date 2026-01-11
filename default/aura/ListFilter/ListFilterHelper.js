({
    closePopover: function (component) {
        component.set('v.filtering', false);
    },

    updateFilterLabelWithCount: function (component, count) {
        if (count === 1) {
            component.set('v.filterCountForLabel', $A.get('$Label.c.Filter_Tasks_Applied_Singular'));
        } else if (count > 1) {
            const service = component.find('stringUtilService');

            component.set(
                'v.filterCountForLabel',
                service.formatLabel($A.get('$Label.c.Filter_Tasks_Applied_Plural'), [count])
            );
        } else {
            component.set('v.filterCountForLabel', '');
        }
    }
});