({
    doInit: function (component) {
        var service = component.find('utilityForBrowserSupport');

        component.set('v.supportsExternalSVG', service.supportsExternalSVG());

        var fullName = component.get('v.iconName');
        var parts = fullName.split(':');
        var category = parts[0];
        var name = parts[1];
        var iconUrl = $A.get('$Resource.sldsIcons') + '/' + category + '/' + name + '_60.png';

        component.set('v.iconURL', iconUrl);
        component.set('v.iconCategory', category);
        component.set('v.icon', name);
        component.set('v.isLoaded', true);
    }
});