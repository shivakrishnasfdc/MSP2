public with sharing class AccountController {
    @AuraEnabled
    public static Account getAccountByAccountPlanId(Id accountPlanId) {
        List<Account_Plan__c> accountPlans = new AccountPlanSelector()
            .selectByIdWithAccountAndOwner(new Set<Id>{ accountPlanId });

        if (accountPlans.isEmpty()) {
            return null;
        }

        return accountPlans.get(0).Account__r;
    }

    @AuraEnabled
    public static String getAccountDescribeFields(String[] fieldsToCheck) {
        Map<String, Schema.SObjectField> fieldDescribeTokens = Schema.SObjectType.Account.fields.getMap();

        List<DescribeObject> objects = new List<DescribeObject>();

        for (String field : fieldsToCheck) {
            DescribeObject obj = new DescribeObject();
            obj.name = field;
            Schema.DescribeFieldResult describe = fieldDescribeTokens.get(field).getDescribe();
            obj.isAccessible = describe.isAccessible();
            obj.isUpdateable = describe.isUpdateable();
            objects.add(obj);
        }

        for (DescribeObject obj : objects) {
            if (obj.name == 'Industry') {
                obj.isAccessible = AccountPlanController.checkReadAccessibility('Account_Industry__c');
            } else if (obj.name == 'Ownership') {
                obj.isAccessible = AccountPlanController.checkReadAccessibility('Account_Ownership__c');
            } else if (obj.name == 'Type') {
                obj.isAccessible = AccountPlanController.checkReadAccessibility('Account_Type__c');
            } else if (obj.name == 'AnnualRevenue') {
                obj.isAccessible = AccountPlanController.checkReadAccessibility('Account_AnnualRevenue__c');
            } else if (obj.name == 'Name') {
                obj.isAccessible = AccountPlanController.checkReadAccessibility('Account__c');
            }
        }

        return JSON.serialize(objects);
    }

    @AuraEnabled
    public static Account getAccountById(Id accountId) {
        List<Account> accounts = new AccountSelector().selectById(new Set<Id>{ accountId });

        if (accounts.isEmpty()) {
            return null;
        }

        return accounts.get(0);
    }

    @AuraEnabled
    public static Account upsertAccount(Account account) {
        fflib_SObjectUnitOfWork unitOfWork = new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Schema.Account.SObjectType }
        );

        Accounts accounts = new Accounts(new List<Account>{ account });

        /*accounts.updateField(Schema.Account.Name, account.Name, unitOfWork);
        accounts.updateField(Schema.Account.Type, account.Type, unitOfWork);
        accounts.updateField(Schema.Account.Ownership, account.Ownership, unitOfWork);
        accounts.updateField(Schema.Account.Industry, account.Industry, unitOfWork);
        accounts.updateField(Schema.Account.AnnualRevenue, account.AnnualRevenue, unitOfWork);*/

        unitOfWork.commitWork();
        return getAccountById(account.Id);
    }
}