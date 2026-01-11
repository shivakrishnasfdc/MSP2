({
    init: function (component, event, helper) {
        var service = component.find('keyStakeholderService');

        component.set('v.orgSettingsLoading', true);
        Promise.all([service.getOrgSettings()]).then(
            $A.getCallback(function (results) {
                component.set('v.orgSettings', results[0]);
                component.set('v.orgSettingsLoading', false);
            })
        );

        component.set('v.isLoading', true);
        component.set('v.saveDisabled', true);
        var maptype = component.get("v.maptype");
        //Added By Navya START
        var orgChartPromise;
        if(maptype=='accountrelation'){
             orgChartPromise = helper.getOrgChartFieldsAccount(component);
        }else{
            //Added By Navya END
             orgChartPromise = helper.getOrgChartFields(component);
        }
        var objectFieldsPromise = helper.getObjectFields(component);

        helper.setHierarchyLevel(component);

        Promise.all([orgChartPromise, objectFieldsPromise])
            .then(
                $A.getCallback(function () {
                    component.set('v.isLoading', false);
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    StrategyUtils.errorToast(error.message);
                    component.set('v.isLoading', false);
                })
            );
    },

    onChange: function (component, event, helper) {
        var params = event.getParams();
        var objectName = params.objectName;
        var fieldName = params.fieldName;
        var isChecked = params.checked;
        var isMainChecked = params.mainChecked;
        var orgChartFields = component.get('v.orgChartFields');
        var field = _.find(orgChartFields, function (x) {
            return x.objectName === objectName && x.fieldName === fieldName;
        });

        if (isChecked !== null) {
            field.isVisible = isChecked;
        }
        if (isMainChecked !== null) {
            field.isMain = isMainChecked;
        }

        helper.save(component);
    },

    handleHierarchySelection: function (component, event, helper) {
        var level = event.getSource().get('v.value');

        component.set('v.hierarchyLevel', Number.parseInt(level));
        helper.setSaveButtonAvailability(component);
    },

    toggleField: function (component, event, helper) {
        var params = event.getParams();
        var objectName = params.objectName;
        var fieldName = params.fieldName;
        var checked = params.checked;
        var fieldLabel = params.fieldLabel;
        var updatedFields = params.updatedFields;
        var relatedFieldName = params.relatedFieldName;

        component.set('v.objects', updatedFields);
        var orgChartFields = component.get('v.orgChartFields');

        if (checked) {
             var maptype = component.get("v.maptype");
            // Add the object field to the list of org chart fields
            var obj = {
                fieldLabel: fieldLabel,
                fieldName: fieldName,
                objectName: objectName,
                relatedFieldName: relatedFieldName,
                isVisible: true,
                isMain: false,
                isEditable: true,
                mapType:maptype =='accountrelation'?'Account Map': 'Key Stakeholder'
            };

            orgChartFields.push(obj);
            component.set('v.orgChartFields', orgChartFields);
        } else {
            // Remove the object field from the list of org chart fields
            var i = _.findIndex(orgChartFields, function (x) {
                return x.objectName === objectName && x.fieldName === fieldName;
            });

            var removedItem = _.pullAt(orgChartFields, i)[0];

            component.set('v.orgChartFields', orgChartFields);

            var originalOrgChartFields = component.get('v.originalOrgChartFields');

            // If the object field is part of the initial list from the server then add it to the list of items to delete
            if (_.includes(JSON.stringify(originalOrgChartFields), JSON.stringify(removedItem))) {
                var orgChartFieldsToDelete = component.get('v.orgChartFieldsToDelete');

                orgChartFieldsToDelete.push(removedItem);
            }
        }

        helper.save(component);
    },

    onUpdateHierarchy: function (component, event, helper) {
        helper.setHierarchyLevel(component);
    },

    onCancel: function (component, event, helper) {
        helper.resetData(component);
    },

    handleSettingsChanged: function () {
        StrategyUtils.successToast('Settings updated!');
    }
});