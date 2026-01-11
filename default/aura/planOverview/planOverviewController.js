({
    init: function (component) {
        const recordId = component.get('v.recordId');
        const params = {
            accountPlanId: recordId
        };

        const browserService = component.find('utilityForBrowserSupport');

        component.set('v.isBrowserIE', browserService.isBrowserIE());

        const userRecordAccessService = component.find('userRecordAccessService');

        var promises = [
            StrategyUtils.executeAction(component, 'c.getAccountPlanById', params),
            StrategyUtils.executeAction(component, 'c.checkPlanOverviewUpdateAccessibility', {}),
            userRecordAccessService.getUserRecordAccess(recordId)
        ];

        component.set('v.isLoading', true);
        Promise.all(promises)
            .then(
                $A.getCallback(function (result) {
                    const accountPlan = result[0];
                    const fieldAccessibility = result[1];
                    const canEditAccountPlan = result[2] && (result[2].HasAllAccess || result[2].HasEditAccess);

                    component.set('v.accountPlan', accountPlan);
                    component.set('v.planOverviewTitle', accountPlan.pqcrush__Plan_Overview_Title__c);
                    component.set('v.planOverview', accountPlan.pqcrush__Plan_Overview__c);

                    component.set('v.canEdit', fieldAccessibility && canEditAccountPlan);
                    component.set('v.isLoading', false);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast('An error occurred while loading data: ' + error.message);
                    component.set('v.isLoading', false);
                })
            );
    },

    upsertPlanOverview: function (component, event, helper) {
        if (!helper.isValid(component)) {
            return;
        }
        var params = {
            accountPlanId: component.get('v.recordId'),
            planOverviewTitle: component.get('v.planOverviewTitle'),
            planOverview: component.get('v.planOverview')
        };

        component.set('v.isSaving', true);
        StrategyUtils.executeAction(component, 'c.upsertAccountPlan', params)
            .then(
                $A.getCallback(function (result) {
                    component.set('v.accountPlan', result);
                    StrategyUtils.hideModal(component, 'planOverviewModal');
                    helper.eventService(component).fireAppEvent('REFRESH_HISTORY');
                })
            )
            .catch(
                $A.getCallback(function () {
                    StrategyUtils.errorToast('An error occurred while saving your changes.');
                })
            )
            .then(
                $A.getCallback(function () {
                    component.set('v.isSaving', false);
                })
            );
    },

    checkBodyValid: function (component, event, helper) {
        helper.isValid(component);
    },

    showModal: function (component) {
        StrategyUtils.showModal(component, 'planOverviewModal');
    },

    hideModal: function (component) {
        var accountPlan = component.get('v.accountPlan');

        component.set('v.planOverviewTitle', accountPlan.pqcrush__Plan_Overview_Title__c);
        component.set('v.planOverview', accountPlan.pqcrush__Plan_Overview__c);
        StrategyUtils.hideModal(component, 'planOverviewModal');
    }
});