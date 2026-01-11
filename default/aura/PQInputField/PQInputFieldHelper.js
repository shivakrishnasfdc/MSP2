({
    autosize: function (component) {
        var textArea = component.find('wsTextArea');

        if (!textArea) {
            return;
        }
        var el = textArea.getElement();

        if (el) {
            el.style.height = 'auto';
            el.style.height = el.scrollHeight + 'px';
        }
    }
});