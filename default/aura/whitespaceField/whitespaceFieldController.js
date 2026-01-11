({
    afterLoad: function (component) {
        const displayFieldWrapper = component.get('v.displayFieldWrapper');

        if (!$A.util.isEmpty(displayFieldWrapper.color)) {
            let lightBackground = true;

            try {
                lightBackground = textContrast.textContrast.isLight(displayFieldWrapper.color);
            } catch (err) {
                lightBackground = true;
            }
            component.set('v.backgroundIsLight', lightBackground);
        }
    }
});