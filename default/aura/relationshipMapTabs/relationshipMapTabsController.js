({
    init: function (component) {
        component.set('v.isLoading', true);

        let masterAccountPlanRecordId = component.get('v.recordId');

        const params = {
            masterAccountPlanId: masterAccountPlanRecordId
        };

        StrategyUtils.executeAction(component, 'c.getRelationshipMapsByMasterAccountPlan', params)
            .then(
                $A.getCallback(function (relationshipMaps) {
                    component.set('v.maps', relationshipMaps);
                    component.set('v.isLoading', false);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast(error.message);
                    component.set('v.isLoading', false);
                })
            );

        var sortValues = component.get('c.getSortOrderValues');
        var opts = [];
        sortValues.setCallback(this, function(a) {
            for (var i=0;i< a.getReturnValue().length;i++){

                let text = a.getReturnValue()[i];
                const myArray = text.split(',');
                let sortLabel = myArray[0];
                let sortApiName = myArray[1];

                opts.push({'class': 'optionClass', label: sortLabel, value: sortApiName});

                component.set('v.defaultSortOrder', sortApiName);
            }
            component.set('v.options', opts);
        });

        var defaultSort = component.get('c.getRmSortOrder');
        defaultSort.setCallback(this, function(ds) {
            component.set('v.defaultSortOrder', ds.getReturnValue());
        });

        $A.enqueueAction(sortValues); 
        $A.enqueueAction(defaultSort); 
    },

    handleChange : function(component, event) {
        var action = component.get('c.updateAccountPlanSort');
        var order = event.getParam( 'value' );
        action.setParams({ sortOrder : order});
        $A.enqueueAction(action);
            
        var sectionContainer = component.find('collapsibleSectionContainer');
        $A.util.toggleClass(sectionContainer, 'slds-is-open');

        var a = component.get('c.init');
        a.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                StrategyUtils.successToast('Order updated!');
            }
        });
        $A.enqueueAction(a);

    },

    handleSectionHeaderClick : function(component, event) {
        var button = event.getSource();
        button.set('v.state', !button.get('v.state'));

        var sectionContainer = component.find('collapsibleSectionContainer');
        $A.util.toggleClass(sectionContainer, 'slds-is-open');
    }

});