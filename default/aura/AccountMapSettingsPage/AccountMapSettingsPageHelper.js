({
    getObjectFields: function (component) {
        var maptype = component.get("v.maptype");
        return StrategyUtils.executeAction(component, 'c.getKSObjectFields', {maptype:maptype}).then(
            $A.getCallback(function (results) {
                var originalCopy = JSON.parse(JSON.stringify(results));

                component.set('v.originalObjects', originalCopy);
                component.set('v.objects', results);

                return Promise.resolve();
            })
        );
    },

    getOrgChartFields: function (component) {
        return StrategyUtils.executeAction(component, 'c.getOrgChartFields', { mapType: 'Key Stakeholder' }).then(
            $A.getCallback(function (results) {
                var originalCopy = JSON.parse(JSON.stringify(results));

                component.set('v.originalOrgChartFields', originalCopy);
                component.set('v.orgChartFields', results);

                return Promise.resolve();
            })
        );
    },
    //Added By Navya START
    getOrgChartFieldsAccount: function (component) {
        return StrategyUtils.executeAction(component, 'c.getOrgChartFieldsAccount', { mapType: 'Account Map' }).then(
            $A.getCallback(function (results) {
                var originalCopy = JSON.parse(JSON.stringify(results));

                component.set('v.originalOrgChartFields', originalCopy);
                component.set('v.orgChartFields', results);

                return Promise.resolve();
            })
        );
    },
//Added By Navya END
    setHierarchyLevel: function (component) {
        var level = component.get('v.hierarchyLevel');

        component.set('v.originalHierarchyLevel', level);
    },

    setColorMaps: function (component, colorMap) {
        component.set('v.originalSupportColorsMap', Object.assign({}, colorMap));
        component.set('v.supportColorsMap', Object.assign({}, colorMap));

        this.setColorsToSupport(component, colorMap);
    },

    setColorsToSupport: function (component, colorMap) {
        var support = component.get('v.support');

        for (var i = 0; i < support.length; i++) {
            support[i].color = '#aaaaaa';
            if (colorMap) {
                var color = colorMap[support[i].name];

                if (color) {
                    support[i].color = color;
                }
            }
        }
        component.set('v.support', support);
    },

    resetData: function (component) {
        component.set('v.isLoading', true);

        var originalObjectFields = JSON.parse(JSON.stringify(component.get('v.originalObjects')));

        component.set('v.objects', originalObjectFields);

        var originalOrgChartFields = JSON.parse(JSON.stringify(component.get('v.originalOrgChartFields')));

        component.set('v.orgChartFields', originalOrgChartFields);
        component.set('v.orgChartFieldsToDelete', []);

        var level = component.get('v.originalHierarchyLevel');

        component.set('v.hierarchyLevel', level);

        var originalColorMap = component.get('v.originalSupportColorsMap');

        component.set('v.supportColorsMap', Object.assign({}, originalColorMap));
        this.setColorsToSupport(component, originalColorMap);

        component.set('v.isLoading', false);
    },

    setSaveButtonAvailability: function (component) {
        var originalOrgChartFields = component.get('v.originalOrgChartFields');
        var orgChartFields = component.get('v.orgChartFields');
        var hierarchyLevel = component.get('v.hierarchyLevel');
        var originalHierarchyLevel = component.get('v.originalHierarchyLevel');
        var supportColors = component.get('v.supportColorsMap');
        var originalSupportColors = component.get('v.originalSupportColorsMap');

        if (
            _.isEqual(originalOrgChartFields, orgChartFields) &&
            hierarchyLevel === originalHierarchyLevel &&
            supportColors === originalSupportColors
        ) {
            component.set('v.saveDisabled', true);
        } else {
            component.set('v.saveDisabled', false);
        }
    },

    save: function (component) {
        component.set('v.isLoading', true);

        var updateList = component.get('v.orgChartFields');
        var deleteList = component.get('v.orgChartFieldsToDelete');
        var deleteIds = deleteList.map(function (item) {
            return item.id;
        });
        //Added By Navya START
        var maptype = component.get("v.maptype");
        if(maptype =='accountrelation'){
            StrategyUtils.executeAction(component, 'c.saveSettingsAccount', {
            updateListJson: JSON.stringify(updateList),
            deleteIds: deleteIds
        })
            .then(
                $A.getCallback(function (results) {
                    var originalOrgChartFields = JSON.parse(JSON.stringify(results));

                    component.set('v.originalOrgChartFields', originalOrgChartFields);
                    component.set('v.orgChartFields', results);

                    var originalObjects = JSON.parse(JSON.stringify(component.get('v.objects')));

                    component.set('v.originalObjects', originalObjects);

                    component.set('v.orgChartFieldsToDelete', []);
                    component.set('v.saveDisabled', true);
                    component.set('v.isLoading', false);

                    StrategyUtils.successToast('Settings updated!');
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    component.set('v.isLoading', false);
                    StrategyUtils.errorToast(error.message);
                })
            );
            //Added By Navya END
}else{
        StrategyUtils.executeAction(component, 'c.saveSettings', {
            updateListJson: JSON.stringify(updateList),
            deleteIds: deleteIds
        })
            .then(
                $A.getCallback(function (results) {
                    var originalOrgChartFields = JSON.parse(JSON.stringify(results));

                    component.set('v.originalOrgChartFields', originalOrgChartFields);
                    component.set('v.orgChartFields', results);

                    var originalObjects = JSON.parse(JSON.stringify(component.get('v.objects')));

                    component.set('v.originalObjects', originalObjects);

                    component.set('v.orgChartFieldsToDelete', []);
                    component.set('v.saveDisabled', true);
                    component.set('v.isLoading', false);

                    StrategyUtils.successToast('Settings updated!');
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    component.set('v.isLoading', false);
                    StrategyUtils.errorToast(error.message);
                })
            );
        }
    }
});