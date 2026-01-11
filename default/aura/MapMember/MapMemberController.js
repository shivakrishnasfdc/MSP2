({
    doInit: function (component) {
        let pageRef = component.get('v.pageReference');
        let state = pageRef.state; // State holds any query params
        let base64Context = state.inContextOfRef;

        if (base64Context.startsWith('1.')) {
            base64Context = base64Context.slice(2);
        }
        let addressableContext = JSON.parse(window.atob(base64Context));
        let containerId = addressableContext.attributes.recordId;
        let objectApiName = pageRef.attributes.objectApiName;
        let recordId = component.get('v.recordId');

        let p3 = StrategyUtils.executeAction(component, 'c.getMatrixByRelationshipMap', {
            mapId: containerId
        });

        let fieldValues = {
            pqcrush__Relationship_Map__c: containerId,
            pqcrush__Account_Plan__c: containerId
        };

        const promises = [p3];

        Promise.all(promises).then(
            $A.getCallback(function (result) {
                let matrix = result[0];
                let influenceData = matrix.influenceList;
                let supportData = matrix.supportList;

                let comp = component.find('membermodal');

                comp.open(objectApiName, recordId, influenceData, supportData, fieldValues);
            })
        );
    }
});