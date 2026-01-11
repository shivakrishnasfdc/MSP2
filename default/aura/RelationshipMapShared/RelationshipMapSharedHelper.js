({
    eventService: function (component) {
        return component.find('eventService');
    },

    viewSettings: function (component, name, editId, access) {
        this.showObjectDialog(component, name, editId, access, 'RM_CLOSE_EDIT_RECORD', 'RM_EDIT_SETTINGS_SAVE_SUCCESS');
    },

    viewObject: function (component, name, editId, access) {
        this.showObjectDialog(component, name, editId, access, 'RM_CLOSE_EDIT_RECORD', 'RM_EDIT_RECORD_SAVE_SUCCESS');
    },

    showObjectDialog: function (component, name, editId, access, closeKey, saveKey) {
        var isClassic = component.get('v.isClassic');
        var isMobile = !$A.get('$Browser.isDesktop');
        const canEdit = access.HasAllAccess || access.HasEditAccess;

        if (isMobile) {
            if (canEdit) {
                sforce.one.editRecord(editId);
            } else {
                sforce.one.navigateToSObject(editId, 'detail');
            }
        } else if (isClassic) {
            var editRecordEvent;

            if (canEdit) {
                editRecordEvent = $A.get('e.force:editRecord');
            } else {
                editRecordEvent = $A.get('e.force:navigateToSObject');
            }

            if (editRecordEvent) {
                editRecordEvent.setParams({ recordId: editId });
                editRecordEvent.fire();
            }
        } else {
            this.showModal(component, 'PQRecordEdit', {
                recordId: editId,
                title: name,
                editable: canEdit,
                closeEventKey: closeKey,
                saveEventKey: saveKey
            });
        }
    },

    showModal: function (component, modalComponent, modalComponentparams) {
        console.log('inside RelationshipMapsharedHelper');
        var modalService = component.find('modalService');

        modalService.presentDynamicModal(modalComponent, modalComponentparams, 'pqcrush');
    },

    closeModal: function (component) {
        var modalService = component.find('modalService');

        modalService.closeModal();
    }
});