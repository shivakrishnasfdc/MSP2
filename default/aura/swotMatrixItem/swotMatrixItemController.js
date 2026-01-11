({
    onEditItem: function (component) {
        component.set('v.itemCopy', Object.assign({}, component.get('v.item')));
        var updateItemEvent = component.getEvent('updateItem');

        updateItemEvent.setParams({
            item: Object.assign({}, component.get('v.item'))
        });
        updateItemEvent.fire();
    },

    onDeleteItem: function (component) {
        var deleteItemEvent = component.getEvent('deleteItem');

        deleteItemEvent.setParams({
            item: component.get('v.item')
        });
        deleteItemEvent.fire();
    }
});