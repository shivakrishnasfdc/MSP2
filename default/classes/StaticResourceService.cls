public with sharing class StaticResourceService {
    public static Map<String, String> getResourceUrlsForResourceNames(Set<String> resourceNames) {
        return service().getResourceUrlsForResourceNames(resourceNames);
    }

    private static StaticResourceServiceImpl service() {
        return (StaticResourceServiceImpl) Application.Service.newInstance(StaticResourceServiceImpl.class);
    }
}