@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class PicklistServiceImpl {
    // Currently the most common way to get dependentPicklistValues. No built in salesforce way yet.
    // https://glyntalkssalesforce.blogspot.com/2018/08/dependent-picklist-values-in-apex.html
    public Map<Object, List<PicklistService.PicklistWrapper>> getDependentPicklistValues(
        Schema.sObjectField dependToken
    ) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return null;
        }
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries = (control.getType() == Schema.DisplayType.Boolean
            ? null
            : control.getPicklistValues());

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object, List<PicklistService.PicklistWrapper>> dependentPicklistValues = new Map<Object, List<PicklistService.PicklistWrapper>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive()) {
                List<String> base64chars = String.valueOf(
                        ((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')
                    )
                    .split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue = (controlEntries == null
                        ? (Object) (index == 1)
                        : (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null));
                    Integer bitIndex = index / 6;
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0) {
                        continue;
                    }
                    if (!dependentPicklistValues.containsKey(controlValue)) {
                        dependentPicklistValues.put(controlValue, new List<PicklistService.PicklistWrapper>());
                    }
                    PicklistService.PicklistWrapper wrapper = new PicklistService.PicklistWrapper(
                        entry.getLabel(),
                        entry.getValue()
                    );
                    dependentPicklistValues.get(controlValue).add(wrapper);
                }
            }
        }
        return dependentPicklistValues;
    }
}