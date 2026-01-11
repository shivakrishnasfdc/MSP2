public with sharing class UtilityForMap {
    private static UtilityForMapImpl instance = null;

    public static Map<String, Decimal> mergeData(Map<String, Decimal> newData, Map<String, Decimal> oldData) {
        return service().mergeData(newData, oldData);
    }

    public static Map<String, Decimal> convertMap(Map<String, Object> input) {
        return service().convertMap(input); 
    }

    private static UtilityForMapImpl service() {
        if (instance == null) {
            instance = (UtilityForMapImpl) Application.Service.newInstance(UtilityForMapImpl.class);
        }
        return instance;
    }
}