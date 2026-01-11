@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class ContinueDML extends fflib_SObjectUnitOfWork.SimpleDML {
    public Boolean bypassDmlChecks = false;

    public ContinueDML() {
        this(false);
    }

    public ContinueDML(Boolean bypassDmlChecks) {
        this.bypassDmlChecks = bypassDmlChecks;
    }

    public override void dmlInsert(List<SObject> objList) {
        if (!bypassDmlChecks) {
            for (SObject obj : objList) {
                fflib_SecurityUtils.checkObjectIsInsertable(obj.getSObjectType());
            }
        }
        Database.insert(objList, false);
    }

    public override void dmlUpdate(List<SObject> objList) {
        if (!bypassDmlChecks) {
            for (SObject obj : objList) {
                fflib_SecurityUtils.checkObjectIsUpdateable(obj.getSObjectType());
            }
        }
        Database.update(objList, false);
    }

    public override void dmlDelete(List<SObject> objList) {
        if (!bypassDmlChecks) {
            for (SObject obj : objList) {
                fflib_SecurityUtils.checkObjectIsDeletable(obj.getSObjectType());
            }
        }
        Database.delete(objList, false);
    }
}