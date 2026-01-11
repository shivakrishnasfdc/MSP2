@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class WhiteSpaceController {
    @AuraEnabled
    public static WhiteSpaceObjectAccess getWhiteSpaceObjectAccessForAccountPlan(Id accountPlanId) {
        UserRecordAccess accountPlanAccess = AccountPlanController.getUserRecordAccess(accountPlanId);
        Boolean canEditAccountPlan =
            accountPlanAccess != null && (accountPlanAccess.HasEditAccess || accountPlanAccess.HasAllAccess);

        return new WhiteSpaceObjectAccess(
            canUpdateObject(White_Space__c.SObjectType) && canEditAccountPlan,
            canCreateObject(White_Space__c.SObjectType) && canEditAccountPlan,
            canDeleteObject(White_Space__c.SObjectType) && canEditAccountPlan,
            canUpdateObject(White_Space_Row__c.SObjectType),
            canCreateObject(White_Space_Row__c.SObjectType),
            canDeleteObject(White_Space_Row__c.SObjectType),
            canUpdateObject(White_Space_Column__c.SObjectType),
            canCreateObject(White_Space_Column__c.SObjectType),
            canDeleteObject(White_Space_Column__c.SObjectType),
            canUpdateObject(White_Space_Cell__c.SObjectType),
            canCreateObject(White_Space_Cell__c.SObjectType),
            canDeleteObject(White_Space_Cell__c.SObjectType)
        );
    }

    @AuraEnabled
    public static WS_User_Setting__c getUserSetting(Id whitespaceId) {
        return WSUserSettingService.getUserSetting(whitespaceId);
    }

    @AuraEnabled
    public static void updateUserSetting(WS_User_Setting__c setting) {
        WSUserSettingService.updateUserSetting(new List<WS_User_Setting__c>{ setting });
    }

    @AuraEnabled
    public static void updateZoomIndex(Id settingId, Integer zoomIndex) {
        WSUserSettingService.updateZoomIndex(settingId, zoomIndex);
    }

    @AuraEnabled
    public static FiltersData getFilters(Id whitespaceId) {
        WS_User_Setting__c userSetting = WSUserSettingService.getUserSetting(whitespaceId);
        FiltersData filtersData = new FiltersData(userSetting);
        return filtersData;
    }

    @AuraEnabled
    public static void updateFilters(FiltersData filtersData) {
        WSUserSettingService.updateUserSetting(new List<WS_User_Setting__c>{ filtersData.unwrap() });
    }

    @AuraEnabled
    public static WhiteSpaceAbstract createWhiteSpace(
        Id accountPlanId,
        String name,
        List<String> rowNames,
        List<String> columnNames
    ) {
        White_Space__c whiteSpace = WhiteSpaceService.createWhiteSpaceForAccountPlanId(accountPlanId, name);
        Application.bypassTrigger = true;
        Set<Id> wsRows = (new Map<Id, White_Space_Row__c>(
                WhiteSpaceService.createWhiteSpaceRows(whiteSpace.Id, rowNames)
            ))
            .keySet();
        Set<Id> wsColumns = (new Map<Id, White_Space_Column__c>(
                WhiteSpaceService.createWhiteSpaceColumns(whiteSpace.Id, columnNames)
            ))
            .keySet();
        WhiteSpaceService.createWhiteSpaceCells(whiteSpace.id, wsColumns, wsRows, null);

        Application.bypassTrigger = false;
        return getWhiteSpaceForAccountPlan(accountPlanId);
    }

    @AuraEnabled
    public static WhiteSpaceAbstract createWhiteSpaceFromTemplate(White_Space__c ws) {
        WhiteSpaceService.createWhiteSpace(ws);
        Application.bypassTrigger = true;
        WhiteSpaceAbstract newWS = getWhiteSpaceForAccountPlan(ws.pqcrush__Account_Plan__c);
        Application.bypassTrigger = false;
        return newWS;
    }

    @AuraEnabled
    public static void deleteWhiteSpace(Id whiteSpaceId) {
        WhiteSpaceService.deleteWhiteSpace(whiteSpaceId);
    }

    @AuraEnabled
    public static WhiteSpaceAbstract undeleteWhiteSpace(Id whiteSpaceId) {
        WhiteSpaceService.undeleteWhiteSpace(whiteSpaceId);
        White_Space__c whiteSpaceInfo = WhiteSpaceSelector.newInstance().selectById(whiteSpaceId);

        WhiteSpaceFactory factory = new WhiteSpaceFactory();
        WhiteSpaceAbstract wrapper = null;
        if (whiteSpaceInfo != null) {
            wrapper = factory.makeWhiteSpaceAbstract(whiteSpaceInfo, whiteSpaceInfo.White_Space_Template__r);
        }
        return wrapper;
    }

    @AuraEnabled
    public static WhiteSpaceAbstract getWhiteSpaceForAccountPlan(Id accountPlanId) {
        Application.bypassTrigger = true;

        White_Space__c whiteSpaceInfo = WhiteSpaceSelector.newInstance()
            .selectFirstWithGridDataByAccountPlanId(accountPlanId);

        WhiteSpaceFactory factory = new WhiteSpaceFactory();
        WhiteSpaceAbstract wrapper = null;
        if (whiteSpaceInfo != null) {
            White_Space_Template__c template = whiteSpaceInfo.White_Space_Template__r;
            wrapper = factory.makeWhiteSpaceAbstract(whiteSpaceInfo, template);
        }
        Application.bypassTrigger = false;
        return wrapper;
    }

    @AuraEnabled
    public static List<Id> getFirstWhiteSpaceIdForAccountPlan(Id accountPlanId) {
        List<Id> whiteSpaceId = new List<Id>();
        List<White_Space__c> whiteSpace = WhiteSpaceSelector.newInstance().selectFirstByAccountPlanId(accountPlanId);
        if (whiteSpace != null) {
            for (White_Space__c ws : whiteSpace) {
                whiteSpaceId.add(ws.Id);
            }
        }
        return whiteSpaceId;
    }

    @AuraEnabled
    public static Map<String, Object> getWhiteSpace(Id whiteSpaceId) {
        Application.bypassTrigger = true;

        White_Space__c whiteSpaceInfo = WhiteSpaceSelector.newInstance().selectById(whiteSpaceId);

        WhiteSpaceFactory factory = new WhiteSpaceFactory();
        WhiteSpaceAbstract wrapper = null;
        if (whiteSpaceInfo != null) {
            wrapper = factory.makeWhiteSpaceAbstract(whiteSpaceInfo, whiteSpaceInfo.White_Space_Template__r);
        }
        Application.bypassTrigger = false;

        WhiteSpaceObjectAccess permissions = getWhiteSpaceObjectAccessForAccountPlan(whiteSpaceInfo.Account_Plan__c);

        Map<String, Object> result = new Map<String, Object>();
        result.put('whiteSpace', wrapper);
        result.put('permissions', permissions);
        return result;
    }

    @AuraEnabled
    public static WhiteSpaceTileWrapper updateWhiteSpaceTile(WhiteSpaceTileWrapper wrapper, Id whiteSpaceId) {
        White_Space_Cell__c unwrappedCell = wrapper.toSObjectCell();
        unwrappedCell = WhiteSpaceService.updateWhiteSpaceCell(unwrappedCell);

        List<White_Space_Amount_Type_Association__c> allAssociations = new List<White_Space_Amount_Type_Association__c>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (WhiteSpaceDisplayFieldWrapper displayFieldWrapper : wrapper.displayFields) {
            if (
                displayFieldWrapper.id != null &&
                displayFieldWrapper.isEditable &&
                displayFieldWrapper.fieldType == 'amountType'
            ) {
                Id amountTypeId = displayFieldWrapper.id;
                Id cellId = wrapper.id;
                for (WhiteSpaceDisplayFieldDataWrapper dataWrapper : displayFieldWrapper.data) {
                    White_Space_Amount_Type_Association__c dataObject = dataWrapper.toAssociationWithDisplayFieldId(
                        amountTypeId,
                        cellId
                    );
                    if (dataObject == null) {
                        continue;
                    }
                    if (dataObject.Id == null) {
                        uow.registerNew(dataObject);
                        allAssociations.add(dataObject);
                    } else {
                        uow.registerDirty(dataObject);
                        allAssociations.add(dataObject);
                    }
                }
            }
        }
        uow.commitWork();

        WhiteSpaceTileWrapper tileWrapper = getTileWrapper(wrapper.id, whiteSpaceId);
        if (tileWrapper != null) {
            return tileWrapper;
        }

        List<White_Space_Amount_Type__c> amountTypes = WhiteSpaceAmountTypeSelector.newInstance().selectAll();
        List<WS_Data_Type__c> dataTypes = WSDataTypeSelector.newInstance()
            .selectByWhiteSpaceId(unwrappedCell.White_Space__c);
        List<WSRelatedObjectWrapper> relatedObjects = WhiteSpaceUtils.getWSRelatedObjectWrappers();
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields = new List<WhiteSpaceTemplateCellFieldWrapper>();
        Map<String, List<SObject>> relatedData = new Map<String, List<SObject>>();
        for (WSRelatedObjectWrapper relWrapper : relatedObjects) {
            WhiteSpaceTemplateCellFieldWrapper cellFieldWrapper = new WhiteSpaceTemplateCellFieldWrapper(
                relWrapper,
                true
            );
            Query queryBuilder = cellFieldWrapper.getQueryBuilder(
                null,
                null,
                new Set<String>{ wrapper.id },
                null,
                false
            );
            List<SObject> data = queryBuilder != null ? queryBuilder.run() : new List<SObject>();
            relatedData.put(cellFieldWrapper.id, data);
            relatedFields.add(cellFieldWrapper);
        }
        WhiteSpaceTileWrapper updatedWrapper = WhiteSpaceTileWrapper.createFor(
            unwrappedCell,
            amountTypes,
            dataTypes,
            relatedData,
            allAssociations,
            relatedFields,
            relatedObjects
        );
        return updatedWrapper;
    }

    @AuraEnabled
    public static WhiteSpaceTileWrapper createWhiteSpaceTile(Id columnId, Id rowId, Id whiteSpaceId) {
        White_Space_Cell__c newCell = WhiteSpaceService.addNewWhitespaceCell(whiteSpaceId, columnId, rowId);
        List<White_Space_Amount_Type__c> amountTypes = WhiteSpaceAmountTypeSelector.newInstance().selectAll();
        List<WS_Data_Type__c> dataTypes = WSDataTypeSelector.newInstance().selectByWhiteSpaceId(whiteSpaceId);
        List<WSRelatedObjectWrapper> relatedObjects = WhiteSpaceUtils.getWSRelatedObjectWrappers();
        List<WhiteSpaceTemplateCellFieldWrapper> relatedFields = new List<WhiteSpaceTemplateCellFieldWrapper>();
        for (WSRelatedObjectWrapper wrapper : relatedObjects) {
            WhiteSpaceTemplateCellFieldWrapper cellFieldWrapper = new WhiteSpaceTemplateCellFieldWrapper(wrapper, true);
            relatedFields.add(cellFieldWrapper);
        }
        Map<String, List<SObject>> relatedData = new Map<String, List<SObject>>(); //New tile would not have any related object data yet
        return WhiteSpaceTileWrapper.createFor(
            newCell,
            amountTypes,
            dataTypes,
            relatedData,
            newCell.White_Space_Amount_Type_Associations__r,
            relatedFields,
            relatedObjects
        );
    }

    @AuraEnabled
    public static void deleteWhiteSpaceTile(Id tileId) {
        White_Space_Cell__c cell = new White_Space_Cell__c(Id = tileId);
        WhiteSpaceService.deleteWhitespaceCells(new List<White_Space_Cell__c>{ cell });
    }

    @AuraEnabled
    public static WhiteSpaceAbstract updateWhiteSpaceRowsAndColumns(Id whiteSpaceId, String wsRows, String wsColumns) {
        List<White_Space_Row__c> rows = (List<White_Space_Row__c>) JSON.deserialize(
            wsRows,
            List<White_Space_Row__c>.class
        );
        List<White_Space_Column__c> columns = (List<White_Space_Column__c>) JSON.deserialize(
            wsColumns,
            List<White_Space_Column__c>.class
        );
        WhiteSpaceService.updateWhiteSpaceRows(whiteSpaceId, rows);
        WhiteSpaceService.updateWhiteSpaceColumns(whiteSpaceId, columns);

        White_Space__c whiteSpaceInfo = WhiteSpaceSelector.newInstance().selectById(whiteSpaceId);

        WhiteSpaceFactory factory = new WhiteSpaceFactory();
        WhiteSpaceAbstract wrapper = null;
        if (whiteSpaceInfo != null) {
            wrapper = factory.makeWhiteSpaceAbstract(whiteSpaceInfo, whiteSpaceInfo.White_Space_Template__r);
        }
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static List<WS_Highlight__c> getHighlights(Id whiteSpaceId) {
        return WhiteSpaceHighlightService.getHighlightsForWhiteSpace(whiteSpaceId);
    }

    @AuraEnabled
    public static WS_Highlight__c setHighlight(Id cellId, Id highlightId) {
        List<White_Space_Cell__c> cell = WhiteSpaceCellSelector.newInstance().selectById(new Set<Id>{ cellId });

        if (cell == null || cell.isEmpty()) {
            throw new AuraHandledException('Unable to to locate data to update.');
        }
        White_Space_Cell__c cellRecord = cell[0];
        List<WS_Highlight__c> highlight = new List<WS_Highlight__c>();

        if (highlightId != null) {
            highlight = WSHighlightSelector.newInstance().selectById(new Set<Id>{ highlightId });
            if (highlight == null || highlight.isEmpty()) {
                highlightId = null;
            }
        }
        if (highlightId != null) {
        cellRecord.Highlight__c = highlightId;
        } else {
        cellRecord.Highlight__c = null;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(cellRecord);
        uow.commitWork();
        if (highlight != null && !highlight.isEmpty()) {
            return highlight[0];
        }

        return null;
    }

    @AuraEnabled
    public static List<WS_Summary_Formula__c> getSummaryFormulas(Id whiteSpaceId) {
        return WSSummaryFormulaService.getSummaryFormulas(whiteSpaceId);
    }

    //-----------------------------
    //    DATA TYPE METHODS
    //-----------------------------

    @AuraEnabled
    public static List<WS_Data_Type__c> getDataTypes(Id whiteSpaceId) {
        return WSDataTypeService.getDataTypes(whiteSpaceId);
    }

    @AuraEnabled
    public static Id saveDataForCell(Id cellId, Id dataTypeId, String value) {
        return WSDataTypeService.saveDataForCell(cellId, dataTypeId, value);
    }

    @AuraEnabled
    public static List<WS_Data_Type_Association__c> getDataTypeDataForCell(Id cellId) {
        return WSDataTypeService.getDataTypeDataForCell(cellId);
    }

    /******************************
     *      PRIVATE METHODS
     ******************************/

    private static WhiteSpaceTileWrapper getTileWrapper(Id tileId, Id whiteSpaceId) {
        if (whiteSpaceId == null || tileId == null) {
            return null;
        }
        WhiteSpaceAbstract wsw = (WhiteSpaceAbstract) getWhiteSpace(whiteSpaceId).get('whiteSpace');
        if (wsw?.cells == null) {
            return null;
        }
        for (WhiteSpaceCellWrapper cellWrapper : wsw.cells) {
            for (WhiteSpaceTileWrapper tileWrapper : cellWrapper.tiles) {
                if (tileWrapper.id == tileId) {
                    return tileWrapper;
                }
            }
        }
        return null;
    }

    /* CHECK PERMISSION FOR WHITE SPACE   */
    private static Boolean canCreateObject(SObjectType objType) {
        try {
            fflib_SecurityUtils.checkObjectIsInsertable(objType);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private static Boolean canUpdateObject(SObjectType objType) {
        try {
            fflib_SecurityUtils.checkObjectIsUpdateable(objType);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private static Boolean canDeleteObject(SObjectType objType) {
        try {
            fflib_SecurityUtils.checkObjectIsDeletable(objType);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}