public with sharing class StaticResourceServiceImpl {
    private static Map<Set<String>, Map<String, String>> resourceURLCache = new Map<Set<String>, Map<String, String>>();

    public Map<String, String> getResourceUrlsForResourceNames(Set<String> resourceNames) {
        if (resourceURLCache.containsKey(resourceNames)) {
            return resourceURLCache.get(resourceNames);
        }
        Set<String> originalNames = new Set<String>(resourceNames);

        // MAKE THEM REPLACE THE WHOLE SET
        Set<String> overrideResourceNames = new Set<String>();
        for (String resourceName : resourceNames) {
            overrideResourceNames.add('pqcrush__' + resourceName);
        }

        List<StaticResource> resources = StaticResourcesSelector.newInstance().selectByName(overrideResourceNames);
        if (resources.size() <= 0) {
            resources = StaticResourcesSelector.newInstance().selectByName(resourceNames);
        }

        Map<String, String> resourceMap = new Map<String, String>();
        for (StaticResource resource : resources) {
            String namespace = resource.NamespacePrefix;
            // Resource URL
            String resourceUrl =
                '/resource/' +
                ((resource.SystemModStamp != null) ? String.valueOf(resource.SystemModStamp.getTime()) : '') +
                '/' +
                (namespace != null && namespace != '' ? namespace + '__' : '') +
                resource.Name;
            resourceMap.put(resource.Name, resourceUrl);
        }

        resourceURLCache.put(originalNames, resourceMap);
        return resourceMap;
    }
}