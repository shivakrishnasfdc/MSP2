@isTest
private class ColorBoundaryTest {
    @isTest
    static void instanceTest() {
        ColorBoundary cb = new ColorBoundary('#a00000', '#b00000', '#c00000', .20, .80);
        System.assertEquals('#a00000', cb.lowColor);
        System.assertEquals('#b00000', cb.midColor);
        System.assertEquals('#c00000', cb.highColor);
        System.assertEquals(.20, cb.lowMidBoundary);
        System.assertEquals(.80, cb.midHighBoundary);
    }
}