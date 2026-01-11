({
    swapItem: function (list, index, newIndex) {
        // RETURN IF OUT OF BOUNDS
        if (newIndex < 0 || newIndex >= list.length) {
            return;
        }

        var item = list[index];
        var swapItem = list[newIndex];

        var tempOrder = item.collection.pqcrush__Order__c;

        item.collection.pqcrush__Order__c = swapItem.collection.pqcrush__Order__c;
        swapItem.collection.pqcrush__Order__c = tempOrder;

        list[newIndex] = JSON.parse(JSON.stringify(item));
        list[index] = JSON.parse(JSON.stringify(swapItem));
    },

    updateRowColumnName: function (component, event, isRow) {
        var params = event.getParams();
        var index = params.index;
        var newName = params.newValue;

        var whitespace = component.get('v.whitespaceObj');
        var list = isRow ? whitespace.rows : whitespace.columns;

        if (index < list.length) {
            var item = list[index];

            item.collection.Name = newName;
            item.name = newName;
            component.set('v.whitespaceObj', whitespace);
            this.checkChangesMade(component);
        }
    },

    deleteItem: function (component, event, isRow) {
        event.stopPropagation();
        var params = event.getParams();

        var whitespace = component.get('v.whitespaceObj');
        var list = isRow ? whitespace.rows : whitespace.columns;

        if (!$A.util.isEmpty(list[params.index].collection.pqcrush__Related_Object_Id__c)) {
            const ignoredListName = isRow ? 'v.selectedRowRelatedObjectIds' : 'v.selectedColumnRelatedObjectIds';
            const ignoredList = component.get(ignoredListName);

            ignoredList.splice(ignoredList.indexOf(list[params.index].collection.pqcrush__Related_Object_Id__c), 1);
            component.set(ignoredListName, ignoredList);
        }

        list.splice(params.index, 1);
        component.set('v.whitespaceObj', whitespace);
        this.checkChangesMade(component);
    },

    orderChanged: function (component, event, isRow) {
        event.stopPropagation();
        var params = event.getParams();

        var whitespace = component.get('v.whitespaceObj');
        var list = isRow ? whitespace.rows : whitespace.columns;

        this.swapItem(list, params.index, params.newIndex);

        component.set('v.whitespaceObj', whitespace);
        this.checkChangesMade(component);
    },

    handleAddClick: function (component, list, addObj) {
        var ws = component.get('v.whitespaceObj');
        var order = 0;

        if (list.length > 0) {
            order = parseInt(list[list.length - 1].collection.pqcrush__Order__c);
        }
        var newItem = {
            collection: {
                pqcrush__White_Space__c: ws.id,
                Name: addObj.name,
                pqcrush__Related_Object_Id__c: addObj.relatedObjectId,
                pqcrush__Order__c: order + 1
            },
            name: addObj.name
        };

        list.push(newItem);

        component.set('v.whitespaceObj', ws);
        this.checkChangesMade(component);
    },

    checkChangesMade: function (component) {
        var original = component.get('v.originalWhitespaceObj');
        var dirty = component.get('v.whitespaceObj');

        if (_.isEqual(original, dirty)) {
            component.set('v.changesMade', false);
        } else {
            component.set('v.changesMade', true);
        }
    }
});