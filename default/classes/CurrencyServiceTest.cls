@isTest
private class CurrencyServiceTest {
    // Null String test
    @isTest
    private static void convertStringTest() {
        String input = null;
        Object result = CurrencyService.convert(input, UserInfo.getDefaultCurrency());
        System.AssertEquals(input, (String) result);
    }

    // String test
    @isTest
    private static void convertStringTest2() {
        String input = '2';
        Object result = CurrencyService.convert(input, UserInfo.getDefaultCurrency());
        System.AssertEquals(2, (Decimal) result);
    }

    // Decimal null test
    @isTest
    private static void convertDecimalTest() {
        Decimal input = null;
        Object result = CurrencyService.convert(input, UserInfo.getDefaultCurrency());
        System.AssertEquals(input, (Decimal) result);
    }

    // Decimal test
    @isTest
    private static void convertDecimalTest2() {
        Decimal input = 147.0;
        Object result = CurrencyService.convert(input, UserInfo.getDefaultCurrency());
        System.AssertEquals(input, (Decimal) result);
    }

    // Integer null test
    @isTest
    private static void convertIntegerTest() {
        Integer input = null;
        Object result = CurrencyService.convert(input, UserInfo.getDefaultCurrency());
        System.AssertEquals(input, result);
    }

    // Integer test
    @isTest
    private static void convertIntegerTest2() {
        Integer input = 147;
        Object result = CurrencyService.convert(input, UserInfo.getDefaultCurrency());
        System.AssertEquals(147.0, Decimal.valueOf(String.valueOf(result)));
    }

    // Object null test
    @isTest
    private static void convertObjectTest() {
        Object input = null;
        Object result = CurrencyService.convert(input, UserInfo.getDefaultCurrency());
        System.AssertEquals(input, result);
    }

    // Object test
    @isTest
    private static void convertObjectTest2() {
        Object input = (Object) 147.0;
        Object result = CurrencyService.convert(input, UserInfo.getDefaultCurrency());
        System.AssertEquals(input, result);
    }
}