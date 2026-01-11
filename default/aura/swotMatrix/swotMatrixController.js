({
    doInit: function (component, event, helper) {
        const recordId = component.get('v.recordId');
        const userRecordAccessService = component.find('userRecordAccessService');

        const promises = [
            StrategyUtils.executeAction(component, 'c.getSWOTMatrix', {
                accountPlanId: recordId
            }),
            userRecordAccessService.getUserRecordAccess(recordId)
        ];

        component.set('v.isLoading', true);
        Promise.all(promises)
            .then(
                $A.getCallback(function (result) {
                    const matrix = result[0];

                    component.set('v.swotMatrix', matrix);
                    helper.categorizeItems(component, matrix.items);
                    const accountPlanAccess = result[1];

                    component.set('v.accountPlanAccess', accountPlanAccess);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast('An error occurred while loading data: ' + error.message);
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                })
            );
    },

    onAddItem: function (component, event) {
        component.set('v.isUpdating', false);
        var newItem = event.getParam('item');

        newItem.pqcrush__Account_Plan__c = component.get('v.recordId');
        component.set('v.itemToUpdate', newItem);
        component.set('v.modalTitle', $A.get('$Label.c.Create_SWOT_Analysis'));
        StrategyUtils.showModal(component, 'SWOTModal');
    },

    onCancel: function (component) {
        StrategyUtils.hideModal(component, 'SWOTModal');
    },

    onUpdateThisItem: function (component, event) {
        component.set('v.isUpdating', true);
        var itemToUpdate = event.getParam('item');
		var sanitizedItemName = this.escapeHtml(itemToUpdate.Name);
        component.set('v.itemToUpdate', itemToUpdate);
        const service = component.find('stringUtilService');

        component.set('v.modalTitle', service.formatLabel($A.get('$Label.c.Edit_Title'), [sanitizedItemName]));
        StrategyUtils.showModal(component, 'SWOTModal');
    },

    onUpdateConfirm: function (component, event, helper) {
        var isUpdating = component.get('v.isUpdating');
        var item = component.get('v.itemToUpdate');

        if (isUpdating) {
            helper.saveEditItem(component, item);
        } else {
            helper.addItem(component, item);
        }
        StrategyUtils.hideModal(component, 'SWOTModal');
    },

    onDeleteItem: function (component, event) {
        var item = event.getParam('item');

        component.set('v.itemToDelete', item);
        StrategyUtils.showModal(component, 'deleteSWOTModal');
    },

    onDeleteCancel: function (component) {
        StrategyUtils.hideModal(component, 'deleteSWOTModal');
    },

    onDeleteConfirm: function (component, event, helper) {
        var item = component.get('v.itemToDelete'),
            arrayAttribute = helper.getArrayAttributeForItem(component, item),
            array = component.get(arrayAttribute),
            index = helper.indexOf(array, item);

        // Delete the item on screen, we'll add it back later if the server delete fails
        array.splice(index, 1);
        component.set(arrayAttribute, array);
        StrategyUtils.hideModal(component, 'deleteSWOTModal');

        StrategyUtils.executeAction(component, 'c.deleteItem', { item: item })
            .then(
                $A.getCallback(function () {
                    helper.eventService(component).fireAppEvent('REFRESH_HISTORY');
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while deleting "' + item.Name + '".');

                    // Add the item back
                    array.splice(index, 0, item);
                    component.set(arrayAttribute, array);
                })
            );
    },

    fullScreenHandler: function (component) {
        const isExpanding = !component.get('v.isExpanded');

        if (isExpanding) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = '';
        }
        component.set('v.isExpanded', isExpanding);
    }
});