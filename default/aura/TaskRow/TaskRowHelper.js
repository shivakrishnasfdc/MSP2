({
    setDisplayedStatus: function (component) {
        var task = component.get('v.task');
        var statusMap = component.get('v.statusMap');

        if (!task || !task.Status) {
            component.set('v.displayedStatus', 'unknown');
        } else if (statusMap) {
            var status = statusMap[task.Status];

            component.set('v.displayedStatus', status);
        } else {
            component.set('v.displayedStatus', task.Status);
        }
    },

    isTaskOverdue: function (task) {
        if (task === null || task.ActivityDate === null) {
            return false;
        }
        if (task.IsClosed) {
            return false;
        }
        var today = new Date();
        var monthDigit = today.getMonth() + 1;

        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        var dayDigit = today.getDate();

        if (dayDigit <= 9) {
            dayDigit = '0' + dayDigit;
        }
        var todayString = today.getFullYear() + '-' + monthDigit + '-' + dayDigit;

        return task.ActivityDate < todayString;
    }
});