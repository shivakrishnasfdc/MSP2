({
    afterRender: function (component) {
        this.superAfterRender();
        var color = component.get('v.backgroundColor');
        var cell = component.find('cellBackground');
        var cellElement = cell.getElement();

        if (cellElement) {
            cellElement.style.backgroundColor = color;
        }
    },
    reRender: function (component) {
        this.superReRender();
        var color = component.get('v.backgroundColor');
        var cell = component.find('cellBackground');
        var cellElement = cell.getElement();

        if (cellElement) {
            cellElement.style.backgroundColor = color;
        }
    }
});