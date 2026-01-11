({
    afterRender: function(component) {
        this.superAfterRender();
        var card = component.find('card');
        var content = component.find('bodyContent');
        var isMobile = component.get('v.isMobile');
        var isSF1Card = window.innerHeight <= 50;

        if (isMobile && isSF1Card) {
            $A.util.addClass(card, 'no-header');
            $A.util.removeClass(card, 'slds-hide');
            $A.util.addClass(content, 'slds-hide');
        } else {
            $A.util.removeClass(card, 'no-header');
            $A.util.addClass(card, 'slds-hide');
            $A.util.removeClass(content, 'slds-hide');
        }
    }
});