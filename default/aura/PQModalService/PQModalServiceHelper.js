({
    showDynamicModal: function (component, name, params, cssClass) {
        var modalBody;
        var self = this;

        $A.createComponent(name, params, function (content, status) {
            if (status === 'SUCCESS') {
                modalBody = content;
                self.showStaticModal(component, modalBody, cssClass);
            }
        });
    },
    showStaticModal: function (component, modalBody, cssClass) {
        var isClassic = component.get('v.isClassic');

        isClassic
            ? this.showModalClassic(component, modalBody, cssClass)
            : this.showModalLEX(component, modalBody, cssClass);
    },
    showModalLEX: function (component, modalBody, cssClass) {
        cssClass = $A.util.isEmpty(cssClass) ? '' : cssClass + ' ';
        cssClass += 'pq-lex-zero-padding ' + component.getName();

        var overlayLib = component.find('overlayLib');
        var modalPromise = overlayLib.showCustomModal({
            body: modalBody,
            showCloseButton: false,
            cssClass: cssClass
        });

        component.set('v.modalPromise', modalPromise);
    },
    showModalClassic: function (component, modalBody, cssClass) {
        var modalContent = component.find('modalContent');
        var modalContentBody = modalContent.get('v.body');

        $A.util.addClass(modalContent, 'pro-classic-modal-container');

        modalContentBody.push(modalBody);
        $A.util.addClass(modalContent, cssClass);
        modalContent.set('v.body', modalContentBody);

        var modal = component.find('modal');

        $A.util.addClass(modal, 'slds-fade-in-open');

        var backdrop = component.find('backdrop');

        $A.util.addClass(backdrop, 'slds-backdrop_open');
    },
    closeModal: function (component) {
        var isClassic = component.get('v.isClassic');

        isClassic ? this.closeModalClassic(component) : this.closeModalLEX(component);
    },
    closeModalLEX: function (component) {
        var modalPromise = component.get('v.modalPromise');

        if (modalPromise) {
            modalPromise.then(function (overlay) {
                overlay.close(0);
            });
        }
    },
    closeModalClassic: function (component) {
        var modal = component.find('modal');

        $A.util.removeClass(modal, 'slds-fade-in-open');

        var backdrop = component.find('backdrop');

        $A.util.removeClass(backdrop, 'slds-backdrop_open');

        var modalContent = component.find('modalContent');

        modalContent.set('v.body', []);
        $A.util.removeClass(modalContent, 'pro-classic-modal-container');
    }
});