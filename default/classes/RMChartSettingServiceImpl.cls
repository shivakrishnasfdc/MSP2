@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class RMChartSettingServiceImpl {
    private static Map<Id, RM_Chart_Setting__c> settingsCache = new Map<Id, RM_Chart_Setting__c>();
    /******************************
     *      PUBLIC METHODS
     ******************************/

    public RM_Chart_Setting__c getRelationshipMapSettingForObject(Id objectId) {
        if (settingsCache.containsKey(objectId)) {
            return settingsCache.get(objectId);
        }
        Map<Id, RM_Chart_Setting__c> settings = getRelationshipMapSettingForObjects(new Set<Id>{ objectId }, false);
        RM_Chart_Setting__c setting = settings.get(objectId);
        settingsCache.put(objectId, setting);
        return setting;
    }

    public RM_Chart_Setting__c getRelationshipMapSettingForObjectCreateIfNeeded(Id objectId) {
        if (settingsCache.containsKey(objectId)) {
            return settingsCache.get(objectId);
        }
        Map<Id, RM_Chart_Setting__c> settings = getRelationshipMapSettingForObjects(new Set<Id>{ objectId }, true);
        RM_Chart_Setting__c setting = settings.get(objectId);
        settingsCache.put(objectId, setting);
        return setting;
    }

    public Map<Id, RM_Chart_Setting__c> getRelationshipMapSettingForObjects(Set<Id> objectIds, Boolean insertOnCreate) {
        List<RM_Chart_Setting__c> settings = RMChartSettingSelector.newInstance().selectByObjectId(objectIds);

        Map<Id, RM_Chart_Setting__c> result = new Map<Id, RM_Chart_Setting__c>();

        for (RM_Chart_Setting__c setting : settings) {
            if (setting.Relationship_Map__c != null) {
                result.put(setting.Relationship_Map__c, setting);
            } else if (setting.Account_Plan__c != null) {
                result.put(setting.Account_Plan__c, setting);
            }
        }

        for (Id objId : objectIds) {
            if (!result.containsKey(objId)) {
                result.put(objId, createSettingForObject(objId, insertOnCreate));
            }
        }

        return result;
    }

    private RM_Chart_Setting__c createSettingForObject(Id objectId, Boolean shouldInsert) {
        // IF SETTINGS DOESN'T EXISTS, CREATE ONE
        Id accountPlanId = null;
        Id relationshipMapId = null;

        if (objectId != null) {
            if (objectId.getSobjectType() == Account_Plan__c.SObjectType) {
                accountPlanId = objectId;
            } else if (objectId.getSobjectType() == Relationship_Map__c.SObjectType) {
                relationshipMapId = objectId;
            }
        }

        // Get Crush Settings (default values for creating new settings)
        RM_Org_Setting__c orgSettings = RMOrgSettingService.getRMOrgSetting(objectId);

        RM_Chart_Setting__c setting = (RM_Chart_Setting__c) RM_Chart_Setting__c.sObjectType.newSObject(null, true);

        setting.Account_Plan__c = accountPlanId;
        setting.Relationship_Map__c = relationshipMapId;
        setting.Description__c = System.Label.Relationship_Map_Chart_Description;

        setting = this.populateDefaultValues(setting, orgSettings);

        if (shouldInsert) {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(setting);
            uow.commitWork();
        }

        return setting;
    }

    private RM_Chart_Setting__c populateDefaultValues(RM_Chart_Setting__c setting, RM_Org_Setting__c orgSettings) {
        if (orgSettings == null) {
            return setting;
        }

        setting.Relationship_Line_Opacity__c = (orgSettings.Relationship_Line_Opacity__c != null)
            ? orgSettings.Relationship_Line_Opacity__c
            : setting.Relationship_Line_Opacity__c;
        setting.Reports_To_Line_Opacity__c = (orgSettings.Reports_To_Line_Opacity__c != null)
            ? orgSettings.Reports_To_Line_Opacity__c
            : setting.Reports_To_Line_Opacity__c;
        setting.Show_Empty_Fields__c = (orgSettings.Show_Empty_Fields__c != null)
            ? orgSettings.Show_Empty_Fields__c
            : setting.Show_Empty_Fields__c;
        setting.Show_Overview__c = (orgSettings.Show_Overview__c != null)
            ? orgSettings.Show_Overview__c
            : setting.Show_Overview__c;
        setting.Show_Parents__c = (orgSettings.Show_Parents__c != null)
            ? orgSettings.Show_Parents__c
            : setting.Show_Parents__c;
        setting.Is_Group_Global_Scope__c = (orgSettings.Is_Group_Global_Scope__c != null)
            ? orgSettings.Is_Group_Global_Scope__c
            : setting.Is_Group_Global_Scope__c;
        setting.Is_Badge_Global_Scope__c = (orgSettings.Is_Badge_Global_Scope__c != null)
            ? orgSettings.Is_Badge_Global_Scope__c
            : setting.Is_Badge_Global_Scope__c;
        setting.Is_Relationship_Line_Global_Scope__c = (orgSettings.Is_Relationship_Line_Global_Scope__c != null)
            ? orgSettings.Is_Relationship_Line_Global_Scope__c
            : setting.Is_Relationship_Line_Global_Scope__c;
        setting.Display_Style__c = (orgSettings.Display_Style__c != null)
            ? orgSettings.Display_Style__c
            : setting.Display_Style__c;
        setting.Enable_Drag_Select__c = (orgSettings.Enable_Drag_Select__c != null)
            ? orgSettings.Enable_Drag_Select__c
            : setting.Enable_Drag_Select__c;
        setting.Card_Style__c = (orgSettings.Card_Style__c != null) ? orgSettings.Card_Style__c : setting.Card_Style__c;
        setting.Auto_Layout__c = (orgSettings.Auto_Layout__c != null)
            ? orgSettings.Auto_Layout__c
            : setting.Auto_Layout__c;
        setting.Is_Influence_Support_Global_Scope__c = (orgSettings.Is_Influence_Support_Global_Scope__c != null)
            ? orgSettings.Is_Influence_Support_Global_Scope__c
            : setting.Is_Influence_Support_Global_Scope__c;
        setting.Is_Reports_To_Global_Scope__c = (orgSettings.Is_Reports_To_Global_Scope__c != null)
            ? orgSettings.Is_Reports_To_Global_Scope__c
            : setting.Is_Reports_To_Global_Scope__c;
        return setting;
    }
}