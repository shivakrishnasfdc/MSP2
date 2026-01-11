({
    sortData: function (component) {
        var fullData = component.get('v.rowData');

        fullData = fullData ? fullData : [];
        var groupedData = _.groupBy(fullData, 'column');
        var cols = component.get('v.columns');
        var isHeader = component.get('v.isHeaderRow');
        var orderedData = _.map(cols, function (col) {
            if (isHeader) {
                return col.name;
            }
            var cellArray = groupedData[col.id] ? groupedData[col.id] : [];
            var cellObject = cellArray.length > 0 ? cellArray[0] : {};
            var cellData = cellObject.display ? cellObject.display : '';

            return cellData;
        });

        component.set('v.orderedRowData', orderedData);
    }
});