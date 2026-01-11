public with sharing class UtilityForMapImpl {
    // This method merges two sets of maps by adding the values of the same keys
    public Map<String, Decimal> mergeData(Map<String, Decimal> newData, Map<String, Decimal> oldData) {

        Boolean hasNewData = newData != null && newData.size() > 0;
        Boolean hasOldData = oldData != null && oldData.size() > 0;
    
        if (!hasNewData && !hasOldData) {
            return new Map<String, Decimal>();
        } else if (!hasNewData) {
            return oldData;
        } else if (!hasOldData){
            return newData;
        }

        for (String k : oldData.keySet()) {
            Decimal val = oldData.get(k);
            if (newData.containsKey(k)) {
                val += newData.get(k);
                oldData.put(k, val);
            }
        }

        for (String k : newData.keySet()) {
            if (!oldData.containsKey(k)) {
                oldData.put(k, newData.get(k));
            }
        }

        return oldData;
    }

    // This method converts a map of String Object to String Decimal
    public Map<String, Decimal> convertMap(Map<String, Object> input) {
        Map<String, Decimal> result = new Map<String, Decimal>();
        if (input == null || input.size() == 0) {
            return result;
        }

        for (String k : input.keySet()) {
            result.put(k, (Decimal)input.get(k));
        }
        return result;
    }
}