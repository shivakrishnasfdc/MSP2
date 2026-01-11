({
    doInit: function (component, event, helper) {
        var service = component.find('utilityForBrowserSupport');
        const supportsExternalSVG = service.supportsExternalSVG();

        if (!supportsExternalSVG) {
            component.set('v.downIconURL', helper.getIconURL('utility:down'));
            const iconName = component.get('v.iconName');

            if (iconName !== 'utility:down') {
                component.set('v.iconURL', helper.getIconURL(iconName));
            }
            const itemList = component.get('v.itemList');

            itemList.forEach(function (item) {
                if (item.iconName) {
                    item.iconURL = helper.getIconURL(item.iconName);
                }
            });
            component.set('v.itemList', itemList);
        }
        component.set('v.supportsExternalSVG', supportsExternalSVG);
        helper.addHandlers(component.getReference('c.menuItemClicked'), component);
        component.set('v.isLoaded', true);
    },

    hideOnBlur: function (component) {
        window.setTimeout(
            $A.getCallback(function () {
                $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
            }),
            250
        );
    },

    menuClick: function (component) {
        $A.util.toggleClass(component.find('dropdown'), 'slds-is-open');
    },

    onselectInternal: function (component, event) {
        var value = event.getParam('value');
        var label = event.getParam('label');
        var selectEvt = component.getEvent('onselect');

        selectEvt.setParams({
            value: value,
            label: label
        });
        selectEvt.fire();
    },

    menuItemClicked: function (component, event) {
        var target = event.target;
        var index = target.tabIndex;
        var itemList = component.get('v.itemList');
        var itemMap = itemList[index];
        var value = itemMap.value;
        var label = itemMap.label;
        var selectEvt = component.getEvent('onselect');

        selectEvt.setParams({
            value: value,
            label: label
        });
        selectEvt.fire();
        $A.util.toggleClass(component.find('dropdown'), 'slds-is-open');
    }
});