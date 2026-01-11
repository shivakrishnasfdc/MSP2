({
    init: function (component) {
        var imageResourceName = component.get('v.imageResourceName');

        if (imageResourceName) {
            var imageResourceReference = $A.get('$Resource.' + imageResourceName);

            component.set('v.imageResourceReference', imageResourceReference);
        }
    }
});