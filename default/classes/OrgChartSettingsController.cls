public with sharing class OrgChartSettingsController {
    private static Map<String, Schema.SObjectType> ocfd = null;
    @AuraEnabled
       public static List<ObjectDescriptionWrapper> getKSObjectFields(String maptype) {
        //Added By Navya START
        if(maptype =='accountrelation'){ 
        String[] objectTypes = new List<String>{
            Account.sObjectType.getDescribe().getName()
        };
        return OrgChartSettingsController.getObjectFields(objectTypes, 'Account Map');
        //Added By Navya END
    }else{
        String[] objectTypes = new List<String>{
            Contact.sObjectType.getDescribe().getName(),
            Relationship_Map_Member__c.sObjectType.getDescribe().getName()
        };
        return OrgChartSettingsController.getObjectFields(objectTypes, 'Key Stakeholder');
       
       }
    }

    @AuraEnabled
    public static List<ObjectDescriptionWrapper> getRMObjectFields() {
        String[] objectTypes = new List<String>{
            Contact.sObjectType.getDescribe().getName(),
            Relationship_Map_Member__c.sObjectType.getDescribe().getName()
        };
        return OrgChartSettingsController.getObjectFields(objectTypes, 'Relationship Map');
    }

    public static List<ObjectDescriptionWrapper> getObjectFields(List<String> objectTypes, String mapType) {
        Schema.DescribeSObjectResult[] objectDescriptions = Schema.describeSObjects(objectTypes);

        List<ObjectDescriptionWrapper> objectFields = new List<ObjectDescriptionWrapper>();

        for (Schema.DescribeSObjectResult obj : objectDescriptions) {
            String objectName = obj.getName();
            String objectLabel = obj.getLabel();

            List<Org_Chart_Field__c> orgChartFields = OrgChartFieldSelector.newInstance()
                .selectByObjectNameAndMapType(objectName, mapType);
            Map<String, Org_Chart_Field__c> orgChartFieldsMap = mapOrgChartFields(orgChartFields);

            List<FieldWrapper> fields = new List<FieldWrapper>();
            List<Schema.SObjectField> fieldValues = obj.fields.getMap().values();

            for (Schema.SObjectField fieldValue : fieldValues) {
                try {
                    Schema.DescribeFieldResult dfr = fieldValue.getDescribe();
                    // if the field is viewable and the type is not a reference to another object then add it to the list

                    if (isExcludedField(dfr)) {
                        continue;
                    }

                    if (dfr.isAccessible() && dfr.getType().name() != 'REFERENCE') {
                        fields.add(
                            buildFieldWrapper(dfr.getName(), dfr.getLabel(), dfr.isNameField(), null, orgChartFieldsMap)
                        );
                    } else if (objectName == 'Contact' && dfr.isAccessible() && dfr.getType().name() == 'REFERENCE') {
                        List<FieldWrapper> fieldsToAdd = processReferenceField(dfr, orgChartFieldsMap);
                        if (fieldsToAdd != null) {
                            fields.addAll(fieldsToAdd);
                        }
                    }
                } catch (Exception e) {
                    continue;
                }
            }
            fields.sort();
            ObjectDescriptionWrapper settingsObject = new ObjectDescriptionWrapper(objectName, objectLabel, fields);
            objectFields.add(settingsObject);
        }

        return objectFields;
    }

    private static Boolean isExcludedField(Schema.DescribeFieldResult dfr) {
        if (
            dfr?.getName().toLowerCase() == 'influence__c' ||
            dfr?.getName().toLowerCase() == 'pqcrush__influence__c' ||
            dfr?.getName().toLowerCase() == 'support__c' ||
            dfr?.getName().toLowerCase() == 'pqcrush__support__c'
        ) {
            return true;
        }
        return false;
    }

    private static FieldWrapper buildFieldWrapper(
        String fieldName,
        String fieldLabel,
        Boolean isNameField,
        String relatedFieldName,
        Map<String, Org_Chart_Field__c> orgChartFieldsMap
    ) {
        Boolean isOrgChartField = false;
        Boolean isRequired = false;

        if (orgChartFieldsMap.containsKey(fieldName)) {
            Org_Chart_Field__c orgChartField = orgChartFieldsMap.get(fieldName);
            isOrgChartField = true;
            isRequired = orgChartField.isRequired__c;
        }

        return new FieldWrapper(fieldLabel, fieldName, isOrgChartField, isRequired, isNameField, relatedFieldName);
    }

    private static List<FieldWrapper> processReferenceField(
        Schema.DescribeFieldResult descFieldResult,
        Map<String, Org_Chart_Field__c> orgChartFieldsMap
    ) {
        if (descFieldResult.isNamePointing()) {
            return null;
        }

        String refObjectName = null;

        for (Schema.SObjectType reference : descFieldResult.getReferenceTo()) {
            refObjectName = reference.getDescribe().getName();
        }

        // We are only showing the related Account (remove the comparing to account to show all)
        if (refObjectName == null || !refObjectName.equalsIgnoreCase('account')) {
            return null;
        }

        Schema.DescribeSObjectResult[] manyobjectDescription = Schema.describeSObjects(
            new List<String>{ refObjectName }
        );

        if (manyobjectDescription.size() <= 0) {
            return null;
        }

        Schema.DescribeSObjectResult objectDescription = manyobjectDescription[0];
        List<Schema.SObjectField> relatedFieldValues = objectDescription.fields.getMap().values();
        List<FieldWrapper> fieldsToReturn = new List<FieldWrapper>();
        for (Schema.SObjectField relatedFieldValue : relatedFieldValues) {
            try {
                Schema.DescribeFieldResult dfr = relatedFieldValue.getDescribe();
                // if the field is viewable and the type is not a reference to another object then add it to the list

                if (dfr.isAccessible() && (dfr.getType().name() == 'ID' || dfr.isNameField())) {
                    fieldsToReturn.add(
                        buildFieldWrapper(
                            descFieldResult.getRelationshipName() +
                            '.' +
                            dfr.getName(),
                            String.format(
                                System.Label.Relationship_Map_Settings_Related_Field_label,
                                new List<String>{ refObjectName, descFieldResult.getName(), dfr.getLabel() }
                            ),
                            dfr.isNameField(),
                            descFieldResult.getName(),
                            orgChartFieldsMap
                        )
                    );
                }
            } catch (Exception e) {
                continue;
            }
        }

        return fieldsToReturn;
    }

    @AuraEnabled
    public static List<OrgChartFieldWrapper> getOrgChartFields(String mapType) {
        List<Org_Chart_Field__c> orgChartFieldsPreFilter = OrgChartFieldSelector.newInstance().selectByMapType(mapType);

        if (orgChartFieldsPreFilter.isEmpty()) {
            orgChartFieldsPreFilter = createOrgChartDefaults(mapType);
        }

        List<Org_Chart_Field__c> orgChartFields = removeDeprecatedFeilds(orgChartFieldsPreFilter);

        List<OrgChartFieldWrapper> result = new List<OrgChartFieldWrapper>();
        Map<String, Set<String>> objectTypeFields = new Map<String, Set<String>>();
        Map<String, SObjectType> gd = getOrgChartFieldDescribe();
        Set<String> uniques = new Set<String>();
        for (Org_Chart_Field__c ocf : orgChartFields) {
            Set<String> fieldSet = objectTypeFields.get(ocf.ObjectName__c);
            if (fieldSet == null) {
                SObjectType objType = gd.get(ocf.ObjectName__c);
                fieldSet = objType.getDescribe().fields.getMap().keySet();
                objectTypeFields.put(ocf.ObjectName__c, fieldSet);
            }

            if (
                fieldSet != null &&
                ((ocf.FieldName__c != null && fieldSet.contains(ocf.FieldName__c.toLowerCase())) ||
                (ocf.Related_FieldName__c != null && fieldSet.contains(ocf.Related_FieldName__c.toLowerCase())))
            ) {
                OrgChartFieldWrapper newField = new OrgChartFieldWrapper(ocf);
                String key = newField.objectName + '_' + newField.fieldName;
                if (!uniques.contains(key)) {
                    result.add(new OrgChartFieldWrapper(ocf));
                }
                uniques.add(key);
            }
        }
        return result;
    }
    //Added By Navya 
    @AuraEnabled
    public static List<OrgChartFieldWrapper> getOrgChartFieldsAccount(String mapType) {
        List<Org_Chart_Field__c> orgChartFieldsPreFilter = OrgChartFieldSelector.newInstance().selectByObjectNameAndMapType('Account',mapType);

        if (orgChartFieldsPreFilter.isEmpty()) {
            orgChartFieldsPreFilter = createOrgChartDefaults(mapType);
        }

        List<Org_Chart_Field__c> orgChartFields = removeDeprecatedFeilds(orgChartFieldsPreFilter);

        List<OrgChartFieldWrapper> result = new List<OrgChartFieldWrapper>();
        Map<String, Set<String>> objectTypeFields = new Map<String, Set<String>>();
        Map<String, SObjectType> gd = getOrgChartFieldDescribe();
        Set<String> uniques = new Set<String>();
        for (Org_Chart_Field__c ocf : orgChartFields) {
            Set<String> fieldSet = objectTypeFields.get(ocf.ObjectName__c);
            if (fieldSet == null) {
                SObjectType objType = gd.get(ocf.ObjectName__c);
                fieldSet = objType.getDescribe().fields.getMap().keySet();
                objectTypeFields.put(ocf.ObjectName__c, fieldSet);
            }

            if (
                fieldSet != null &&
                ((ocf.FieldName__c != null && fieldSet.contains(ocf.FieldName__c.toLowerCase())) ||
                (ocf.Related_FieldName__c != null && fieldSet.contains(ocf.Related_FieldName__c.toLowerCase())))
            ) {
                OrgChartFieldWrapper newField = new OrgChartFieldWrapper(ocf);
                String key = newField.objectName + '_' + newField.fieldName;
                if (!uniques.contains(key)) {
                    result.add(new OrgChartFieldWrapper(ocf));
                }
                uniques.add(key);
            }
        }
        System.debug('=== getOrgChartFieldsAccount OrgChartFieldWrapper list result==='+result);
        return result;
    }

    private static List<Org_Chart_Field__c> removeDeprecatedFeilds(List<Org_Chart_Field__c> orgChartFieldsPreFilter) {
        List<Org_Chart_Field__c> orgChartFields = new List<Org_Chart_Field__c>();

        Schema.SObjectType objType = Relationship_Map_Member__c.getSObjectType();
        Map<String, SObjectField> fieldsByName = objType.getDescribe().fields.getMap();

        Schema.SObjectType objTypeKS = Key_Stakeholder__c.getSObjectType();
        Map<String, SObjectField> ksFieldsByName = objTypeKS.getDescribe().fields.getMap();

        for (Org_Chart_Field__c oc : orgChartFieldsPreFilter) {
            if (
                oc.FieldName__c.toLowerCase() == 'influence__c' ||
                oc.FieldName__c.toLowerCase() == 'support__c' ||
                oc.FieldName__c.toLowerCase() == 'pqcrush__influence__c' ||
                oc.FieldName__c.toLowerCase() == 'pqcrush__support__c'
            ) {
                continue;
            }

            if (
                oc.ObjectName__c.toLowerCase() != 'contact' &&
                ksFieldsByName.containsKey(oc.FieldName__c) &&
                !fieldsByName.containsKey(oc.FieldName__c)
            ) {
                continue;
            }

            orgChartFields.add(oc);
        }

        return orgChartFields;
    }

    public static List<Org_Chart_Field__c> getVisibleOrgChartFields(String mapType) {
        System.debug('===OrgChartSettingsController getVisibleOrgChartFields===');
        System.debug('===mapType==='+mapType);
        List<Org_Chart_Field__c> orgChartFields = OrgChartFieldSelector.newInstance().selectVisibleByMapType(mapType);

        if (orgChartFields.isEmpty()) {
            System.debug('===createOrgChartDefaults===');
            orgChartFields = createOrgChartDefaults(mapType);
        }
        System.debug('===orgChartFields==='+orgChartFields);
        List<Org_Chart_Field__c> result = new List<Org_Chart_Field__c>();
        Map<String, SObjectType> gd = getOrgChartFieldDescribe();
        for (Org_Chart_Field__c ocf : orgChartFields) {
            SObjectType objType = gd.get(ocf.ObjectName__c);
            System.debug('===objType==='+objType);
            String fieldName = ocf.FieldName__c;
            // The field name for Related field is place in Related_FieldName__ so that we can store the relationship.field (example Account.Name) for querying
            if (ocf.Related_FieldName__c != null && ocf.Related_FieldName__c.length() > 0) {
                fieldName = ocf.Related_FieldName__c;
            }

            if (objType != null && UtilityForSObject.isFieldReadable(objType, fieldName)) {
                result.add(ocf);
            }
            System.debug('====result=='+result);
        }

        return result;
    }

    public static List<Org_Chart_Field__c> getVisibleOrgChartFieldsByObjectNameAndMapType(String mapType,Set<String> objectNameSet) {
        System.debug('===OrgChartSettingsController getVisibleOrgChartFields===');
        System.debug('===mapType==='+mapType);
        List<Org_Chart_Field__c> orgChartFields = OrgChartFieldSelector.newInstance().selectVisibleByMapTypeAndObjectName(mapType,objectNameSet);

        if (orgChartFields.isEmpty()) {
            System.debug('===createOrgChartDefaults===');
            orgChartFields = createOrgChartDefaults(mapType);
        }
        System.debug('===orgChartFields==='+orgChartFields);
        List<Org_Chart_Field__c> result = new List<Org_Chart_Field__c>();
        Map<String, SObjectType> gd = getOrgChartFieldDescribe();
        for (Org_Chart_Field__c ocf : orgChartFields) {
            SObjectType objType = gd.get(ocf.ObjectName__c);
            System.debug('===objType==='+objType);
            String fieldName = ocf.FieldName__c;
            // The field name for Related field is place in Related_FieldName__ so that we can store the relationship.field (example Account.Name) for querying
            if (ocf.Related_FieldName__c != null && ocf.Related_FieldName__c.length() > 0) {
                fieldName = ocf.Related_FieldName__c;
            }

            if (objType != null && UtilityForSObject.isFieldReadable(objType, fieldName)) {
                result.add(ocf);
            }
            System.debug('====result=='+result);
        }

        return result;
    }

    public static List<Org_Chart_Field__c> createOrgChartDefaults(String mapType) {
        Crush_Settings_Obj__c settings = SettingService.getOrgSettingsAndCreateIfNeeded();
        List<Org_Chart_Field__c> fields = null;
        if (mapType == 'Key Stakeholder') {
            fields = createOrgChartDefaultsWithoutInsertForSettingsObj(settings);
        } else if (mapType == null){
            string tempMapType = 'Relationship Map';
            fields = createRelationshipMapDefaultsWithoutInsertForSettingsObj(settings, tempMapType);
        } else {
            fields = createRelationshipMapDefaultsWithoutInsertForSettingsObj(settings, mapType);
        } 

        if (Org_Chart_Field__c.getSObjectType().getDescribe().isCreateable()) {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(fields);
            uow.commitWork();
        }
        System.debug('====fields=='+fields);
        Formula.recalculateFormulas(fields);
        return fields;
    }

    public static List<Org_Chart_Field__c> createOrgChartDefaultsWithoutInsertForSettingsObj(
        Crush_Settings_Obj__c orgSettings
    ) {
        if (orgSettings == null) {
            return null;
        }
        String defaultSettings = orgSettings.Org_Chart_Default_Fields__c;
        if (defaultSettings == null || defaultSettings == '') {
            DescribeFieldResult describe = Crush_Settings_Obj__c.Org_Chart_Default_Fields__c.getDescribe();
            defaultSettings = (String) describe.getDefaultValueFormula().replace('"', '');
        }
        return createOrgChartDefaultsWithoutInsertForSettingsMapAndType(defaultSettings, 'Key Stakeholder');
    }

    public static List<Org_Chart_Field__c> createRelationshipMapDefaultsWithoutInsertForSettingsObj(
        Crush_Settings_Obj__c orgSettings,
        String mapType
    ) {
        if (orgSettings == null) {
            return null;
        }
        String defaultSettings = orgSettings.Relationship_Map_Default_Fields__c;
        if (defaultSettings == null || defaultSettings == '') {
            DescribeFieldResult describe = Crush_Settings_Obj__c.Relationship_Map_Default_Fields__c.getDescribe();
            defaultSettings = (String) describe.getDefaultValueFormula().replace('"', '');
        }
        return createOrgChartDefaultsWithoutInsertForSettingsMapAndType(defaultSettings, mapType);
    }

    public static List<Org_Chart_Field__c> createOrgChartDefaultsWithoutInsertForSettingsMapAndType(
        String defaultSettings,
        String mapType
    ) {
        if (defaultSettings == null) {
            return null;
        }

        List<String> settingsList = defaultSettings.split(',');

        List<Org_Chart_Field__c> fields = new List<Org_Chart_Field__c>();
        for (String setting : settingsList) {
            List<String> fieldParts = setting.split('\\.');
            String objectName = fieldParts.get(0);
            String fieldName = fieldParts.get(1);
            Boolean isRequired = false;
            if (fieldParts.size() == 3) {
                isRequired = true;
            }

            // Skip old influence & support values
            if (
                fieldName == 'Influence__c' ||
                fieldName == 'Support__c' ||
                fieldName == 'pqcrush__Influence__c' ||
                fieldName == 'pqcrush__Support__c'
            ) {
                continue;
            }

            if (objectName == 'Relationship_Map_Member__c') {
                objectName = 'pqcrush__Relationship_Map_Member__c';
                fieldName = 'pqcrush__' + fieldName;
            } else if (objectName == 'Key_Stakeholder__c') {
                objectName = 'pqcrush__Key_Stakeholder__c';
                fieldName = 'pqcrush__' + fieldName;
            }

            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(
                new List<String>{ objectName }
            );
            Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
            String fieldLabel = allFields.get(fieldName).getDescribe().getLabel();

            Org_Chart_Field__c orgChartField = (Org_Chart_Field__c) Org_Chart_Field__c.getSObjectType()
                .newSObject(null, true);
            orgChartField.ObjectName__c = objectName;
            orgChartField.FieldName__c = fieldName;
            orgChartField.FieldLabel__c = fieldLabel;
            orgChartField.isRequired__c = isRequired;
            orgChartField.isVisible__c = true;
            orgChartField.Map_Type__c = mapType;
            orgChartField.IsMain__c = true;

            fields.add(orgChartField);
        }
        return fields;
    }

    @AuraEnabled
    public static List<OrgChartFieldWrapper> saveSettings(String updateListJson, Id[] deleteIds) {
        List<OrgChartFieldWrapper> orgChartWrapperList = (List<OrgChartFieldWrapper>) JSON.deserialize(
            updateListJson,
            List<OrgChartFieldWrapper>.class
        );

        List<Org_Chart_Field__c> orgChartList = OrgChartFieldWrapper.toSObjectList(orgChartWrapperList);

        if (deleteIds.size() > 0) {
            deleteOrgChartFields(deleteIds);
        }

        if (orgChartList.size() > 0) {
            upsertOrgChartFields(orgChartList);
        }

        List<Org_Chart_Field__c> orgChartFieldsPreFilter = OrgChartFieldSelector.newInstance()
            .selectByMapType('Key Stakeholder');

        List<Org_Chart_Field__c> orgChartFields = removeDeprecatedFeilds(orgChartFieldsPreFilter);

        List<OrgChartFieldWrapper> result = new List<OrgChartFieldWrapper>();

        Set<String> uniques = new Set<String>();
        for (Org_Chart_Field__c ocf : orgChartFields) {
            OrgChartFieldWrapper newField = new OrgChartFieldWrapper(ocf);
            String key = newField.objectName + '_' + newField.fieldName;
            if (!uniques.contains(key)) {
                result.add(new OrgChartFieldWrapper(ocf));
            }
            uniques.add(key);
        }
        return result;
    }
    //Added By Navya
    @AuraEnabled
    public static List<OrgChartFieldWrapper> saveSettingsAccount(String updateListJson, Id[] deleteIds) {
        List<OrgChartFieldWrapper> orgChartWrapperList = (List<OrgChartFieldWrapper>) JSON.deserialize(
            updateListJson,
            List<OrgChartFieldWrapper>.class
        );

        List<Org_Chart_Field__c> orgChartList = OrgChartFieldWrapper.toSObjectList(orgChartWrapperList);

        if (deleteIds.size() > 0) {
            deleteOrgChartFields(deleteIds);
        }

        if (orgChartList.size() > 0) {
            upsertOrgChartFields(orgChartList);
        }

        List<Org_Chart_Field__c> orgChartFieldsPreFilter = OrgChartFieldSelector.newInstance()
            .selectByObjectNameAndMapType('Account','Account Map');

        List<Org_Chart_Field__c> orgChartFields = removeDeprecatedFeilds(orgChartFieldsPreFilter);

        List<OrgChartFieldWrapper> result = new List<OrgChartFieldWrapper>();

        Set<String> uniques = new Set<String>();
        for (Org_Chart_Field__c ocf : orgChartFields) {
            OrgChartFieldWrapper newField = new OrgChartFieldWrapper(ocf);
            String key = newField.objectName + '_' + newField.fieldName;
            if (!uniques.contains(key)) {
                result.add(new OrgChartFieldWrapper(ocf));
            }
            uniques.add(key);
        }
        System.debug('=== saveSettingsAccount OrgChartFieldWrapper list result==='+result);
        return result;
    }

    public static void upsertOrgChartFields(List<Org_Chart_Field__c> orgChartFields) {
        if (
            Org_Chart_Field__c.sObjectType.getDescribe().isCreateable() &&
            Org_Chart_Field__c.sObjectType.getDescribe().isUpdateable()
        ) {
            Database.upsert(orgChartFields,true,Accesslevel.USER_MODE);
        }
    }

    private static void deleteOrgChartFields(Id[] items) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Org_Chart_Field__c> orgChartFields = OrgChartFieldSelector.newInstance().selectById(new Set<Id>(items));

        for (Org_Chart_Field__c item : orgChartFields) {
            uow.registerDeleted(item);
        }
        uow.commitWork();
    }

    private static Map<String, Org_Chart_Field__c> mapOrgChartFields(List<Org_Chart_Field__c> orgChartFields) {
        Map<String, Org_Chart_Field__c> orgChartFieldsMap = new Map<String, Org_Chart_Field__c>();
        for (Org_Chart_Field__c field : orgChartFields) {
            orgChartFieldsMap.put(field.FieldName__c, field);
        }
        return orgChartFieldsMap;
    }

    private static Map<String, Schema.SObjectType> getOrgChartFieldDescribe() {
        if (ocfd == null) {
            ocfd = new Map<String, Schema.SObjectType>();
            Schema.SObjectType contactType = Contact.sObjectType;
            Schema.SObjectType ksType = Key_Stakeholder__c.sObjectType;
            Schema.SObjectType rmmType = Relationship_Map_Member__c.sObjectType;
            Schema.SObjectType accountType = Account.sObjectType;
            ocfd.put(contactType.getDescribe().getName(), contactType);
            ocfd.put(ksType.getDescribe().getName(), ksType);
            ocfd.put(rmmType.getDescribe().getName(), rmmType);
            ocfd.put(accountType.getDescribe().getName(), accountType);
        }
        return ocfd;
    }
}