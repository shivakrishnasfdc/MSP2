public with sharing class PicklistService {
    public static Map<Object, List<PicklistService.PicklistWrapper>> getDependentPicklistValues(
        Schema.sObjectField dependToken
    ) {
        return service().getDependentPicklistValues(dependToken);
    }

    private static PicklistServiceImpl service() {
        return (PicklistServiceImpl) Application.Service.newInstance(PicklistServiceImpl.class);
    }

    public class PicklistWrapper {
        public String label;
        public String value;

        public PicklistWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}