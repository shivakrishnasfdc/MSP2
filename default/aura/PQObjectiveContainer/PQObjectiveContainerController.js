({
    handleObjectEdit: function (component, event) {
        var recordId = event.getParam('recordId');
        var canEdit = event.getParam('canEdit');

        var isMobile = !$A.get('$Browser.isDesktop');

        if (isMobile) {
            if (canEdit) {
                sforce.one.editRecord(recordId);
            } else {
                sforce.one.navigateToSObject(recordId, 'detail');
            }
        } else {
            var editRecordEvent;

            if (canEdit) {
                editRecordEvent = $A.get('e.force:editRecord');
            } else {
                editRecordEvent = $A.get('e.force:navigateToSObject');
            }

            if (editRecordEvent) {
                editRecordEvent.setParams({ recordId: recordId });
                editRecordEvent.fire();
            }
        }
    }
});