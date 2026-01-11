@SuppressWarnings('PMD')
global with sharing class ScheduleEmailKeyDateReminderBatch implements Database.Batchable<sObject>, Schedulable {
    public static final String ON_THE_DAY_OF = 'On the day of';
    public static final String ONE_DAY_BEFORE = '1 day before';
    public static final String TWO_DAYS_BEFORE = '2 days before';
    public static final String ONE_WEEK_BEFORE = '1 week before';
    public static final String TWO_WEEKS_BEFORE = '2 weeks before';
    public static final String THIRTY_DAYS_BEFORE = '30 days before';
    public static final String SIXTY_DAYS_BEFORE = '60 days before';
    public static final String NINETY_DAYS_BEFORE = '90 days before';

    public static integer DAYSTOPULL = 91;

    /******************************
     *     Schedulable Methods
     ******************************/

    global void execute(SchedulableContext context) {
        Database.executeBatch(this);
    }

    /******************************
     *     Batchable Methods
     ******************************/

    global Iterable<sObject> start(Database.BatchableContext context) {
        List<sObject> records = new List<sObject>();

        Date today = Date.today();
        Date ninetydaysFromNow = today.addDays(DAYSTOPULL);

        List<Key_Date__c> keyDates = KeyDateSelector.newInstance()
            .selectWithRemindersBetweenAsSystem(today, ninetydaysFromNow);

        records.addAll((List<SObject>) keyDates);

        return records;
    }

    global void execute(Database.BatchableContext context, List<sObject> records) {
        Date today = Date.today();

        List<Key_Date__c> keyDates = new List<Key_Date__c>();

        for (sObject record : records) {
            if (record.getSObjectType() == Key_Date__c.sObjectType) {
                Key_Date__c keyDate = (Key_Date__c) record;
                if (checkSendReminder(keyDate, today)) {
                    keyDates.add(keyDate);
                }
            }
        }

        try {
            if (keyDates.size() > 0) {
                System.debug(loggingLevel.Error, '*** keyDatesFromActual2: ' + keyDates);
                SendEmailNotifications.sendReminderEmails(keyDates, 'Key_Date_Reminder');
            }
        } catch (Exception e) {
            System.debug('Error thrown sending update Emails: ' + e.getMessage());
        }
    }

    private Boolean checkSendReminder(Key_Date__c keyDate, Date today) {
        DateTime tminus1 = keyDate.Date__c.addDays(-1);
        DateTime tminus2 = keyDate.Date__c.addDays(-2);
        DateTime tminus7 = keyDate.Date__c.addDays(-7);
        DateTime tminus14 = keyDate.Date__c.addDays(-14);
        DateTime tminus30 = keyDate.Date__c.addDays(-30);
        DateTime tminus60 = keyDate.Date__c.addDays(-60);
        DateTime tminus90 = keyDate.Date__c.addDays(-90);

        if (keyDate.Reminder__c == NINETY_DAYS_BEFORE && tminus90 == today) {
            return true;
        }
        if (keyDate.Reminder__c == SIXTY_DAYS_BEFORE && tminus60 == today) {
            return true;
        }
        if (keyDate.Reminder__c == THIRTY_DAYS_BEFORE && tminus30 == today) {
            return true;
        }
        if (keyDate.Reminder__c == TWO_WEEKS_BEFORE && tminus14 == today) {
            return true;
        }
        if (keyDate.Reminder__c == ONE_WEEK_BEFORE && tminus7 == today) {
            return true;
        }
        if (keyDate.Reminder__c == TWO_DAYS_BEFORE && tminus2 == today) {
            return true;
        }
        if (keyDate.Reminder__c == ONE_DAY_BEFORE && tminus1 == today) {
            return true;
        }
        if (keyDate.Reminder__c == ON_THE_DAY_OF && keyDate.Date__c == today) {
            return true;
        }

        return false;
    }

    global void finish(Database.BatchableContext context) {
    }
}