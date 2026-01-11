@isTest
private class ObjectiveSettingWrapperTest {
    @isTest
    static void objectiveSettingWrapperTest1() {
        ColorBoundary obj = new ColorBoundary('#a00000', '#b00000', '#c00000', .20, .80);
        ColorBoundary tasks = new ColorBoundary('#d00000', '#e00000', '#f00000', .30, .70);
        Boolean allowAddTask = true;

        ObjectiveSettingWrapper wrapper = new ObjectiveSettingWrapper(obj, tasks, allowAddTask);
        System.assertEquals('#a00000', wrapper.objective.lowColor);
        System.assertEquals('#b00000', wrapper.objective.midColor);
        System.assertEquals('#c00000', wrapper.objective.highColor);
        System.assertEquals(.20, wrapper.objective.lowMidBoundary);
        System.assertEquals(.80, wrapper.objective.midHighBoundary);
        System.assertEquals('#d00000', wrapper.task.lowColor);
        System.assertEquals('#e00000', wrapper.task.midColor);
        System.assertEquals('#f00000', wrapper.task.highColor);
        System.assertEquals(.30, wrapper.task.lowMidBoundary);
        System.assertEquals(.70, wrapper.task.midHighBoundary);
        System.assertEquals(allowAddTask, wrapper.allowAddTask);
    }

    @isTest
    static void objectiveSettingWrapperTest2() {
        CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Objective_Low_Color__c = '#a00000',
            Objective_Middle_Color__c = '#b00000',
            Objective_Low_Middle_Boundary__c = .20,
            Objective_High_Color__c = '#c00000',
            Objective_Middle_High_Boundary__c = .80,
            Objective_Task_Low_Color__c = '#d00000',
            Objective_Task_Middle_Color__c = '#e00000',
            Objective_Task_Low_Middle_Boundary__c = .30,
            Objective_Task_High_Color__c = '#f00000',
            Objective_Task_Middle_High_Boundary__c = .70,
            Allow_Add_Tasks_From_Objective_Component__c = true,
            Enable_Objective_Stage_Based_On_Tasks__c = true,
            Use_System_Create_Task_Modal__c = true
        );
        ObjectiveSettingWrapper wrapper = new ObjectiveSettingWrapper(orgSettings);
        System.assertEquals('#a00000', wrapper.objective.lowColor);
        System.assertEquals('#b00000', wrapper.objective.midColor);
        System.assertEquals('#c00000', wrapper.objective.highColor);
        System.assertEquals(.20, wrapper.objective.lowMidBoundary);
        System.assertEquals(.80, wrapper.objective.midHighBoundary);
        System.assertEquals('#d00000', wrapper.task.lowColor);
        System.assertEquals('#e00000', wrapper.task.midColor);
        System.assertEquals('#f00000', wrapper.task.highColor);
        System.assertEquals(.30, wrapper.task.lowMidBoundary);
        System.assertEquals(.70, wrapper.task.midHighBoundary);
        System.assertEquals(true, wrapper.allowAddTask);
        System.assertEquals(true, wrapper.useSFTaskModal);
    }

    @isTest
    static void updateSettingTest() {
        CRUSH_Settings_Obj__c orgSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Objective_Low_Color__c = '#a00000',
            Objective_Middle_Color__c = '#b00000',
            Objective_Low_Middle_Boundary__c = .20,
            Objective_High_Color__c = '#c00000',
            Objective_Middle_High_Boundary__c = .80,
            Objective_Task_Low_Color__c = '#d00000',
            Objective_Task_Middle_Color__c = '#e00000',
            Objective_Task_Low_Middle_Boundary__c = .30,
            Objective_Task_High_Color__c = '#f00000',
            Objective_Task_Middle_High_Boundary__c = .70
        );

        CRUSH_Settings_Obj__c updatedSettings = new CRUSH_Settings_Obj__c(
            Type__c = 'Org',
            Objective_Low_Color__c = '#100000',
            Objective_Middle_Color__c = '#200000',
            Objective_Low_Middle_Boundary__c = .10,
            Objective_High_Color__c = '#300000',
            Objective_Middle_High_Boundary__c = .20,
            Objective_Task_Low_Color__c = '#400000',
            Objective_Task_Middle_Color__c = '#500000',
            Objective_Task_Low_Middle_Boundary__c = .80,
            Objective_Task_High_Color__c = '#600000',
            Objective_Task_Middle_High_Boundary__c = .90
        );

        ObjectiveSettingWrapper wrapper = new ObjectiveSettingWrapper(updatedSettings);

        CRUSH_Settings_Obj__c newSettings = ObjectiveSettingWrapper.updateSettings(orgSettings, wrapper);
        System.assertEquals('#100000', newSettings.Objective_Low_Color__c);
        System.assertEquals('#200000', newSettings.Objective_Middle_Color__c);
        System.assertEquals('#300000', newSettings.Objective_High_Color__c);
        System.assertEquals(.10, newSettings.Objective_Low_Middle_Boundary__c);
        System.assertEquals(.20, newSettings.Objective_Middle_High_Boundary__c);
        System.assertEquals('#400000', newSettings.Objective_Task_Low_Color__c);
        System.assertEquals('#500000', newSettings.Objective_Task_Middle_Color__c);
        System.assertEquals('#600000', newSettings.Objective_Task_High_Color__c);
        System.assertEquals(.80, newSettings.Objective_Task_Low_Middle_Boundary__c);
        System.assertEquals(.90, newSettings.Objective_Task_Middle_High_Boundary__c);
    }
}