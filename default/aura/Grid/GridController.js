({
    doInit: function (component, event, helper) {
        var rows = component.get('v.rows');
        var orderedData = [];

        rows.forEach(function (row) {
            orderedData.push({
                name: row.name,
                data: []
            });
        });
        component.set('v.orderedGridData', orderedData);
        helper.handleColumnDisplay(component);
    },

    resourcesLoaded: function (component, event, helper) {
        component.set('v.lodashLoaded', true);
        helper.sortData(component);
    },

    dataChanged: function (component, event, helper) {
        helper.sortData(component);
        helper.handleColumnDisplay(component);
    },

    columnDisplayChanged: function (component, event, helper) {
        helper.handleColumnDisplay(component);
    }
});