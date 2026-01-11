@SuppressWarnings('PMD.EmptyStatementBlock,PMD.ExcessivePublicCount')
public with sharing class FiltersData {
    @AuraEnabled
    public Id id { get; set; }
    @AuraEnabled
    public Id whiteSpaceId { get; set; }
    @AuraEnabled
    public Id userId { get; set; }
    @AuraEnabled
    public List<String> hiddenHighlights { get; set; }
    @AuraEnabled
    public List<String> hiddenAmountTypes { get; set; }
    @AuraEnabled
    public List<String> hiddenColumns { get; set; }
    @AuraEnabled
    public List<String> hiddenRows { get; set; }
    @AuraEnabled
    public Boolean showUnhighlighted { get; set; }
    @AuraEnabled
    public Boolean showPopulatedRows { get; set; }
    @AuraEnabled
    public Boolean showUnpopulatedRows { get; set; }
    @AuraEnabled
    public Boolean showPopulatedColumns { get; set; }
    @AuraEnabled
    public Boolean showUnpopulatedColumns { get; set; }

    public FiltersData() {
    }

    public FiltersData(WS_User_Setting__c userSetting) {
        this.id = userSetting.Id;
        this.whiteSpaceId = userSetting.White_Space__c;
        this.userId = userSetting.User__c;
        this.showUnhighlighted = userSetting.Show_Unhighlighted__c;
        this.showPopulatedRows = userSetting.Show_Populated_Rows__c;
        this.showUnpopulatedRows = userSetting.Show_Empty_Rows__c;
        this.showPopulatedColumns = userSetting.Show_Populated_Columns__c;
        this.showUnpopulatedColumns = userSetting.Show_Empty_Columns__c;
        this.hiddenHighlights = userSetting.Highlight_Filters__c != null
            ? userSetting.Highlight_Filters__c.split(',')
            : new List<String>();
        this.hiddenAmountTypes = userSetting.Amount_Type_Filters__c != null
            ? userSetting.Amount_Type_Filters__c.split(',')
            : new List<String>();
        this.hiddenColumns = userSetting.Column_Filters__c != null
            ? userSetting.Column_Filters__c.split(',')
            : new List<String>();
        this.hiddenRows = userSetting.Row_Filters__c != null
            ? userSetting.Row_Filters__c.split(',')
            : new List<String>();
    }

    public WS_User_Setting__c unwrap() {
        WS_User_Setting__c settingObj = new WS_User_Setting__c(
            Id = this.id,
            White_Space__c = this.whiteSpaceId,
            User__c = this.userId,
            Show_Unhighlighted__c = this.showUnhighlighted,
            Show_Populated_Rows__c = this.showPopulatedRows,
            Show_Empty_Rows__c = this.showUnpopulatedRows,
            Show_Populated_Columns__c = this.showPopulatedColumns,
            Show_Empty_Columns__c = this.showUnpopulatedColumns
        );

        if (this.hiddenHighlights != null) {
            settingObj.Highlight_Filters__c = String.join(this.hiddenHighlights, ',');
        }
        if (this.hiddenAmountTypes != null) {
            settingObj.Amount_Type_Filters__c = String.join(this.hiddenAmountTypes, ',');
        }
        if (this.hiddenColumns != null) {
            settingObj.Column_Filters__c = String.join(this.hiddenColumns, ',');
        }
        if (this.hiddenRows != null) {
            settingObj.Row_Filters__c = String.join(this.hiddenRows, ',');
        }
        return settingObj;
    }
}