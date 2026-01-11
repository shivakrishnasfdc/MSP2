({
    handlePresentDynamicModal: function (component, event, helper) {
        var params = event.getParam('arguments');

        if (params) {
            var modalParams = params.componentParams;
            var namespace = params.namespace ? params.namespace : 'c';
            var componentName = params.componentName;

            if (!componentName.includes(':')) {
                componentName = namespace + ':' + componentName;
            }
            var cssClass = params.cssClass;

            helper.showDynamicModal(component, componentName, modalParams, cssClass);
        }
    },
    handlePresentStaticModal: function (component, event, helper) {
        var params = event.getParam('arguments');

        if (params) {
            var body = params.body;
            var cssClass = params.cssClass;

            helper.showStaticModal(component, body, cssClass);
        }
    },
    handleCloseModal: function (component, event, helper) {
        helper.closeModal(component);
    }
});