public with sharing class UserRecordAccessServiceImpl {
    private static final Integer BATCH_SIZE = 200;

    public Map<Id, UserRecordAccess> recordAccessForRecords(List<SObject> objs) {
        Integer numberOfList = (objs.size() / BATCH_SIZE) + 1;
        Map<Id, UserRecordAccess> recordAccessById = new Map<Id, UserRecordAccess>();

        for (Integer i = 0; i < numberOfList; i++) {
            List<SObject> smallList = new List<SObject>();
            Integer start = i * BATCH_SIZE;
            Integer finish = start + BATCH_SIZE;
            for (Integer j = start; (j < finish) && (j < objs.size()); j++) {
                smallList.add(objs.get(j));
            }

            Set<Id> objIds = new Map<Id, SObject>(smallList).keyset();
            List<UserRecordAccess> recordAccess = UserRecordAccessSelector.newInstance().selectByRecordId(objIds);

            if (recordAccess != null) {
                for (UserRecordAccess ura : recordAccess) {
                    recordAccessById.put(ura.RecordId, ura);
                }
            }
        }

        return recordAccessById;
    }
}