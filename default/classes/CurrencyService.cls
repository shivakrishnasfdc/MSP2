public with sharing class CurrencyService {
    private static CurrencyServiceImpl instance = null;

    public static Object convert(String input, String inputIsoCode) {
        return service().convert(input, inputIsoCode);
    }

    public static Object convert(Decimal input, String inputIsoCode) {
        return service().convert(input, inputIsoCode);
    }

    public static Object convert(Integer input, String inputIsoCode) {
        return service().convert(input, inputIsoCode);
    }

    public static Object convert(Object input, String inputIsoCode) {
        return service().convert(input, inputIsoCode);
    }

    private static CurrencyServiceImpl service() {
        if (instance == null) {
            instance = (CurrencyServiceImpl) Application.Service.newInstance(CurrencyServiceImpl.class);
        }
        return instance;
    }
}