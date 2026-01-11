({
    handleShowEditModal: function (component, event, helper) {
        var isClassic = component.get('v.isClassic');
        var isMobile = !$A.get('$Browser.isDesktop');
        const recordId = event.getParam('recordId');
        const canEdit = event.getParam('canEdit');

        if (isMobile) {
            if (canEdit) {
                sforce.one.editRecord(recordId);
            } else {
                sforce.one.navigateToSObject(recordId, 'detail');
            }
        } else if (isClassic) {
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
        } else {
            const title = event.getParam('title');

            helper.showModal(component, 'PQRecordEdit', {
                recordId: recordId,
                title: title,
                editable: canEdit,
                closeEventKey: 'MATRIX_MODAL_CLOSED',
                saveEventKey: 'MATRIX_MODAL_SAVED'
            });
        }
    },

    handleError: function (component, event) {
        var title = event.getParam('title');
        var message = event.getParam('message');

        StrategyUtils.errorToast(title + ': ' + message);
    },

    handleApplicationEvent: function (component, event, helper) {
        let params = event.getParams();

        switch (params.appEventKey) {
            case 'MATRIX_MODAL_SAVED':
            case 'MATRIX_MODAL_CLOSED':
                helper.closeModal(component);
                break;
            default:
                break;
        }
        component.find('influenceChart').handleApplicationEvent(params.appEventKey, params.appEventValue);
    },

    fireApplicationEvent: function (component, event, helper) {
        var eventName = event.getParam('name');
        var eventValue = event.getParam('value');
        var shouldRefresh = event.getParam('refreshViews');
        let eventService = helper.eventService(component);

        eventService.fireAppEvent(eventName, eventValue);
        if (shouldRefresh) {
            $A.get('e.force:refreshView').fire();
        }
    },

    fullScreenHandler: function (component) {
        const isExpanding = !component.get('v.isExpanded');

        if (isExpanding) {
            document.body.style.overflow = 'hidden';
        } else {
            document.body.style.overflow = '';
        }
        component.set('v.isExpanded', isExpanding);
    }
});