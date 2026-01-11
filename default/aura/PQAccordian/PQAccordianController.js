({
    doInit: function (component) {
        var isDefaultExpanded = component.get('v.isDefaultExpanded');

        component.set('v.isExpanded', isDefaultExpanded);
    },

    handleClick: function (component) {
        var isExpanded = component.get('v.isExpanded');

        component.set('v.isExpanded', !isExpanded);
    }
});