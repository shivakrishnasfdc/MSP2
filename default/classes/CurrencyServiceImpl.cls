public with sharing class CurrencyServiceImpl {
    private Map<String, Double> currencyRateMap = new Map<String, Decimal>();
    private Double userRate = 1;

    public CurrencyServiceImpl() {
        if (UserInfo.IsMultiCurrencyOrganization()) {
            String userCurrencyCode = UserInfo.getDefaultCurrency();
            for (
                SObject ct : Database.query('SELECT Id, ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE')
            ) {
                this.currencyRateMap.put((String) ct.get('ISOCode'), (Double) ct.get('ConversionRate'));
                if (ct.get('ISOCode') == userCurrencyCode) {
                    this.userRate = (Double) ct.get('ConversionRate');
                }
            }
        }
    }

    public Object convert(Object input, String valueIsoCode) {
        try {
            return convert(String.valueOf(input), valueIsoCode);
        } catch (Exception e) {
            return input;
        }
    }

    public Object convert(String input, String valueIsoCode) {
        try {
            return convert(Decimal.valueOf(input), valueIsoCode);
        } catch (Exception e) {
            return (Object) input;
        }
    }

    public Object convert(Integer input, String valueIsoCode) {
        return convert(Decimal.valueOf(input), valueIsoCode);
    }

    public Object convert(Decimal input, String valueIsoCode) {
        if (!UserInfo.IsMultiCurrencyOrganization() || UserInfo.getDefaultCurrency() == valueIsoCode) {
            return input;
        }
        Double valueRate = this.currencyRateMap.get(valueIsoCode);
        Double conversionRate = this.userRate / valueRate;
        Decimal newValue = input * conversionRate;
        return (Object) newValue;
    }
}