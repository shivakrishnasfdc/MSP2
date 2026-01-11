({
    doInit: function (component) {
        var cols = component.get('v.columns');
        var isHeader = component.get('v.isHeaderRow');
        var orderedData = [];

        cols.forEach(function (col) {
            var cellObject = isHeader ? col.name : '';

            orderedData.push(cellObject);
        });
        component.set('v.orderedRowData', orderedData);
    },
    resourcesLoaded: function (component, event, helper) {
        helper.sortData(component);
    },
    dataChanged: function (component, event, helper) {
        helper.sortData(component);
    }
});