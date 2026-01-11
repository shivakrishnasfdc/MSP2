({
    handleClose: function () {
        const appEvent = $A.get('e.force:navigateToObjectHome');

        appEvent.setParams({
            scope: 'pqcrush__White_Space_Template__c'
        });
        appEvent.fire();
    }
});