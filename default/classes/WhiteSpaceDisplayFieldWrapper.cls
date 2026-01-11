@SuppressWarnings('PMD.ExcessivePublicCount,PMD.EmptyStatementBlock,PMD.NcssMethodCount,PMD.CyclomaticComplexity')
public with sharing class WhiteSpaceDisplayFieldWrapper implements Comparable {
    private static String ift = White_Space_Cell__c.Info__c.getDescribe().getType().name().toLowerCase();
    private static String infoAbbLabel = System.Label.Info_Abbreviation;
    private static String infoLabel = System.Label.Info;

    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String fieldType { get; set; }
    @AuraEnabled
    public String abbreviation { get; set; }
    @AuraEnabled
    public String displayName { get; set; }
    @AuraEnabled
    public String color { get; set; }
    @AuraEnabled
    public Decimal displayOrder { get; set; }
    @AuraEnabled
    public Boolean isEditable { get; set; }
    @AuraEnabled
    public Boolean isPrimary { get; set; }
    @AuraEnabled
    public Boolean isInfoField { get; set; }
    @AuraEnabled
    public List<WhiteSpaceDisplayFieldDataWrapper> data { get; set; }
    @AuraEnabled
    public WhiteSpaceTemplateCellFieldWrapper configuration { get; set; }

    public WhiteSpaceDisplayFieldWrapper() {
    }

    private WhiteSpaceDisplayFieldWrapper(
        String id,
        String type,
        String fieldType,
        String abbreviation,
        String displayName,
        String color,
        Decimal displayOrder,
        Boolean isEditable,
        Boolean isInfoField,
        Boolean isPrimary,
        List<WhiteSpaceDisplayFieldDataWrapper> data,
        WhiteSpaceTemplateCellFieldWrapper configuration
    ) {
        this.id = id;
        this.type = type;
        this.fieldType = fieldType;
        this.abbreviation = abbreviation;
        this.displayName = displayName;
        this.displayOrder = displayOrder;
        this.color = color;
        this.isEditable = isEditable;
        this.isPrimary = isPrimary;
        this.isInfoField = isInfoField;
        this.data = data;
        this.configuration = configuration;
    }

    public static WhiteSpaceDisplayFieldWrapper createFor(
        White_Space_Amount_Type__c amountType,
        List<White_Space_Amount_Type_Association__c> associations,
        Boolean isPrimary
    ) {
        String type = amountType.Display_Type__c != null
            ? amountType.Display_Type__c.toLowerCase()
            : Schema.DisplayType.CURRENCY.name().toLowerCase();
        Boolean needsConversion = UserInfo.isMultiCurrencyOrganization() && isCurrency(type);
        Boolean isEditable = true;
        Boolean isInfoField = false;
        Boolean isPrimaryValue = isPrimary != null ? isPrimary : false;

        List<WhiteSpaceDisplayFieldDataWrapper> data = new List<WhiteSpaceDisplayFieldDataWrapper>();
        if (associations != null) {
            for (White_Space_Amount_Type_Association__c association : associations) {
                if (association.White_Space_Amount_Type__c == amountType.Id) {
                    WhiteSpaceDisplayFieldDataWrapper dw = new WhiteSpaceDisplayFieldDataWrapper(
                        needsConversion
                            ? CurrencyService.convert(
                                  association.Amount__c,
                                  (String) association.get('CurrencyIsoCode')
                              )
                            : association.Amount__c,
                        amountType.Abbreviation__c,
                        association.Id
                    );
                    data.add(dw);
                }
            }
        }
        return new WhiteSpaceDisplayFieldWrapper(
            amountType.id,
            type,
            'amountType',
            amountType.Abbreviation__c,
            amountType.Name,
            amountType.Color_RGB__c,
            amountType.Order__c,
            isEditable,
            isInfoField,
            isPrimaryValue,
            data,
            null
        );
    }

    public static WhiteSpaceDisplayFieldWrapper createFor(
        White_Space_Amount_Type__c amountType,
        WhiteSpaceTemplateCellFieldWrapper configuration,
        List<SObject> records,
        Set<String> productIdSet
    ) {
        String type = amountType.Display_Type__c != null
            ? amountType.Display_Type__c.toLowerCase()
            : Schema.DisplayType.CURRENCY.name().toLowerCase();
        Boolean isEditable = true;
        Boolean isInfoField = false;
        Boolean isPrimary = false;

        List<WhiteSpaceDisplayFieldDataWrapper> data = new List<WhiteSpaceDisplayFieldDataWrapper>();
        if (configuration != null && records != null) {
            for (SObject obj : records) {
                data.addAll(
                    getDataWrappersForObjectAndField(
                        type,
                        obj,
                        configuration.mapping.valueFieldName,
                        configuration.mapping.labelFieldName,
                        true,
                        productIdSet
                    )
                );
            }
        }
        return new WhiteSpaceDisplayFieldWrapper(
            amountType.id,
            type,
            'amountType',
            amountType.Abbreviation__c,
            amountType.Name,
            amountType.Color_RGB__c,
            amountType.Order__c,
            isEditable,
            isInfoField,
            isPrimary,
            data,
            configuration
        );
    }

    public static WhiteSpaceDisplayFieldWrapper createFor(
        WhiteSpaceTemplateCellFieldWrapper configuration,
        List<SObject> records
    ) {
        Boolean isEditable = true;
        Boolean isInfoField = false;
        Boolean isPrimary = false;

        List<WhiteSpaceDisplayFieldDataWrapper> data = new List<WhiteSpaceDisplayFieldDataWrapper>();
        if (configuration != null && records != null) {
            for (SObject obj : records) {
                String s = String.valueOf(obj.get(configuration.mapping.labelFieldName));
                WhiteSpaceDisplayFieldDataWrapper dw = new WhiteSpaceDisplayFieldDataWrapper(s, s, obj.Id);
                data.add(dw);
            }
        }
        return new WhiteSpaceDisplayFieldWrapper(
            configuration.id,
            'text',
            'basicMapping',
            null,
            configuration.mapping.objectLabelPlural,
            null,
            null,
            isEditable,
            isInfoField,
            isPrimary,
            data,
            configuration
        );
    }

    public static WhiteSpaceDisplayFieldWrapper createFor(
        WSRelatedObjectWrapper relationshipWrapper,
        WhiteSpaceTemplateCellFieldWrapper configuration,
        List<SObject> records
    ) {
        Boolean isEditable = true;
        Boolean isInfoField = false;
        Boolean isPrimary = false;

        String type = configuration.mapping?.valueFieldInfo?.displayType;

        List<WhiteSpaceDisplayFieldDataWrapper> data = new List<WhiteSpaceDisplayFieldDataWrapper>();
        if (configuration != null && records != null) {
            for (SObject obj : records) {
                data.addAll(
                    getDataWrappersForObjectAndField(
                        type,
                        obj,
                        configuration.mapping.labelFieldName,
                        configuration.mapping.valueFieldInfo.label,
                        false,
                        null
                    )
                );
            }
        }
        return new WhiteSpaceDisplayFieldWrapper(
            configuration.id,
            type,
            'relatedMapping',
            null,
            configuration.mapping.objectLabelPlural,
            relationshipWrapper.color,
            null,
            isEditable,
            isInfoField,
            isPrimary,
            data,
            configuration
        );
    }

    public static WhiteSpaceDisplayFieldWrapper infoFieldWrapper(White_Space_Cell__c cell) {
        String type = ift;
        String abbreviation = infoAbbLabel;
        String displayName = infoLabel;
        String color = null;
        Decimal displayOrder = -1;
        Boolean isEditable = true;
        Boolean isInfoField = true;
        Boolean isPrimary = false;

        List<WhiteSpaceDisplayFieldDataWrapper> data = new List<WhiteSpaceDisplayFieldDataWrapper>();
        String text = cell.Info__c != null ? cell.Info__c : '';
        WhiteSpaceDisplayFieldDataWrapper infoWrapper = new WhiteSpaceDisplayFieldDataWrapper(text, infoLabel, cell.Id);
        data.add(infoWrapper);

        return new WhiteSpaceDisplayFieldWrapper(
            null,
            type,
            'info',
            abbreviation,
            displayName,
            color,
            displayOrder,
            isEditable,
            isInfoField,
            isPrimary,
            data,
            null
        );
    }

    public Integer compareTo(Object obj) {
        WhiteSpaceDisplayFieldWrapper association = (WhiteSpaceDisplayFieldWrapper) (obj);

        if (this.displayOrder > association.displayOrder) {
            return 1;
        }

        if (this.displayOrder == association.displayOrder) {
            if (this.fieldType != association.fieldType) {
                return this.fieldType.compareTo(association.fieldType);
            }
            return this.displayName.compareTo(association.displayName);
        }

        return -1;
    }

    private static List<WhiteSpaceDisplayFieldDataWrapper> getDataWrappersForObjectAndField(
        String type,
        SObject obj,
        String valueField,
        String labelField,
        Boolean labelFromObject,
        Set<String> productIdSet
    ) {
        if (obj == null) {
            return new List<WhiteSpaceDisplayFieldDataWrapper>();
        }
        Boolean needsConversion = UserInfo.isMultiCurrencyOrganization() && isCurrency(type);
        if (!valueField.contains('.')) {
            return new List<WhiteSpaceDisplayFieldDataWrapper>{
                new WhiteSpaceDisplayFieldDataWrapper(
                    needsConversion
                        ? CurrencyService.convert(obj.get(valueField), (String) obj.get('CurrencyIsoCode'))
                        : obj.get(valueField),
                    labelFromObject ? String.valueOf(obj.get(labelField)) : labelField,
                    obj.Id
                )
            };
        }
        SObject temp = obj;
        List<String> parts = valueField.split('\\.');
        String fieldName = (String) UtilityForList.last(parts);
        Boolean isCompoundLabel = false;
        if (labelField.contains('.')) {
            labelField = labelField.substringAfterLast('.');
            isCompoundLabel = true;
        }
        String rel = parts[0];
        if (rel == 'OpportunityLineItem') {
            rel = 'OpportunityLineItems';
            List<WhiteSpaceDisplayFieldDataWrapper> data = new List<WhiteSpaceDisplayFieldDataWrapper>();
            for (SObject oli : temp.getSObjects(rel)) {
                if (productIdSet.contains((String) oli.get('Product2Id'))) {
                    WhiteSpaceDisplayFieldDataWrapper dw = new WhiteSpaceDisplayFieldDataWrapper(
                        needsConversion
                            ? CurrencyService.convert(oli.get(fieldName), (String) obj.get('CurrencyIsoCode'))
                            : oli.get(fieldName),
                        labelFromObject
                            ? (isCompoundLabel
                                  ? String.valueOf(oli.get(labelField))
                                  : String.valueOf(obj.get(labelField)))
                            : labelField,
                        oli.Id,
                        obj.Id
                    );
                    data.add(dw);
                }
            }
            return data;
        } else {
            temp = temp.getSObject(rel);
        }
        WhiteSpaceDisplayFieldDataWrapper dw = new WhiteSpaceDisplayFieldDataWrapper(
            needsConversion
                ? CurrencyService.convert(temp.get(fieldName), (String) obj.get('CurrencyIsoCode'))
                : temp.get(fieldName),
            labelFromObject ? String.valueOf(obj.get(labelField)) : labelField,
            temp.Id
        );
        return new List<WhiteSpaceDisplayFieldDataWrapper>{ dw };
    }

    private static Boolean isCurrency(String type) {
        return type.toLowerCase() == 'currency';
    }
}