public with sharing class SaveAccountPlanLogo {
    /*****************************************
     * Create Content version of Account Plan *
     ******************************************/
    @AuraEnabled
    public static Map<string, string> saveAccountPlanUploadLogo(
        String fileName,
        String fileData,
        String recordId,
        String description
    ) {
        Map<string, string> saveAccountPlan = new Map<string, string>();
        try {
            Integer limitValue = 1;
            List<ContentVersion> contentVersionRecords = new ContentVersionSelector()
                .selectByFirstPublishLocationIdAndDescription(recordId, Description, limitValue);
            List<ContentDocument> contentDocumentsRecords = new List<ContentDocument>();
            if (!contentVersionRecords.isEmpty()) {
                for (ContentVersion cv : contentVersionRecords) {
                    ContentDocument contentRec = new ContentDocument(Id = cv.ContentDocumentId);
                    contentDocumentsRecords.add(contentRec);
                }
            }
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new fflib_SObjectUnitOfWork.SimpleDML());
            uow.registerDeleted(contentDocumentsRecords);
            if (fileData != '') {
                ContentVersion conVer = new ContentVersion();
                conVer.Title = fileName;
                conVer.PathOnClient = fileName;
                conVer.FirstPublishLocationId = recordId;
                conVer.VersionData = EncodingUtil.base64Decode(FileData);
                conVer.Description = Description;
                uow.registerNew(conVer);
            }
            uow.commitWork();
            saveAccountPlan.put('status', 'Success');
            saveAccountPlan.put('msg', 'Success');
        } catch (Exception e) {
            saveAccountPlan.put('status', 'Error');
            saveAccountPlan.put('msg', e.getMessage());
        }
        return saveAccountPlan;
    }

    @AuraEnabled
    public static List<String> getContentVersion(String planId, String description) {
        Integer limitValue = 1;
        List<String> imageDataList = new List<String>();
        List<ContentVersion> contentVersionList = new ContentVersionSelector()
            .selectByFirstPublishLocationIdAndDescription(planId, description, limitValue);

        if (contentVersionList.isEmpty()) {
            return null;
        }
        ContentVersion contentVersion = contentVersionList[0];
        Blob imageBlob = contentVersion.VersionData;
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
}