public with sharing class UserRecordAccessService {
    public static Map<Id, UserRecordAccess> recordAccessForRecords(List<SObject> objs) {
        return service().recordAccessForRecords(objs);
    }

    private static UserRecordAccessServiceImpl service() {
        return (UserRecordAccessServiceImpl) Application.Service.newInstance(UserRecordAccessServiceImpl.class);
    }
}