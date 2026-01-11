@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class ObjectiveSettingWrapper {
    @AuraEnabled
    public ColorBoundary objective { get; set; }
    @AuraEnabled
    public ColorBoundary task { get; set; }
    @AuraEnabled
    public Boolean allowAddTask { get; set; }
    @AuraEnabled
    public Boolean allowTasksBasedObjStage { get; set; }
    @AuraEnabled
    public Boolean useSFTaskModal { get; set; }
    @AuraEnabled
    public Boolean disableSortButton { get; set; }

    public ObjectiveSettingWrapper(ColorBoundary objective, ColorBoundary task, Boolean allowAddTask) {
        this.objective = objective;
        this.task = task;
        this.allowAddTask = allowAddTask;
    }

    public ObjectiveSettingWrapper(CRUSH_Settings_Obj__c crushSettings) {
        String objLowColor = String.isBlank(crushSettings.Objective_Low_Color__c)
            ? '#E1341E'
            : crushSettings.Objective_Low_Color__c;
        String objMidColor = String.isBlank(crushSettings.Objective_Middle_Color__c)
            ? '#EB8214'
            : crushSettings.Objective_Middle_Color__c;
        String objHighColor = String.isBlank(crushSettings.Objective_High_Color__c)
            ? '#2DD24A'
            : crushSettings.Objective_High_Color__c;
        Decimal objLowMid = (crushSettings.Objective_Low_Middle_Boundary__c == null ||
            crushSettings.Objective_Low_Middle_Boundary__c == 0)
            ? .25
            : crushSettings.Objective_Low_Middle_Boundary__c;
        Decimal objMidHigh = (crushSettings.Objective_Middle_High_Boundary__c == null ||
            crushSettings.Objective_Middle_High_Boundary__c == 0)
            ? .75
            : crushSettings.Objective_Middle_High_Boundary__c;

        this.objective = new ColorBoundary(objLowColor, objMidColor, objHighColor, objLowMid, objMidHigh);

        String taskLowColor = String.isBlank(crushSettings.Objective_Task_Low_Color__c)
            ? '#E1341E'
            : crushSettings.Objective_Task_Low_Color__c;
        String taskMidColor = String.isBlank(crushSettings.Objective_Task_Middle_Color__c)
            ? '#EB8214'
            : crushSettings.Objective_Task_Middle_Color__c;
        String taskHighColor = String.isBlank(crushSettings.Objective_Task_High_Color__c)
            ? '#2DD24A'
            : crushSettings.Objective_Task_High_Color__c;
        Decimal taskLowMid = (crushSettings.Objective_Task_Low_Middle_Boundary__c == null ||
            crushSettings.Objective_Task_Low_Middle_Boundary__c == 0)
            ? .25
            : crushSettings.Objective_Task_Low_Middle_Boundary__c;
        Decimal taskMidHigh = (crushSettings.Objective_Task_Middle_High_Boundary__c == null ||
            crushSettings.Objective_Task_Middle_High_Boundary__c == 0)
            ? .75
            : crushSettings.Objective_Task_Middle_High_Boundary__c;

        this.task = new ColorBoundary(taskLowColor, taskMidColor, taskHighColor, taskLowMid, taskMidHigh);
        this.allowAddTask = crushSettings.Allow_Add_Tasks_From_Objective_Component__c;
        this.allowTasksBasedObjStage = crushSettings.Enable_Objective_Stage_Based_On_Tasks__c;
        this.useSFTaskModal = crushSettings.Use_System_Create_Task_Modal__c;
        this.disableSortButton = crushSettings.Disabled_Objective_Sort_Button__c;
    }

    public static CRUSH_Settings_Obj__c updateSettings(
        CRUSH_Settings_Obj__c crushSettings,
        ObjectiveSettingWrapper wrapper
    ) {
        crushSettings.Objective_Low_Color__c = wrapper.objective.lowColor;
        crushSettings.Objective_Middle_Color__c = wrapper.objective.midColor;
        crushSettings.Objective_High_Color__c = wrapper.objective.highColor;
        crushSettings.Objective_Low_Middle_Boundary__c = wrapper.objective.lowMidBoundary;
        crushSettings.Objective_Middle_High_Boundary__c = wrapper.objective.midHighBoundary;
        crushSettings.Objective_Task_Low_Color__c = wrapper.task.lowColor;
        crushSettings.Objective_Task_Middle_Color__c = wrapper.task.midColor;
        crushSettings.Objective_Task_High_Color__c = wrapper.task.highColor;
        crushSettings.Objective_Task_Low_Middle_Boundary__c = wrapper.task.lowMidBoundary;
        crushSettings.Objective_Task_Middle_High_Boundary__c = wrapper.task.midHighBoundary;

        return crushSettings;
    }
}