({
    doInit: function (component) {
        let service = component.find('featureService');

        service
            .initializeValues()
            .then(
                $A.getCallback(function () {
                    component.set('v.relMapEnabled', service.relationshipMapAccess());
                    component.set('v.isLicensed', service.isLicensed());
                    component.set('v.loading', false);
                })
            )
            .catch(
                $A.getCallback(function () {
                    component.set('v.loading', false);
                })
            );
    }
});