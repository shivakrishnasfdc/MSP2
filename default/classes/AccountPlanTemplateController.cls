public with sharing class AccountPlanTemplateController {
    public String recordId { get; set; }
    public String headerTitle { get; set; }
    public String planId { get; set; }
    public String showAttribute { get; set; }
    public String recordIdPlan { get; set; }

    /*********************
     * Get Parameters *
     *********************/
    public AccountPlanTemplateController(ApexPages.StandardController controller) {
        recordId = ApexPages.CurrentPage().getparameters().get('id');
        headerTitle = ApexPages.CurrentPage().getparameters().get('param1');
        planId = ApexPages.CurrentPage().getparameters().get('param5');
        recordIdPlan = ApexPages.CurrentPage().getparameters().get('recordId');
        if (ApexPages.CurrentPage().getparameters().get('showAttribute') == 'true') {
            showAttribute = ApexPages.CurrentPage().getparameters().get('showAttribute');
        } else {
            showAttribute = 'false';
        }
    }

    public AccountPlanTemplateController() {
        this(null);
    }

    /************************************
     * Get specific AccountPlan data *
     ************************************/
    @AuraEnabled
    public static List<pqcrush__Account_Plan__c> getAccountPlan(String planName) {
        List<pqcrush__Account_Plan__c> accountPlanList = new AccountPlanSelector().selectByName(planName);
        if (accountPlanList.isEmpty()) {
            return null;
        }
        return accountPlanList;
    }

    /***************************
     * Get all custom metadata *
     ***************************/
    @AuraEnabled
    public static List<pqcrush__Component_Available__mdt> getComponentAvailableMdt() {
        List<pqcrush__Component_Available__mdt> componentList = pqcrush__Component_Available__mdt.getAll().values();
        if (componentList.isEmpty()) {
            return null;
        }
        return componentList;
    }

    /********************************************
     * Get specific AccountPlanTemplate data *
     ********************************************/
    @AuraEnabled
    public static List<pqcrush__Account_Plan_Template__c> getAccountPlanTemplate(String templateName) {
        List<pqcrush__Account_Plan_Template__c> accountPlanTemplateList = new AccountPlanTemplateSelector()
            .selectByName(templateName);
        if (accountPlanTemplateList.isEmpty()) {
            return null;
        }
        return accountPlanTemplateList;
    }

    /******************************************************
     * To Create the record of Accountplantemplate object *
     ******************************************************/
    @AuraEnabled
    public static String receiveCanvasData(
        String componentName,
        String title,
        String image,
        String components,
        String uploadfileName,
        Boolean saveAsDraft,
        String recordIdOfTemplate
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        if (saveAsDraft) {
            List<pqcrush__Account_Plan_Template__c> defaltCanvas = new AccountPlanTemplateSelector().selectByDefault(1);
            if (defaltCanvas.size() != 0) {
                defaltCanvas[0].pqcrush__Default__c = false;
                uow.registerDirty(defaltCanvas[0]);
            }
        }
        pqcrush__Account_Plan_Template__c accountTemplate;
        if (recordIdOfTemplate != '') {
            accountTemplate = new pqcrush__Account_Plan_Template__c(
                pqcrush__Header_Title__c = title,
                Name = componentName,
                pqcrush__Default__c = saveAsDraft,
                Id = recordIdOfTemplate
            );
        } else {
            accountTemplate = new pqcrush__Account_Plan_Template__c(
                pqcrush__Header_Title__c = title,
                Name = componentName,
                pqcrush__Default__c = saveAsDraft
            );
        }
        uow.registerUpsert(accountTemplate);
        uow.commitWork();
        String accTempId = accountTemplate.Id;
        if (image != null) {
            AccountPlanTemplateController.createContentVersion(image, accTempId, uploadfileName);
        }
        AccountPlanTemplateController.createTemplateSection(accTempId, components);
        return accTempId;
    }

    /******************************************************
     * Create Contentent version of Account plan template *
     ******************************************************/
    static void createContentVersion(String image, String accTempId, String uploadfileName) {
        AccountPlanTemplateController.deleteContentVersion(accTempId);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        if (image != '') {
            ContentVersion conVer = new ContentVersion();
            conVer.Title = uploadfileName;
            conVer.PathOnClient = uploadfileName;
            conVer.FirstPublishLocationId = accTempId;
            conVer.VersionData = EncodingUtil.base64Decode(image);
            conVer.Description = System.Label.Header_Logo;
            uow.registerNew(conVer);
            uow.commitWork();
        }
    }

    /***********************************************************************
     * Create template section records of perticular account plan template *
     ***********************************************************************/
    static void createTemplateSection(String accTempId, String components) {
        AccountPlanTemplateController.deleteTemplateSection(accTempId);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        List<pqcrush__Template_Section__c> templateSectionList = new List<pqcrush__Template_Section__c>();
        List<AccountPlanTemplateControllerWrapper.WrapperTemplate> wrapperData = parse(components);
        for (AccountPlanTemplateControllerWrapper.WrapperTemplate wrp : wrapperData) {
            pqcrush__Template_Section__c templateSection = new pqcrush__Template_Section__c(
                pqcrush__Template__c = accTempId,
                pqcrush__Component_Name__c = wrp.componentApiName,
                pqcrush__Component_Index__c = wrp.componentIndex,
                pqcrush__Component_Label__c = wrp.componentName,
                pqcrush__Is_Related_Object__c = wrp.isRelatedObject
            );
            templateSectionList.add(templateSection);
        }
        uow.registerNew(templateSectionList);
        uow.commitWork();
    }

    /************************************************************
     * Get data form AccountPlanTemplateControllerWrapper class *
     ************************************************************/
    static List<AccountPlanTemplateControllerWrapper.WrapperTemplate> parse(String json) {
        return (List<AccountPlanTemplateControllerWrapper.WrapperTemplate>) System.JSON.deserialize(
            json,
            List<AccountPlanTemplateControllerWrapper.WrapperTemplate>.class
        );
    }

    /***************************************
     * Get Account plan template by its Id *
     ***************************************/
    @AuraEnabled
    public static pqcrush__Account_Plan_Template__c getTemplateById(String id) {
        List<pqcrush__Account_Plan_Template__c> templateList = new AccountPlanTemplateSelector().selectById(id);
        if (templateList.isEmpty()) {
            return null;
        }
        return templateList[0];
    }

    /*********************************************************
     * Get content version of specific Account plan template *
     *********************************************************/
    @AuraEnabled
    public static List<String> getContentVersion(String id) {
        String description = System.Label.Header_Logo;
        List<String> imageDataList = new List<String>();
        List<ContentVersion> contentVersionList = new ContentVersionSelector()
            .selectByFirstPublishLocationIdAndDescription(id, description, 1);
        if (contentVersionList.isEmpty()) {
            return null;
        }
        Blob imageBlob = contentVersionList[0].VersionData;
        String base64Image = EncodingUtil.base64Encode(imageBlob);
        String extension = contentVersionList[0].FileExtension;
        String title = contentVersionList[0].Title;
        if (extension == 'svg') {
            extension = 'svg+xml';
        }
        String imageURL = 'data:image/' + extension + ';base64,' + base64Image;
        imageDataList.add(imageURL);
        imageDataList.add(base64Image);
        imageDataList.add(title);
        return imageDataList;
    }

    /************************************************************
     * Get template section of perticular account plan template *
     ************************************************************/
    @AuraEnabled
    public static List<pqcrush__Template_Section__c> getTemplateSection(String id) {
        List<pqcrush__Template_Section__c> templateSectionList = new TemplateSectionSelector().getTemplateID(id);
        if (templateSectionList.isEmpty()) {
            return null;
        }
        return templateSectionList;
    }

    /***************************************************************
     * Delete template Section of perticular account plan template *
     ***************************************************************/
    static String deleteTemplateSection(String id) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        List<pqcrush__Template_Section__c> templateSectionList = new TemplateSectionSelector().getTemplateID(id);
        if (templateSectionList.isEmpty()) {
            return null;
        }
        uow.registerDeleted(templateSectionList);
        uow.commitWork();
        return 'Success';
    }

    /**************************************************************
     * Delete content version of perticular account plan template *
     **************************************************************/
    static String deleteContentVersion(String id) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
        String description = System.Label.Header_Logo;
        List<ContentVersion> contentVersionList = new ContentVersionSelector()
            .selectByFirstPublishLocationIdAndDescription(id, description, 1);
        if (contentVersionList.isEmpty()) {
            return null;
        }
        ContentDocument conTentDoc = new ContentDocument(Id = contentVersionList[0].ContentDocumentId);
        uow.registerDeleted(conTentDoc);
        uow.commitWork();
        return 'Success';
    }
}