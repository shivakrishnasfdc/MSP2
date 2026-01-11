({
    doInit: function (component) {
        let recordId = component.get('v.recordId');
        let sObjectName = component.get('v.sObjectName');

        if (sObjectName && sObjectName === 'pqcrush__Relationship_Map__c') {
            component.set('v.mapId', recordId);
        } else {
            var action = component.get('c.getMapIdForSObjectIdNoCreate');

            action.setParams({ recordId: recordId });

            // CONFIGURE RESPONSE HANDLER
            action.setCallback(this, function (response) {
                if (component.isValid() && response.getState() === 'SUCCESS') {
                    let mapId = response.getReturnValue();

                    component.set('v.mapId', mapId);
                }
            });

            $A.enqueueAction(action);
        }
    }
});