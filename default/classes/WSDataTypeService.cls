public with sharing class WSDataTypeService {
    public static List<WS_Data_Type__c> getDataTypes(Id whiteSpaceId) {
        return service().getDataTypes(whiteSpaceId);
    }

    public static Id saveDataForCell(Id cellId, Id dataTypeId, String value) {
        return service().saveDataForCell(cellId, dataTypeId, value);
    }

    public static List<WS_Data_Type_Association__c> getDataTypeDataForCell(Id cellId) {
        return service().getDataTypeDataForCell(cellId);
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private static WSDataTypeServiceImpl service() {
        return (WSDataTypeServiceImpl) Application.Service.newInstance(WSDataTypeServiceImpl.class);
    }
}