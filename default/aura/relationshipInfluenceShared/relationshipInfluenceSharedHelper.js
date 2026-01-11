({
    eventService: function (component) {
        return component.find('eventService');
    },

    showModal: function (component, modalComponent, modalComponentparams) {
        var modalService = component.find('modalService');

        modalService.presentDynamicModal(modalComponent, modalComponentparams, 'pqcrush');
    },

    closeModal: function (component) {
        var modalService = component.find('modalService');

        modalService.closeModal();
    }
});