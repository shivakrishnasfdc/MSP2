({
    doInit: function (component) {
        var accountPlanId = component.get('v.recordId');

        // On init set account plan
        component.set('v.member.pqcrush__Account_Plan__c', accountPlanId);
    },

    handleSave: function (component) {
        var member = component.get('v.member');
        var params = {
            accountPlanId: member.pqcrush__Account_Plan__c,
            userId: member.pqcrush__User__c,
            role: member.pqcrush__Role__c
        };

        StrategyUtils.executeAction(component, 'c.addTeamMember', params)
            .then(function () {
                StrategyUtils.successToast('Team Member added!');
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
            })
            .catch(function () {
                StrategyUtils.errorToast('Team Member not added!');
            });
    },

    cancel: function () {
        $A.get('e.force:closeQuickAction').fire();
    }
});