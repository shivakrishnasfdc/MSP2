({
    afterRender: function(component) {
        this.superAfterRender();
        var mobileCard = component.find('mobileCard');
        var content = component.find('bodyContent');
        var isDesktop = $A.get('$Browser.isDesktop');
        var isSF1Card = window.innerHeight <= 50;

        if (!isDesktop && isSF1Card) {
            $A.util.removeClass(mobileCard, 'slds-hide');
            $A.util.addClass(content, 'slds-hide');
        } else {
            $A.util.addClass(mobileCard, 'slds-hide');
            $A.util.removeClass(content, 'slds-hide');
        }
    }
});