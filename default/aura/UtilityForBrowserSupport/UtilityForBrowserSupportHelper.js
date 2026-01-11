({
    // CHECK TO SEE IF BROWSER SUPPORTS SVG
    handleSupportsExternalSVG: function () {
        var supportsExternalSVG = true;

        if (
            document.implementation.hasFeature &&
            !document.implementation.hasFeature('http://www.w3.org/TR/SVG11/feature#ExternalResourcesRequired', '1.1')
        ) {
            supportsExternalSVG = false;
        }

        return supportsExternalSVG;
    }
});