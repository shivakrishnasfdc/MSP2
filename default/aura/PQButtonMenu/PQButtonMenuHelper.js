({
    addHandlers: function (handlerRef, component) {
        var body = component.get('v.body');

        if ($A.util.isEmpty(body)) {
            return;
        }
        for (let index = 0; index < body.length; index++) {
            const element = body[index];

            if (element.toString().match(/lightning:buttonMenu/)) {
                // Do something
                element.set('v.onactive', handlerRef);
            } else {
                this.addHandlers(handlerRef, element);
            }
        }
    },

    getIconURL: function (iconName) {
        var parts = iconName.split(':');
        var category = parts[0];
        var name = parts[1];
        var iconURL = $A.get('$Resource.sldsIcons') + '/' + category + '/' + name + '_60.png';

        return iconURL;
    }
});