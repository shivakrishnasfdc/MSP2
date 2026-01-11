@SuppressWarnings('PMD.EmptyCatchBlock')
public inherited sharing virtual class PQSObjectDomainExt extends fflib_SObjectDomain {
    public PQSObjectDomainExt(List<SObject> sObjectList) {
        super(sObjectList);
    }

    public PQSObjectDomainExt(List<SObject> sObjectList, SObjectType sObjectType) {
        super(sObjectList, sObjectType);
    }

    public void updateField(Schema.SObjectField fieldName, Object value, fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            fflib_SecurityUtils.checkUpdate(getSObjectType(), new List<SObjectField>{ fieldName });

            for (sObject record : (List<sObject>) Records) {
                record.put(fieldName, value);

                // Calling class commits work
                unitOfWork.registerDirty(record);
            }
        } catch (Exception e) {
            // DO NOTHING
        }
    }

    public void deleteObjects(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            fflib_SecurityUtils.checkObjectIsDeletable(getSObjectType());

            // Calling class commits work
            unitOfWork.registerDeleted((List<sObject>) Records);
        } catch (Exception e) {
            // DO NOTHING
        }
    }
}