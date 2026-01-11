@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class PqPresentAccountPlanController {
    public list<string> finalImageDataList = new List<string>();
    public List<string> componentList { get; set; }
    public String titleOfCarousel { get; set; }
    public String imageURL { get; set; }
    public String imageURLPlan { get; set; }
    public Boolean checkLogo { get; set; }
    public String planId { get; set; }
    public String planName { get; set; }
    public Integer pdfCount { get; set; }
    public List<string> screenShotImage { get; set; }

    public void getListAndImage() {
        planId = ApexPages.currentPage().getParameters().get('planId').escapeHtml4();
        getAccountPlanName();
        sendDynamicList();
        imageController();
        getAssociatedPDFNumbers();
        getAssociatedScreenShotofRelationShipMap();
        getAssociatedScreenShotofCrossSell();
    }

    /******************************************
     * Get Account plan name by its record Id *
     ******************************************/
    public void getAccountPlanName() {
        Id planRecordId = ApexPages.currentPage().getParameters().get('recordId').escapeHtml4();
        List<pqcrush__Account_Plan__c> accountPlanList = new AccountPlanSelector().selectByIdWithName(planRecordId);
        if (accountPlanList.size() != 0) {
            planName = accountPlanList[0].Name.escapeHtml4();
        } else {
            planName = '';
        }
    }
    /************************************************************************
     * Method to get all screen shot of relationship Map associated recordId and aligned in PDF *
     ************************************************************************/
    public void getAssociatedScreenShotofRelationShipMap() {
        list<string> imageDataList = new List<string>();
        //fetching Current record id on which we are persenting Account plan template.
        Id planRecordId = ApexPages.currentPage().getParameters().get('recordId').escapeHtml4();
        //getting Description for relationshipMap map from Custom label.
        String relationShipMapDescription = System.Label.RelationshipMap_Image;
        //list for storing screenshot image information.
        Id userid = UserInfo.getUserId();
        list<ContentVersion> cv = new ContentVersionSelector()
            .selectByFirstPublishLocationIdAndDescriptionWithoutLimit(planRecordId, userid, relationShipMapDescription);
        if (cv.size() != 0) {
            //iterate over screenshot image list.
            for (ContentVersion temp : cv) {
                //storing image data into temp variable name as fieldData.
                Blob fileData = temp.VersionData;
                //converting image data into base 64 into varaible name as fieldString.
                string finalString = EncodingUtil.base64Encode(fileData);
                finalString = finalString + '-->Relationship';
                //storing image base 64 data into imageDataList.
                imageDataList.add(finalString);
            }
            //assigning imageDataList to screenShotImage List.
            finalImageDataList.addAll(imageDataList);
            screenShotImage = finalImageDataList;
        }
    }

    /************************************************************************
     * Method to get all screen shot of relationship Map associated recordId and aligned in PDF *
     ************************************************************************/
    public void getAssociatedScreenShotofCrossSell() {
        list<string> imageDataList = new List<string>();
        //fetching Current record id on which we are persenting Account plan template.
        Id planRecordId = ApexPages.currentPage().getParameters().get('recordId').escapeHtml4();
        //getting Description for cross sell map from Custom label.
        String crossSellDescription = System.Label.CrossSell_Image;
        Id userid = UserInfo.getUserId();
        //list for storing screenshot image information.
        list<ContentVersion> cv = new ContentVersionSelector()
            .selectByFirstPublishLocationIdAndDescriptionWithoutLimit(planRecordId, userid, crossSellDescription);
        if (cv.size() != 0) {
            //iterate over screenshot image list.
            for (ContentVersion temp : cv) {
                //storing image data into temp variable name as fieldData.
                Blob fileData = temp.VersionData;
                //converting image data into base 64 into varaible name as fieldString.
                string finalString = EncodingUtil.base64Encode(fileData);
                finalString = finalString + '-->Crosssell';
                //storing image base 64 data into imageDataList.
                imageDataList.add(finalString);
            }
            //assigning imageDataList to screenShotImage List.
            finalImageDataList.addAll(imageDataList);
            screenShotImage = finalImageDataList;
        }
    }

    /***************************************************************************************************************************
     * Method to fetch Number of PDF records Associated recordId so that we are append version number in pdf name while saving *
     ***************************************************************************************************************************/
    public void getAssociatedPDFNumbers() {
        //fetching Current record id on which we are persenting Account plan template.
        Id planRecordId = ApexPages.currentPage().getParameters().get('recordId').escapeHtml4();
        //getting Description for cross sell map from Custom label.
        String pdfDescription1 = System.Label.Prolifiq_PDF;
        //list for storing PDF Data information.
        Id userid = UserInfo.getUserId();
        List<ContentVersion> contentVersionList = new ContentVersionSelector()
            .selectByFirstPublishLocationIdAndDescriptionWithoutLimit(planRecordId, userid, pdfDescription1);
        //storing List size into variable name as tempVar.
        Integer tempVar = contentVersionList.size();
        //assigning Value to pdfCount.
        pdfCount = tempVar + 1;
    }

    /*****************************************
     * Get all component to show in carousel *
     *****************************************/
    public void sendDynamicList() {
        String planId = ApexPages.currentPage().getParameters().get('planId').escapeHtml4();
        List<pqcrush__Template_Section__c> templateSectionRecords = new TemplateSectionSelector().getTemplateID(planId);
        //Integer limitValue = 1;

        Map<Integer, String> mapStoreIndexComponent = new Map<Integer, String>();
        for (pqcrush__Template_Section__c tempSec : templateSectionRecords) {
            if (tempSec.pqcrush__Is_Related_Object__c == true) {
                mapStoreIndexComponent.put(
                    Integer.valueOf(tempSec.pqcrush__Component_Index__c),
                    'pqcrush:genericDataTableComponent $' + tempSec.pqcrush__Component_Name__c
                );
            } else {
                mapStoreIndexComponent.put(
                    Integer.valueOf(tempSec.pqcrush__Component_Index__c),
                    'pqcrush:' + tempSec.pqcrush__Component_Name__c + ' $pqcrush__Account_Plan__c'
                );
            }
        }

        List<String> componentName = new List<String>();
        for (Integer i = 0; i < mapStoreIndexComponent.size(); i++) {
            componentName.add(mapStoreIndexComponent.get(i));
        }
        componentList = componentName;
        List<pqcrush__Account_Plan_Template__c> titleofTemplate = new AccountPlanTemplateSelector()
            .getTitleOfTemplate(PlanId, 1);
        if (titleofTemplate.size() != 0) {
            titleOfCarousel = titleofTemplate[0].Name.escapeHtml4();
        }
    }

    /*************************************************
     * Make image URL to show image in carousel page *
     *************************************************/
    public void imageController() {
        String contentVersionId = ApexPages.currentPage().getParameters().get('planId').escapeHtml4();
        String accountPlanId = ApexPages.currentPage().getParameters().get('recordId').escapeHtml4();
        String description = System.Label.Header_Logo;
        Integer limitValue = 1;

        List<ContentVersion> content = new ContentVersionSelector()
            .selectByFirstPublishLocationIdAndDescription(contentVersionId, description, limitValue);

        if (content.size() > 0) {
            Blob imageBlob = content[0].VersionData;
            String base64Image = EncodingUtil.base64Encode(imageBlob);
            String fileType = '';
            if (content[0].FileExtension == 'svg') {
                fileType = 'svg+xml';
            } else {
                fileType = content[0].FileExtension;
            }
            imageURL = 'data:image/' + fileType + ';base64,' + base64Image;
        }

        List<ContentVersion> contentAccountPlan = new ContentVersionSelector()
            .selectByFirstPublishLocationIdAndDescription(accountPlanId, description, limitValue);

        if (contentAccountPlan.size() > 0) {
            Blob imageBlobPlan = contentAccountPlan[0].VersionData;
            String base64ImagePlan = EncodingUtil.base64Encode(imageBlobplan);
            String planFileType = '';
            if (contentAccountPlan[0].FileExtension == 'svg') {
                planFileType = 'svg+xml';
            } else {
                planFileType = contentAccountPlan[0].FileExtension;
            }
            imageURLPlan = 'data:image/' + planFileType + ';base64,' + base64ImagePlan;
            checkLogo = true;
        } else {
            imageURLPlan = null;
            checkLogo = false;
        }
    }
}