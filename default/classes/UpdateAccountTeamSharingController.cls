public with sharing class UpdateAccountTeamSharingController {
    @AuraEnabled
    public static void updateAccountPlanSharing(List<Id> accountPlanIds) {
        AccountPlanShareService.updateAllAccountTeamShares(accountPlanIds);
    }
}