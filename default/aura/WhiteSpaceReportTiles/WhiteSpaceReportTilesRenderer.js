({
    afterRender: function(component, helper) {
        this.superAfterRender();
        helper.updateGridWidth(component);
    },

    rerender: function(component, helper) {
        this.superRerender();
        helper.updateGridWidth(component);
    }
});