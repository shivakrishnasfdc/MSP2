public with sharing class WSDataTypeServiceImpl {
    public List<WS_Data_Type__c> getDataTypes(Id whiteSpaceId) {
        return WSDataTypeSelector.newInstance().selectByWhiteSpaceId(whiteSpaceId);
    }

    public Id saveDataForCell(Id cellId, Id dataTypeId, String value) {
        List<WS_Data_Type_Association__c> associations = WSDataTypeAssociationSelector.newInstance()
            .selectByCellAndDataType(cellId, dataTypeId);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        WS_Data_Type_Association__c assoc;

        if (associations != null && associations.size() > 0) {
            // Should only be 1
            assoc = associations[0];
            assoc.WS_Data_Value__c = value;
            uow.registerDirty(assoc);
        } else {
            assoc = new WS_Data_Type_Association__c(
                White_Space_Cell__c = cellId,
                WS_Data_Type__c = dataTypeId,
                WS_Data_Value__c = value
            );
            uow.registerNew(assoc);
        }
        uow.commitWork();
        return assoc.Id;
    }

    public List<WS_Data_Type_Association__c> getDataTypeDataForCell(Id cellId) {
        return WSDataTypeAssociationSelector.newInstance().selectByCellId(cellId);
    }
}