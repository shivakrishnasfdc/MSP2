({
    init: function (component, event, helper) {
        helper.loadData(component);
    },

    closeModal: function (component, event, helper) {
        event.stopPropagation();
        helper.closeModal(component);
    },

    configurationSaved: function (component, event, helper) {
        event.stopPropagation();
        var params = event.getParams();

        helper.handleWhiteSpaceResult(component, params.newValue);
    },

    handleApplicationEvent: function (component, event, helper) {
        let params = event.getParams();

        switch (params.appEventKey) {
            case 'WS_EDIT_RECORD_SAVE_SUCCESS':
                helper.closeModal(component);
                helper.loadData(component);
                break;
            case 'WS_CLOSE_EDIT_RECORD':
                helper.closeModal(component);
                break;
        }
    },

    handleDelete: function (component, event, helper) {
        helper.closeModal(component);

        // Fire event
        const evt = component.getEvent('onDelete');

        evt.fire();
    },

    handleEditRecord: function (component, event, helper) {
        var recordId = event.getParam('recordId');
        var title = event.getParam('recordName');
        var access = event.getParam('access');

        helper.showModal(component, 'PQRecordEdit', {
            recordId: recordId,
            title: title,
            editable: access.HasAllAccess || access.HasEditAccess,
            closeEventKey: 'WS_CLOSE_EDIT_RECORD',
            saveEventKey: 'WS_EDIT_RECORD_SAVE_SUCCESS',
            openNewTab: 'true'
        });
    },

    handleCreateClassic: function (component, event) {
        const createRecordEvent = $A.get('e.force:createRecord');
        const relatedObjects = event.getParam('relatedObjects');
        const objectApiName = event.getParam('objectApiName');

        if (createRecordEvent) {
            const params = {
                entityApiName: objectApiName,
                defaultFieldValues: relatedObjects
            };

            createRecordEvent.setParams(params);
            createRecordEvent.fire();
        }
    },

    handleWhiteSpaceUpdated: function (component, event) {
        const updatedWS = event.getParam('whiteSpace');

        component.set('v.whiteSpace', updatedWS);
    },

    onMenuSelect: function (component, event, helper) {
        const menuAction = event.getParam('value');
        let params = {};

        if (menuAction === 'edit') {
            params = {
                whitespaceObj: component.get('v.whiteSpace'),
                whitespaceObjAccess: component.get('v.whiteSpaceObjectAccess'),
                onChangesSaved: component.getReference('c.configurationSaved'),
                closeModal: component.getReference('c.closeModal')
            };
            helper.showModal(component, 'WhitespaceReportConfiguration', params);
        } else if (menuAction === 'delete') {
            params = {
                title: $A.get('$Label.c.Delete'),
                content: $A.get('$Label.c.Delete_Cross_Sell_Confirmation'),
                primaryActionLabel: 'Delete',
                primaryActionVariant: 'destructive',
                onPrimaryActionClicked: component.getReference('c.handleDelete'),
                closeModal: component.getReference('c.closeModal')
            };
            helper.showModal(component, 'PQModal', params);
        } else if (menuAction === 'formula') {
            component.set('v.openModal', true);
        }
    },

    handleRefresh: function (component, event, helper) {
        helper.loadData(component);
    }
});