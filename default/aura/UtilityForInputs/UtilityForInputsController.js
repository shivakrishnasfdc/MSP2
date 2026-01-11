({
    // REGEX FOR OBJECT NAME
    handleGetRegexForObjectName: function () {
        return '^[~!@#$%^&*().\\-_+=\\w]+[~!@#$%^&*().\\-_+= \\w]*$';
    },

    handleGetRegexForObjectNameDescription: function () {
        return 'Names can only contain letters, numbers, spaces and these special characters ~!@#$%^&amp;*().-_+=';
    },

    // Regex for a non-blank non-whitespace value
    handleGetRegexForNonBlankString: function () {
        return '^(?!\\s*$).+';
    },

    handleGetRegexForNonBlankStringDescription: function () {
        return 'This value must not be empty.';
    }
});