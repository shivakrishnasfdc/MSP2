({
    sortData: function (component) {
        const lodashLoaded = component.get('v.lodashLoaded');

        if (!lodashLoaded) {
            return;
        }
        var fullData = component.get('v.gridData');

        fullData = fullData ? fullData : [];
        var groupedData = _.groupBy(fullData, 'row');
        var rows = component.get('v.rows');
        var orderedData = _.map(rows, function (row) {
            var rowData = groupedData[row.id];

            return {
                name: row.name,
                data: rowData
            };
        });

        component.set('v.orderedGridData', orderedData);
        var header = component.find('headerRow');

        if (header) {
            header.dataChanged();
        }
    },

    handleColumnDisplay: function (component) {
        const fit = component.get('v.expandColumnsToFit');
        const smallColumns = component.get('v.smallColumns');
        const mediumColumns = component.get('v.mediumColumns');
        const largeColumns = component.get('v.largeColumns');

        if (fit) {
            // Total number of columns including the fixed header column
            const numberOfColumns = component.get('v.columns').length + 1;

            // Determines number of columns to display before scrolling for each break point based on valid slds numbers (1-8 and 12).
            let smallColumnsToUse = numberOfColumns < smallColumns ? numberOfColumns : smallColumns;

            if (smallColumnsToUse > 3) {
                smallColumnsToUse = 3;
            }
            let mediumColumnsToUse = numberOfColumns < mediumColumns ? numberOfColumns : mediumColumns;

            if (mediumColumnsToUse > 4) {
                mediumColumnsToUse = 4;
            }
            let largeColumnsToUse = numberOfColumns < largeColumns ? numberOfColumns : largeColumns;

            if (largeColumnsToUse < 12 && largeColumnsToUse > 8) {
                largeColumnsToUse = 8;
            }
            if (largeColumnsToUse > 12) {
                largeColumnsToUse = 12;
            }
            component.set('v.smallColumnsToUse', smallColumnsToUse);
            component.set('v.mediumColumnsToUse', mediumColumnsToUse);
            component.set('v.largeColumnsToUse', largeColumnsToUse);
        } else {
            component.set('v.smallColumnsToUse', smallColumns);
            component.set('v.mediumColumnsToUse', mediumColumns);
            component.set('v.largeColumnsToUse', largeColumns);
        }
    }
});