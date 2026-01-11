@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessivePublicCount,PMD.TooManyFields')
public with sharing class RMChartSettingsWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public Boolean showOverview;
    @AuraEnabled
    public String cardStyle;
    @AuraEnabled
    public String displayStyle;
    @AuraEnabled
    public Boolean showParent;
    @AuraEnabled
    public Boolean enableDragSelect;
    @AuraEnabled
    public Boolean autoLayout;
    @AuraEnabled
    public Boolean readOnly;
    @AuraEnabled
    public Boolean showEmptyFields;
    @AuraEnabled
    public Double relationshipLineOpacity;
    @AuraEnabled
    public Double reportsToLineOpacity;
    @AuraEnabled
    public Boolean createNewContact;
    @AuraEnabled
    public Boolean isInfluenceSupportGlobal;
    @AuraEnabled
    public Boolean isCloneEnabled;
    @AuraEnabled
    public Boolean isSettingsEnabled;
    @AuraEnabled
    public Boolean userCanClone;
    @AuraEnabled
    public Boolean userCanAccessSettings;

    private RM_Chart_Setting__c baseChartSettings;
    private RM_Org_Setting__c baseOrgSettings;

    public RMChartSettingsWrapper() {
        this(null, null);
    }

    public RMChartSettingsWrapper(RM_Chart_Setting__c setting, RM_Org_Setting__c orgSetting) {
        this.id = setting?.Id;
        this.showOverview = setting?.Show_Overview__c == null ? false : setting.Show_Overview__c;
        this.cardStyle = setting?.Card_Style__c == null ? 'Detail' : setting.Card_Style__c;
        this.displayStyle = setting?.Display_Style__c == null ? 'Horizontal' : setting.Display_Style__c;
        this.showParent = setting?.Show_Parents__c == null ? false : setting.Show_Parents__c;
        this.enableDragSelect = setting?.Enable_Drag_Select__c == null ? false : setting.Enable_Drag_Select__c;
        this.autoLayout = setting?.Auto_Layout__c == null ? true : setting.Auto_Layout__c;
        this.readOnly = setting?.Read_Only__c == null ? true : setting.Read_Only__c;
        this.showEmptyFields = setting?.Show_Empty_Fields__c == null ? false : setting.Show_Empty_Fields__c;
        this.relationshipLineOpacity = setting?.Relationship_Line_Opacity__c == null
            ? 1
            : setting.Relationship_Line_Opacity__c / 100;
        this.reportsToLineOpacity = setting?.Reports_To_Line_Opacity__c == null
            ? 1
            : setting.Reports_To_Line_Opacity__c / 100;
        this.createNewContact = orgSetting?.Create_New_Contact__c == null ? true : orgSetting.Create_New_Contact__c;
        this.isInfluenceSupportGlobal = setting?.Is_Influence_Support_Global_Scope__c == null
            ? false
            : setting.Is_Influence_Support_Global_Scope__c;
        this.isCloneEnabled = orgSetting?.Show_Clone_Relationship_Map__c == null
            ? true
            : orgSetting.Show_Clone_Relationship_Map__c;
        this.isSettingsEnabled = orgSetting?.Show_Chart_Settings__c == null ? true : orgSetting.Show_Chart_Settings__c;
        this.baseChartSettings = setting;
        this.baseOrgSettings = orgSetting;
        this.userCanClone = FeatureManagement.checkPermission('pqcrush__Can_See_Chart_Clone_Button');
        this.userCanAccessSettings = FeatureManagement.checkPermission('pqcrush__Can_See_Chart_Settings');
    }

    public RM_Chart_Setting__c toChartSettings() {
        if (baseChartSettings == null) {
            baseChartSettings = new RM_Chart_Setting__c();
        }
        baseChartSettings.Show_Overview__c = showOverview;
        baseChartSettings.Card_Style__c = cardStyle;
        baseChartSettings.Display_Style__c = displayStyle;
        baseChartSettings.Show_Parents__c = showParent;
        baseChartSettings.Enable_Drag_Select__c = enableDragSelect;
        baseChartSettings.Auto_Layout__c = autoLayout;
        baseChartSettings.Show_Empty_Fields__c = showEmptyFields;
        baseChartSettings.Relationship_Line_Opacity__c = relationshipLineOpacity * 100;
        baseChartSettings.Reports_To_Line_Opacity__c = reportsToLineOpacity * 100;
        return baseChartSettings;
    }

    public RM_Org_Setting__c toOrgSettings() {
        if (baseOrgSettings == null) {
            baseOrgSettings = new RM_Org_Setting__c();
        }
        baseOrgSettings.Create_New_Contact__c = createNewContact;
        baseOrgSettings.Show_Clone_Relationship_Map__c = isCloneEnabled;
        baseOrgSettings.Show_Chart_Settings__c = isSettingsEnabled;
        return baseOrgSettings;
    }
}