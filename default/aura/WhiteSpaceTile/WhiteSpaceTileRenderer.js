({
    afterRender: function (component) {
        this.superAfterRender();
        var headerColor = component.get('v.headerBackgroundColor');
        var header = component.find('wsTileHeader');
        var headerElement = header.getElement();

        if (headerElement) {
            headerElement.style.backgroundColor = headerColor;
        }
    },

    rerender: function (component) {
        this.superRerender();
        var headerColor = component.get('v.headerBackgroundColor');
        var header = component.find('wsTileHeader');
        var headerElement = header.getElement();

        if (headerElement) {
            headerElement.style.backgroundColor = headerColor;
        }
    }
});