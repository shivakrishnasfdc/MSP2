({
    init: function (component, event, helper) {
        var accessMap = component.get('v.accessMap');
        var task = component.get('v.task');
        var isMobile = component.get('v.isMobile');
        var showAccountPlanName = component.get('v.showAccountPlanName');

        var allAccess = false;
        var readAccess = false;
        var editAccess = false;
        var deleteAccess = false;

        var isOverdue = helper.isTaskOverdue(task);

        component.set('v.isOverdue', isOverdue);

        if (accessMap) {
            allAccess = accessMap[task.Id].HasAllAccess;
            readAccess = accessMap[task.Id].HasReadAccess;
            editAccess = accessMap[task.Id].HasEditAccess;
            deleteAccess = accessMap[task.Id].HasDeleteAccess;
        }

        var showDropdown = !isMobile && (allAccess || editAccess || readAccess || deleteAccess);

        component.set('v.showDropdown', showDropdown);

        var canEdit = editAccess || allAccess;
        var canRead = readAccess || allAccess;
        var canDelete = deleteAccess || allAccess;

        component.set('v.canEdit', canEdit);
        component.set('v.canRead', canRead);
        component.set('v.canDelete', canDelete);
        component.set('v.showAccountPlanName', showAccountPlanName);

        var menuItems = [];

        if (canEdit) {
            menuItems.push({ label: $A.get('$Label.c.Edit'), value: 'edit' });
        }
        if (canRead) {
            menuItems.push({ label: $A.get('$Label.c.View'), value: 'view' });
        }
        if (canDelete) {
            menuItems.push({ label: $A.get('$Label.c.Delete'), value: 'delete' });
        }
        component.set('v.menuItems', menuItems);

        var checkBox = component.find('checkbox'),
            subjectComponent = component.find('subjectText');

        checkBox.set('v.disabled', !allAccess && !canEdit);

        if (task.IsClosed) {
            $A.util.addClass(subjectComponent, 'strikethrough');
        }

        // Check if subjecttext has value
        if (!subjectComponent.get('v.value')) {
            subjectComponent.set('v.value', $A.get('$Label.c.No_Subject'));
        }
        helper.setDisplayedStatus(component);
    },

    onMenuSelect: function (component, event) {
        var itemEvent = component.getEvent('taskItemAction');
        var task = component.get('v.task');
        var action = event.getParam('value');

        itemEvent
            .setParams({
                taskId: task.Id,
                action: action
            })
            .fire();
    },

    onCheck: function (component) {
        var itemEvent = component.getEvent('taskItemAction');
        var task = component.get('v.task');
        var checked = task.IsClosed;

        itemEvent
            .setParams({
                taskId: task.Id,
                action: checked ? 'unChecked' : 'checked'
            })
            .fire();
    },

    onRowSelect: function (component) {
        var isMobile = component.get('v.isMobile');
        var task = component.get('v.task');

        if (isMobile) {
            sforce.one.navigateToSObject(task.Id);
        } else {
            var itemEvent = component.getEvent('taskItemAction');

            itemEvent
                .setParams({
                    taskId: task.Id,
                    action: 'view'
                })
                .fire();
        }
    }
});