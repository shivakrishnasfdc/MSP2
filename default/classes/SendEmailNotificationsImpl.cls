public with sharing class SendEmailNotificationsImpl {
    public void sendReminderEmails(List<Key_Date__c> keyDates, String template) {
        //If Org disables notifications then dont send any
        Crush_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        if (!orgSettings.Enable_Notifications__c) {
            return;
        }

        List<EmailTemplate> templates = EmailTemplatesSelector.newInstance()
            .selectByDeveloperNames(new List<String>{ template });
        if (templates != null && templates.size() > 0) {
            Id templateId = templates[0].Id;

            Set<Id> accountPlanIds = new Set<Id>();
            for (Key_Date__c keyDate : keyDates) {
                accountPlanIds.add(keyDate.Account_Plan__c);
            }
            Map<Id, Account_Plan__c> plansMap = new Map<Id, Account_Plan__c>(
                AccountPlanSelector.newInstance().selectByIdWithSharesAsSystem(accountPlanIds)
            );

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            Map<Id, UserPackageLicense> licensedUsersMap = new SystemContext().getLicensedUsersMap();

            for (Key_Date__c keyDate : keyDates) {
                Set<String> recipients = getRecipientsForReminders(
                    plansMap.get(keyDate.Account_Plan__c),
                    licensedUsersMap.keySet()
                );

                if (recipients.size() > 0) {
                    emails = generateEmails(recipients, templateId, keyDate.Id);
                }
            }

            send(emails);
        } else {
            throw new SendEmailException('Template does not exist: ' + template);
        }
    }

    public void sendEmails(List<SendEmailNotifications.SendEmailRequest> requests) {
        //If Org disables notifications then dont send any
        Crush_Settings_Obj__c orgSettings = SettingService.getOrgSettingsAndCreateIfNeeded();
        if (!orgSettings.Enable_Notifications__c) {
            return;
        }

        Map<Id, UserPackageLicense> licensedUsersMap = new SystemContext().getLicensedUsersMap();

        Map<String, Id> templateNameToTemplateId = getTemplateMap(requests);
        Map<Id, Account_Plan__c> plansMap = getAccountPlansWithShares(requests);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (SendEmailNotifications.SendEmailRequest request : requests) {
            //If Org disabled that notification type then don't send
            SObjectField settingsField = SendEmailNotifications.SETTINGS_FIELDS_BY_EVENT_TYPE.get(request.eventType);
            Boolean sendEnabled = settingsField != null && (Boolean) orgSettings.get(settingsField);
            if (!sendEnabled) {
                continue;
            }
            Id templateId = templateNameToTemplateId.get(request.eventType);
            if (templateId == null) {
                throw new SendEmailException('Template does not exist: ' + request.eventType);
            }

            Set<String> recipients = getRecipients(request, plansMap, request.eventType, licensedUsersMap.keySet());
            Account_Plan__c myPlan = plansMap.get(request.accountPlanId);

            if (recipients.size() > 0) {
                emails.addAll(generateEmails(recipients, templateId, myPlan.Id));
            }
        }

        send(emails);
    }

    private Map<String, Id> getTemplateMap(List<SendEmailNotifications.SendEmailRequest> requests) {
        Set<String> templateNames = new Set<String>();

        for (SendEmailNotifications.SendEmailRequest request : requests) {
            templateNames.add(request.eventType);
        }

        // query for email templates and create map
        List<EmailTemplate> templates = EmailTemplatesSelector.newInstance()
            .selectByDeveloperNames(new List<String>(templateNames));

        Map<String, Id> templateNameToTemplateId = new Map<String, Id>();
        for (EmailTemplate template : templates) {
            templateNameToTemplateId.put(template.DeveloperName, template.Id);
        }

        return templateNameToTemplateId;
    }

    private Map<Id, Account_Plan__c> getAccountPlansWithTeamMembers(
        List<SendEmailNotifications.SendEmailRequest> requests
    ) {
        Set<Id> accountPlanIds = new Set<Id>();

        for (SendEmailNotifications.SendEmailRequest request : requests) {
            accountPlanIds.add(request.accountPlanId);
        }

        return new Map<Id, Account_Plan__c>(
            AccountPlanSelector.newInstance().selectByIdWithTeamMembers(accountPlanIds)
        );
    }

    private Map<Id, Account_Plan__c> getAccountPlansWithShares(List<SendEmailNotifications.SendEmailRequest> requests) {
        Set<Id> accountPlanIds = new Set<Id>();

        for (SendEmailNotifications.SendEmailRequest request : requests) {
            accountPlanIds.add(request.accountPlanId);
        }

        return new Map<Id, Account_Plan__c>(
            AccountPlanSelector.newInstance().selectByIdWithSharesAsSystem(accountPlanIds)
        );
    }

    private void send(List<Messaging.SingleEmailMessage> emails) {
        if (!Test.isRunningTest()) {
            if (emails == null || emails.size() == 0) {
                return;
            }
            Messaging.sendEmail(emails);
        }
    }

    private Set<String> getRecipientsForReminders(Account_Plan__c myPlan, Set<Id> licensedUsers) {
        Set<String> recipients = new Set<String>();

        for (Account_Plan__Share share : myPlan.Shares) {
            if (licensedUsers.contains(share.UserOrGroupId)) {
                recipients.add(share.UserOrGroupId);
            }
        }

        if (licensedUsers.contains(myPlan.OwnerId)) {
            recipients.add(myPlan.OwnerId);
        }

        return recipients;
    }

    private Set<String> getRecipients(
        SendEmailNotifications.SendEmailRequest request,
        Map<Id, Account_Plan__c> plansMap,
        String eventType,
        Set<Id> licensedUsers
    ) {
        Account_Plan__c myPlan = plansMap.get(request.accountPlanId);

        Set<String> recipients = new Set<String>();
        Id currentUserId = UserInfo.getUserId();

        for (Account_Plan__Share share : myPlan.Shares) {
            if (
                currentUserId != share.UserOrGroupId &&
                licensedUsers.contains(share.UserOrGroupId) &&
                doesUserWantNotifications(share.UserOrGroupId, eventType)
            ) {
                recipients.add(share.UserOrGroupId);
            }
        }

        if (
            currentUserId != myPlan.OwnerId &&
            licensedUsers.contains(currentUserId) &&
            doesUserWantNotifications(myPlan.OwnerId, eventType)
        ) {
            recipients.add(myPlan.OwnerId);
        }
        return recipients;
    }

    private List<Messaging.SingleEmailMessage> generateEmails(Set<String> recipients, Id templateId, Id whatId) {
        List<String> recipList = new List<String>(recipients);

        //we have to pre render the email for the merge fields to work correctly because
        Messaging.SingleEmailMessage mergedEmail = Messaging.renderStoredEmailTemplate(
            templateId,
            recipList[0],
            whatId
        );

        String emailSubject = mergedEmail.getSubject();
        String emailTextBody = mergedEmail.getPlainTextBody();
        String emailHtmlBody = mergedEmail.getHtmlBody();

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (String recip : recipients) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(templateId);
            email.setTargetObjectId(recip);
            email.setSubject(emailSubject);
            email.setPlainTextBody(emailTextBody);
            email.setHtmlBody(emailHtmlBody);
            email.setSaveAsActivity(false);
            emails.add(email);
        }

        return emails;
    }

    private Boolean doesUserWantNotifications(Id userId, String eventType) {
        CRUSH_Settings_Obj__c settings = SettingService.getUserSettings(userId);

        if (!settings.Enable_Notifications__c) {
            return false;
        }

        SObjectField settingsField = SendEmailNotifications.SETTINGS_FIELDS_BY_EVENT_TYPE.get(eventType);
        if (settingsField != null) {
            return (Boolean) settings.get(settingsField);
        }

        return false;
    }

    public with sharing class SendEmailException extends Exception {
    }

    private without sharing class SystemContext {
        private Map<Id, UserPackageLicense> getLicensedUsersMap() {
            Query query = new Query('UserPackageLicense', null)
                .selectField('UserId')
                .lookup(
                    'PackageLicenseId',
                    new Query('PackageLicense', null).selectField('Id').addConditionEq('NamespacePrefix', 'pqcrush')
                );
            List<UserPackageLicense> licensedUsers = (List<UserPackageLicense>) query.toSObjectList();
            Map<Id, UserPackageLicense> userIdMap = (Map<Id, UserPackageLicense>) Collection.mapBy(
                Id.class,
                licensedUsers,
                'UserId'
            );
            return userIdMap;
        }
    }
}