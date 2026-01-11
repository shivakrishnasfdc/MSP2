@isTest
private class SearchUtilsTest {
    @isTest
    static void escapeSpecialCharactersNullTest() {
        // Given
        String input = null;

        // When
        String output = SearchUtils.escapeSpecialCharacters(input);

        // Then
        System.assertEquals(null, output);
    }

    @isTest
    static void escapeSpecialCharactersEmptyTest() {
        // Given
        String input = '';

        // When
        String output = SearchUtils.escapeSpecialCharacters(input);

        // Then
        System.assertEquals('', output);
    }

    @isTest
    static void escapeSpecialCharactersTest() {
        // Given
        String input = '[]\\[+&|!(){}^"~*?:-';

        // When
        String output = SearchUtils.escapeSpecialCharacters(input);

        // Then
        System.assertEquals('\\[\\]\\\\\\[\\+\\&\\|\\!\\(\\)\\{\\}\\^\\"\\~\\*\\?\\:\\-', output);
    }
}