({
    MAX_TITLE_LENGTH: 80,
    MAX_BODY_LENGTH: 32768,

    eventService: function (component) {
        return component.find('eventService');
    },

    isValid: function (component) {
        var planOverviewTitle = component.get('v.planOverviewTitle');
        var planOverview = component.get('v.planOverview');
        var isValid = true;

        if (planOverviewTitle && planOverviewTitle.length > this.MAX_TITLE_LENGTH) {
            isValid = false;
        }
        if (planOverview && planOverview.length > this.MAX_BODY_LENGTH) {
            component.set('v.bodyValidity', false);
            isValid = false;
        } else {
            component.set('v.bodyValidity', true);
        }

        return isValid;
    }
});