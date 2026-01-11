({
    init: function (component) {
        var action = component.get('c.loadData');
        $A.enqueueAction(action);

        var sortValues = component.get('c.getSortOrderValues');
        var opts = [];
        sortValues.setCallback(this, function (a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                let text = a.getReturnValue()[i];
                const myArray = text.split(',');
                let sortLabel = myArray[0];
                let sortApiName = myArray[1];

                opts.push({ class: 'optionClass', label: sortLabel, value: sortApiName });

                component.set('v.defaultSortOrder', sortApiName);
            }
            component.set('v.options', opts);
        });

        var defaultSort = component.get('c.getRmSortOrder');
        defaultSort.setParams({ accPlanId: component.get('v.recordId') });
        defaultSort.setCallback(this, function (ds) {
            component.set('v.defaultSortOrder', ds.getReturnValue());
        });

        $A.enqueueAction(sortValues);
        $A.enqueueAction(defaultSort);
    },

    loadData: function (component) {
        component.set('v.isLoading', true);

        let accountPlanRecordId = component.get('v.recordId');

        const params = {
            accountPlanId: accountPlanRecordId
        };

        StrategyUtils.executeAction(component, 'c.getRelationshipMapsByAccountPlan', params)
            .then(
                $A.getCallback(function (relationshipMaps) {
                    component.set('v.maps', relationshipMaps);
                    component.set('v.isLoading', false);

                    if (component.get('v.sObjectName') === 'pqcrush__Account_Plan__c') {
                        component.set('v.newRelationshipMap', true);
                    }
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast(error.message);
                    component.set('v.isLoading', false);
                })
            );
    },

    handleClick: function (component) {
        if (component.get('v.sObjectName') === 'pqcrush__Account_Plan__c') {
            component.find('pqAddRelationshipMapModal').openModel();
        }
    },

    getValueFromLwc: function (component) {
        var action = component.get('c.loadData');
        $A.enqueueAction(action);

        var settab = component.get('c.setActiveTab');
        $A.enqueueAction(settab);
    },

    setActiveTab: function (component) {
        if (component.get('v.maps').length !== 0) {
            component.set('v.selTabId', component.get('v.maps')[0].Name);
        }
    },

    handleChange: function (component, event) {
        var action = component.get('c.updateAccountPlanRelationShipSort');
        var order = event.getParam('value');
        action.setParams({ sortOrder: order, accPlanId: component.get('v.recordId') });
        $A.enqueueAction(action);

        var sectionContainer = component.find('collapsibleSectionContainer');
        $A.util.toggleClass(sectionContainer, 'slds-is-open');

        var a = component.get('c.init');
        a.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                StrategyUtils.successToast('Order updated!');
            }
        });
        $A.enqueueAction(a);
    },

    handleSectionHeaderClick: function (component, event) {
        var button = event.getSource();
        button.set('v.state', !button.get('v.state'));

        var sectionContainer = component.find('collapsibleSectionContainer');
        $A.util.toggleClass(sectionContainer, 'slds-is-open');
    }
});