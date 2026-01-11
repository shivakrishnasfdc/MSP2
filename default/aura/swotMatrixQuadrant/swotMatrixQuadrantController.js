({
    init: function (component) {
        var itemsList = [];

        itemsList.push({
            label: $A.get('$Label.c.Add'),
            value: 'add'
        });
        component.set('v.itemsList', itemsList);
    },

    onMenuSelect: function (component, event) {
        if (event.getParam('value') === 'add') {
            var addItemEvent = component.getEvent('addItem');

            addItemEvent.setParams({
                item: {
                    sobjectType: 'pqcrush__SWOT_Analysis__c',
                    RecordTypeId: component.get('v.recordTypeId'),
                    Name: '',
                    pqcrush__Description__c: '',
                    pqcrush__Account_Plan__c: ''
                }
            });
            addItemEvent.fire();
        }
    }
});