public with sharing class UserRecordAccessServiceController {
    @AuraEnabled(cacheable=true)
    public static UserRecordAccess getUserRecordAccess(Id recordId) {
        if (recordId == null) {
            return null;
        }
        List<UserRecordAccess> accessRecords = UserRecordAccessSelector.newInstance()
            .selectByRecordId(new Set<Id>{ recordId });
            System.debug('===accessRecords=='+accessRecords);
         if (accessRecords != null && !accessRecords.isEmpty()) {
            return accessRecords[0];
        } else {
            return null; 
        }
    }
}