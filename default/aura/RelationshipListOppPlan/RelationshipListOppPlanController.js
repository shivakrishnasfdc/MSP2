({
    init: function (component) {
        component.set('v.isLoading', true);

        let recordId = component.get('v.recordId');

        let dispatcher = component.find('oppManDataDispatcher');

        dispatcher
            .getMapIdForPlanIdPromise(recordId)
            .then(
                $A.getCallback(function (mapId) {
                    if (mapId) {
                        component.set('v.mapId', mapId);
                    } else {
                        StrategyUtils.errorToast($A.get('$Label.c.Opp_Plan_No_RM_Found'));
                    }
                    component.set('v.isLoading', false);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast(error.message);
                    component.set('v.isLoading', false);
                })
            );
    }
});