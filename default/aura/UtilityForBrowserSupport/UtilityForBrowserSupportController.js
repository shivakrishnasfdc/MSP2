({
    // CHECK TO SEE IF BROWSER IS IE
    handleIsBrowserIE: function () {
        var ua = window.navigator.userAgent; // Check the userAgent property of the window.navigator object
        var msie = ua.indexOf('MSIE '); // IE 10 or older
        var trident = ua.indexOf('Trident/'); // IE 11

        return msie > 0 || trident > 0;
    },

    // CHECK TO SEE IF BROWSER IS IE
    handleSupportsExternalSVG: function (component, event, helper) {
        return helper.handleSupportsExternalSVG();
    }
});