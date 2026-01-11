({
    categorizeItems: function (component, items) {
        var strengths = [],
            weaknesses = [],
            opportunities = [],
            threats = [];

        items.forEach(function (item) {
            var type = item.RecordType.DeveloperName;

            if (type === 'Strength') {
                strengths.push(item);
            } else if (type === 'Weakness') {
                weaknesses.push(item);
            } else if (type === 'Opportunity') {
                opportunities.push(item);
            } else if (type === 'Threat') {
                threats.push(item);
            }
        });

        component.set('v.strengths', strengths);
        component.set('v.weaknesses', weaknesses);
        component.set('v.opportunities', opportunities);
        component.set('v.threats', threats);
    },

    eventService: function (component) {
        return component.find('eventService');
    },

    getArrayAttributeForItem: function (component, item) {
        var recordTypeId = item.RecordTypeId,
            matrix = component.get('v.swotMatrix');

        if (recordTypeId === matrix.strengthRecordTypeId) {
            return 'v.strengths';
        } else if (recordTypeId === matrix.weaknessRecordTypeId) {
            return 'v.weaknesses';
        } else if (recordTypeId === matrix.opportunityRecordTypeId) {
            return 'v.opportunities';
        } else if (recordTypeId === matrix.threatRecordTypeId) {
            return 'v.threats';
        } else {
            return null;
        }
    },

    indexOf: function (array, itemToFind) {
        var index = -1;

        array.some(function (item, i) {
            if (itemToFind.Id === item.Id) {
                index = i;
            }

            return index > -1;
        });

        return index;
    },

    saveEditItem: function (component, item) {
        if (item.Name.trim().length === 0) {
            item.Name = '';
            component.set('v.itemCopy', item);
            var inputCmp = component.find('editName');

            inputCmp.showHelpMessageIfInvalid();

            return;
        }

        this.updateItem(component, item);
    },

    updateItem: function (component, updatedItem) {
        var arrayAttribute = this.getArrayAttributeForItem(component, updatedItem);
        var array = component.get(arrayAttribute);
        var index = this.indexOf(array, updatedItem);
        var originalItem = array[index];
        var self = this;

        // Update the item on screen, we'll revert it later if the server update fails
        component.set(arrayAttribute + '[' + index + ']', updatedItem);

        StrategyUtils.executeAction(component, 'c.updateItem', {
            item: updatedItem
        })
            .then(
                $A.getCallback(function () {
                    self.eventService(component).fireAppEvent('REFRESH_HISTORY');
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while saving "' + originalItem.Name + '".');

                    // Revert to the original values for the item
                    component.set(arrayAttribute + '[' + index + ']', originalItem);
                })
            );
    },

    addItem: function (component, item) {
        var arrayAttribute = this.getArrayAttributeForItem(component, item);
        var array = component.get(arrayAttribute);
        var self = this;

        if (item.Name.trim().length === 0) {
            item.Name = '';
            component.set('v.itemToUpdate', item);
            var inputCmp = component.find('newName');

            inputCmp.showHelpMessageIfInvalid();

            return;
        }

        // Add the item on screen, we'll revert it later if the server call fails
        array.push(item);
        component.set(arrayAttribute, array);

        StrategyUtils.executeAction(component, 'c.createItem', { item: item })
            .then(
                $A.getCallback(function (newItem) {
                    self.eventService(component).fireAppEvent('REFRESH_HISTORY');

                    // Set Id on new item
                    var index = array.length - 1;

                    component.set(arrayAttribute + '[' + index + ']', newItem);
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while creating "' + item.Name + '".');

                    // Delete the new item
                    array.splice(array.length - 1, 1);
                    component.set(arrayAttribute, array);
                })
            );
    }
});