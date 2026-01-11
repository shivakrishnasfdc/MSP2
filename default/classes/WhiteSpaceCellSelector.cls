public with sharing class WhiteSpaceCellSelector extends fflib_SObjectSelector {
    public static WhiteSpaceCellSelector newInstance() {
        return (WhiteSpaceCellSelector) Application.Selector.newInstance(White_Space_Cell__c.SObjectType);
    }

    /******************************
     *    QUERY CONFIGURATION
     ******************************/

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            White_Space_Cell__c.Id,
            White_Space_Cell__c.Name,
            White_Space_Cell__c.CreatedDate,
            White_Space_Cell__c.White_Space__c,
            White_Space_Cell__c.White_Space_Column__c,
            White_Space_Cell__c.White_Space_Row__c,
            White_Space_Cell__c.Info__c,
            White_Space_Cell__c.Primary_Amount_Type__c,
            White_Space_Cell__c.Highlight__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return White_Space_Cell__c.sObjectType;
    }

    public override String getOrderBy() {
        return White_Space_Cell__c.CreatedDate.getDescribe().getName() + ' ASC';
    }

    /******************************
     *        SELECT METHODS
     ******************************/

    public List<White_Space_Cell__c> selectById(Set<ID> idSet) {
        return (List<White_Space_Cell__c>) selectSObjectsById(idSet);
    }

    public List<White_Space_Cell__c> selectByRowId(Set<Id> rowIds) {
        return Database.query(newQueryFactory().setCondition('White_Space_Row__c IN :rowIds').toSOQL());
    }

    public List<White_Space_Cell__c> selectByColumnId(Set<Id> columnIds) {
        return Database.query(newQueryFactory().setCondition('White_Space_Column__c IN :columnIds').toSOQL());
    }

    public List<White_Space_Cell__c> selectByWhiteSpaceIdWithAmountTypeAssociations(Id wsId) {
        fflib_QueryFactory query = newQueryFactory();

        new WhiteSpaceAmountTypeSelector()
            .configureQueryFactoryFields(
                query,
                White_Space_Cell__c.Primary_Amount_Type__c.getDescribe().getRelationshipName()
            );

        new WSHighlightSelector()
            .configureQueryFactoryFields(query, White_Space_Cell__c.Highlight__c.getDescribe().getRelationshipName());

        fflib_QueryFactory associationsQueryFactory = new WhiteSpaceAmountTypeAssociationSelector()
            .addQueryFactorySubselect(query);

        new WhiteSpaceAmountTypeSelector()
            .configureQueryFactoryFields(
                associationsQueryFactory,
                White_Space_Amount_Type_Association__c.White_Space_Amount_Type__c.getDescribe().getRelationshipName()
            );

        // ADD DATA TYPE TO QUERY
        fflib_QueryFactory dataTypeAssociationsQueryFactory = new WSDataTypeAssociationSelector()
            .addQueryFactorySubselect(query);

        new WSDataTypeSelector()
            .configureQueryFactoryFields(
                dataTypeAssociationsQueryFactory,
                WS_Data_Type_Association__c.WS_Data_Type__c.getDescribe().getRelationshipName()
            );

        return Database.query(
            query
                .selectField('Highlight__r.Id')
                .selectField('Highlight__r.Color__c')
                .selectField('Highlight__r.Label__c')
                .setCondition('White_Space__c = :wsId')
                .toSOQL()
        );
    }
}