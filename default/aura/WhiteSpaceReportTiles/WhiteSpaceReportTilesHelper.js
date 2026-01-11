({
    SMALL_SIZE: 480,
    MEDIUM_SIZE: 768,
    LARGE_SIZE: 1024,

    handleWhiteSpaceResult: function (component, whiteSpace) {
        if ($A.util.isEmpty(whiteSpace)) {
            component.set('v.amountTypeSums', null);
            component.set('v.data', []);
            component.set('v.numberOfColumns', 0);
        } else {
            component.set('v.numberOfColumns', whiteSpace.columns.length);
            this.createCellData(component, whiteSpace.id, whiteSpace.cells);
        }
    },

    updateCellData: function (component, tileId, newInfoText, associations) {
        var whitespace = component.get('v.whiteSpace');

        for (var i = 0; i < whitespace.cells.length; i++) {
            var cell = whitespace.cells[i];

            for (var j = 0; j < cell.tiles.length; j++) {
                var tile = cell.tiles[j];

                if (tile.id === tileId) {
                    tile.info = newInfoText;
                    tile.amountTypeAssociations = associations;
                    break;
                }
            }
        }
    },

    deleteCellData: function (component, tileId) {
        var whitespace = component.get('v.whiteSpace');

        for (var i = 0; i < whitespace.cells.length; i++) {
            var cell = whitespace.cells[i];

            for (var j = 0; j < cell.tiles.length; j++) {
                var tile = cell.tiles[j];

                if (tile.id === tileId) {
                    cell.tiles.splice(j, 1);
                    break;
                }
            }
        }
    },

    createCellData: function (component, whiteSpaceId, cells) {
        if (!cells || cells.length === 0) {
            component.set('v.data', []);
        }

        // Create an array of display components for each cell
        var componentList = [];

        var wsObjectAccess = component.get('v.whiteSpaceObjectAccess');

        cells.forEach(function (cell) {
            componentList.push([
                'c:WhiteSpaceTileList',
                {
                    whiteSpaceObjectAccess: wsObjectAccess,
                    records: cell.tiles,
                    isEditable: wsObjectAccess.canUpdate,
                    columnId: cell.columnId,
                    rowId: cell.rowId,
                    whiteSpaceId: whiteSpaceId
                }
            ]);
        });

        $A.createComponents(componentList, function (components, status) {
            if (status === 'SUCCESS') {
                // Construct the data object for each cell
                var objectList = [];

                cells.forEach(function (cell, index) {
                    objectList.push({
                        row: cell.rowId,
                        column: cell.columnId,
                        id: cell.id,
                        display: components[index]
                    });
                });
                component.set('v.data', objectList);
            }
        });
    },

    updateGridWidth: function (component) {
        var isPrinterFriendly = component.get('v.isPrinterFriendly');

        if (isPrinterFriendly) {
            this.setGridWidthToFit(component);
        } else {
            this.setGridFullWidth(component);
        }
    },

    setGridFullWidth: function (component) {
        var gridWrapper = component.find('gridWrapper');

        if (gridWrapper) {
            var gridWrapperElement = gridWrapper.getElement();

            if (gridWrapperElement) {
                gridWrapperElement.style.width = '100%';
            }
        }
    },

    setGridWidthToFit: function (component) {
        var gridWrapper = component.find('gridWrapper');

        if (gridWrapper) {
            var gridWrapperElement = gridWrapper.getElement();

            if (gridWrapperElement) {
                var viewSize = document.documentElement.clientWidth;
                var visibleColumns = 0;

                if (viewSize < this.MEDIUM_SIZE) {
                    visibleColumns = component.get('v.smallSizeColumns');
                } else if (viewSize < this.LARGE_SIZE) {
                    visibleColumns = component.get('v.mediumSizeColumns');
                } else {
                    visibleColumns = component.get('v.largeSizeColumns');
                }
                var numOfColumns = component.get('v.numberOfColumns');

                if (numOfColumns >= visibleColumns) {
                    this.setGridWidthToFitCalculation(component, gridWrapperElement, visibleColumns, numOfColumns);
                } else {
                    this.setGridFullWidth(component);
                }
            }
        }
    },

    setGridWidthToFitCalculation: function (component, element, visibleColumns, numOfColumns) {
        var gridFixedColumnWidth = 140;
        var calculationText =
            'calc((100% - ' + gridFixedColumnWidth + 'px) * ' + visibleColumns + '/' + numOfColumns + ')';

        element.style.width = calculationText;
    }
});