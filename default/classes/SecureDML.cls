@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class SecureDML extends fflib_SObjectUnitOfWork.SimpleDML {
    public override void dmlInsert(List<SObject> objList) {
        for (SObject obj : objList) {
            fflib_SecurityUtils.checkObjectIsInsertable(obj.getSObjectType());
        }
        insert objList;
    }

    public override void dmlUpdate(List<SObject> objList) {
        for (SObject obj : objList) {
            fflib_SecurityUtils.checkObjectIsUpdateable(obj.getSObjectType());
        }
        update objList;
    }

    public override void dmlDelete(List<SObject> objList) {
        for (SObject obj : objList) {
            fflib_SecurityUtils.checkObjectIsDeletable(obj.getSObjectType());
        }
        delete objList;
    }
}