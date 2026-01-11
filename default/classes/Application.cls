@SuppressWarnings('PMD.FieldNamingConventions,PMD.PropertyNamingConventions,PMD.ExcessivePublicCount')
public with sharing class Application {
    private static Map<String, Schema.SObjectType> gd = null;

    public static Boolean bypassTrigger = false;

    public static Boolean bypassPlanReopen = false;

    public static final PQUnitOfWorkFactory UnitOfWork {
        get {
            if (UnitOfWork == null) {
                UnitOfWork = new PQUnitOfWorkFactory(
                    new List<SObjectType>{
                        Account_Plan__Share.SObjectType,
                        Account_Plan__c.SObjectType,
                        Contact.SObjectType,
                        Contact_Extended_Field__c.SObjectType,
                        Contact_Relationship__c.SObjectType,
                        CRUSH_Settings__c.SObjectType,
                        CRUSH_Settings_Obj__c.SObjectType,
                        Key_Stakeholder__c.SObjectType,
                        Key_Stakeholder_Lead__c.SObjectType,
                        Map_Member_Lead__c.SObjectType,
                        Map_Member_User__c.SObjectType,
                        Map_Member_Placeholder__c.SObjectType,
                        Map_Member_Placeholder_Relationship__c.SObjectType,
                        Master_Account_Plan_User_Setting__c.SObjectType,
                        Objective__c.SObjectType,
                        Objective_Task_Association__c.SObjectType,
                        Org_Chart_Field__c.SObjectType,
                        Opportunity_List_User_Filter__c.SObjectType,
                        Relationship_Map_Member_Auto_History__c.SObjectType,
                        pq_Account_Plan_Score_History__c.SObjectType,
                        pq_CRUSH_Account_Plan_User_Setting__c.SObjectType,
                        pq_CRUSH_Plan_Overview__c.SObjectType,
                        pq_CRUSH_User_Setting__c.SObjectType,
                        pq_Opportunity_Effectiveness_Association__c.SObjectType,
                        pq_Opportunity_Effectiveness_Index__c.SObjectType,
                        pq_Opportunity_Manager_Setting__c.SObjectType,
                        PQ_Opportunity_Plan__c.SObjectType,
                        pqcrush__Account_Plan_Template__c.SObjectType,
                        pqcrush__Template_Section__c.SObjectType,
                        pqcrush__NoteSection__c.SobjectType,
                        Relationship_Group__c.SObjectType,
                        Relationship_Group_Contact_Association__c.SObjectType,
                        Relationship_Group_Lead_Association__c.SObjectType,
                        Relationship_Group_Placeholder_Assoc__c.SObjectType,
                        Relationship_Group_User_Association__c.SObjectType,
                        Relationship_Map__c.SObjectType,
                        Relationship_Map_Member__c.SObjectType,
                        Account_Relationship_Map__c.SObjectType,
                        Account_Map_Member__c.SObjectType,
                        RM_Anchor__c.SObjectType,
                        RM_Chart_Setting__c.SObjectType,
                        RM_Node_Coordinate__c.SObjectType,
                        RM_Svg_Node_Association__c.SObjectType,
                        RM_Org_Setting__c.SObjectType,
                        RM_Svg__c.SObjectType,
                        SWOT_Analysis__c.SObjectType,
                        Task.SObjectType,
                        Team_Member__c.SObjectType,
                        White_Space_Amount_Type_Association__c.SObjectType,
                        White_Space_Amount_Type__c.SObjectType,
                        White_Space__c.SObjectType,
                        White_Space_Column__c.SObjectType,
                        White_Space_Row__c.SObjectType,
                        White_Space_Cell__c.SObjectType,
                        WS_Data_Type_Association__c.SObjectType,
                        pq_Condition__c.SObjectType,
                        WS_User_Setting__c.SObjectType,
                        ContentVersion.SObjectType,
                        ContentDocument.SObjectType
                    }
                );
            }

            return UnitOfWork;
        }
        set;
    }

    // Unit of Work factory to handle post install objects
    public static final PQUnitOfWorkFactory PostInstallUnitOfWork {
        get {
            if (PostInstallUnitOfWork == null) {
                PostInstallUnitOfWork = new PQUnitOfWorkFactory(
                    new List<SObjectType>{ RM_Chart_Setting__c.SObjectType }
                );
            }
            return PostInstallUnitOfWork;
        }
        set;
    }

    // Unit of Work factory to handle Opportunity Plans that install user won't have issues with
    public static final PQUnitOfWorkFactory OpportunityPlanUnitOfWork {
        get {
            if (OpportunityPlanUnitOfWork == null) {
                OpportunityPlanUnitOfWork = new PQUnitOfWorkFactory(
                    new List<SObjectType>{ PQ_Opportunity_Plan__c.SObjectType }
                );
            }
            return OpportunityPlanUnitOfWork;
        }
        set;
    }

    // Unit of Work factory to handle white space templating objects
    public static final PQUnitOfWorkFactory WsTemplateUnitOfWork {
        get {
            if (WsTemplateUnitOfWork == null) {
                WsTemplateUnitOfWork = new PQUnitOfWorkFactory(
                    new List<SObjectType>{
                        Mapping__c.SObjectType,
                        Mapping_Condition_Group__c.SObjectType,
                        Mapping_Condition__c.SObjectType,
                        White_Space_Template__c.SObjectType,
                        White_Space_Template_Cell_Field__c.SObjectType
                    }
                );
            }
            return WsTemplateUnitOfWork;
        }
        set;
    }

    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory Service {
        get {
            if (Service == null) {
                Service = new fflib_Application.ServiceFactory(
                    new Map<Type, Type>{
                        AccountRelationshipMapServiceImpl.class => AccountRelationshipMapServiceImpl.class,
                        AccountContactRelationServiceImpl.class => AccountContactRelationServiceImpl.class,
                        AccountPlanUserSettingServiceImpl.class => AccountPlanUserSettingServiceImpl.class,
                        AccountPlanScoreHistoryServiceImpl.class => AccountPlanScoreHistoryServiceImpl.class,
                        AccountServiceImpl.class => AccountServiceImpl.class,
                        AccountPlanCloneServiceImpl.class => AccountPlanCloneServiceImpl.class,
                        AccountPlanServiceImpl.class => AccountPlanServiceImpl.class,
                        AccountPlanShareServiceImpl.class => AccountPlanShareServiceImpl.class,
                        AccountTeamServiceImpl.class => AccountTeamServiceImpl.class,
                        CloneSharedServiceImpl.class => CloneSharedServiceImpl.class,
                        ContactExtendedFieldServiceImpl.class => ContactExtendedFieldServiceImpl.class,
                        ContactRelationshipServiceImpl.class => ContactRelationshipServiceImpl.class,
                        CrushUserSettingServiceImpl.class => CrushUserSettingServiceImpl.class,
                        CurrencyServiceImpl.class => CurrencyServiceImpl.class,
                        DynamicObjectQueryServiceImpl.class => DynamicObjectQueryServiceImpl.class,
                        GraphDataLeadServiceImpl.class => GraphDataLeadServiceImpl.class,
                        GraphDataServiceImpl.class => GraphDataServiceImpl.class,
                        HealthScoreServiceImpl.class => HealthScoreServiceImpl.class,
                        HierarchyHelperServiceImpl.class => HierarchyHelperServiceImpl.class,
                        InfluenceSupportMatrixServiceImpl.class => InfluenceSupportMatrixServiceImpl.class,
                        KeyStakeholderServiceImpl.class => KeyStakeholderServiceImpl.class,
                        MapMemberLeadServiceImpl.class => MapMemberLeadServiceImpl.class,
                        MapMemberUserServiceImpl.class => MapMemberUserServiceImpl.class,
                        MapMemberPlaceholderServiceImpl.class => MapMemberPlaceholderServiceImpl.class,
                        MasterAccountPlanServiceImpl.class => MasterAccountPlanServiceImpl.class,
                        ObjectiveServiceImpl.class => ObjectiveServiceImpl.class,
                        OpportunityEIBatchServiceImpl.class => OpportunityEIBatchServiceImpl.class,
                        OpportunityEIServiceImpl.class => OpportunityEIServiceImpl.class,
                        OpportunityPlanServiceImpl.class => OpportunityPlanServiceImpl.class,
                        OpportunityScoreHelperServiceImpl.class => OpportunityScoreHelperServiceImpl.class,
                        OpportunityScoreServiceImpl.class => OpportunityScoreServiceImpl.class,
                        PicklistServiceImpl.class => PicklistServiceImpl.class,
                        RMGroupHelperServiceImpl.class => RMGroupHelperServiceImpl.class,
                        RelationshipGroupServiceImpl.class => RelationshipGroupServiceImpl.class,
                        RelationshipLineWrapperServiceImpl.class => RelationshipLineWrapperServiceImpl.class,
                        RelationshipMapCloneServiceImpl.class => RelationshipMapCloneServiceImpl.class,
                        ReportStructureWrapperServiceImpl.class => ReportStructureWrapperServiceImpl.class,
                        RMChartSettingServiceImpl.class => RMChartSettingServiceImpl.class,
                        RMNodeCoordinateServiceImpl.class => RMNodeCoordinateServiceImpl.class,
                        RMOrgSettingServiceImpl.class => RMOrgSettingServiceImpl.class,
                        RMSvgHelperServiceImpl.class => RMSvgHelperServiceImpl.class,
                        RMSvgServiceImpl.class => RMSvgServiceImpl.class,
                        RelationshipMapServiceImpl.class => RelationshipMapServiceImpl.class,
                        SendEmailNotificationsImpl.class => SendEmailNotificationsImpl.class,
                        SettingServiceImpl.class => SettingServiceImpl.class,
                        SObjectServiceImpl.class => SObjectServiceImpl.class,
                        StaticResourceServiceImpl.class => StaticResourceServiceImpl.class,
                        TeamMemberServiceImpl.class => TeamMemberServiceImpl.class,
                        UserRecordAccessServiceImpl.class => UserRecordAccessServiceImpl.class,
                        UtilityForMapImpl.class => UtilityForMapImpl.class,
                        WhiteSpaceHighlightServiceImpl.class => WhiteSpaceHighlightServiceImpl.class,
                        WhiteSpaceServiceImpl.class => WhiteSpaceServiceImpl.class,
                        WhiteSpaceUtilsImpl.class => WhiteSpaceUtilsImpl.class,
                        WSDataTypeServiceImpl.class => WSDataTypeServiceImpl.class,
                        WSSummaryFormulaServiceImpl.class => WSSummaryFormulaServiceImpl.class,
                        PqConditionServiceImpl.class => PqConditionServiceImpl.class,
                        WSUserSettingServiceImpl.class => WSUserSettingServiceImpl.class
                    }
                );
            }

            return Service;
        }
        set;
    }

    // Configure and create the ServiceFactory for the post install process of the Application
    // This is separate from the ServiceFactory above because post install runs under a special user
    // that can hit errors when trying to access the ServiceFactory above.
    public static final fflib_Application.ServiceFactory PostInstallService {
        get {
            if (PostInstallService == null) {
                PostInstallService = new fflib_Application.ServiceFactory(
                    new Map<Type, Type>{ PostInstallHelperServiceImpl.class => PostInstallHelperServiceImpl.class }
                );
            }

            return PostInstallService;
        }
        set;
    }

    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector {
        get {
            if (Selector == null) {
                Selector = new fflib_Application.SelectorFactory(
                    new Map<SObjectType, Type>{
                        Account.SObjectType => AccountSelector.class,
                        Account_Plan__c.SObjectType => AccountPlanSelector.class,
                        Account_Plan_Opportunity__c.SObjectType => AccountPlanOpportunitySelector.class,
                        Account_Plan__Share.SObjectType => AccountPlanSharesSelector.class,
                        Campaign.SObjectType => CampaignSelector.class,
                        CampaignMember.SObjectType => CampaignMemberSelector.class,
                        Cell_Relationship_Configuration__c.SObjectType => WSCellRelationshipConfigSelector.class,
                        Contact.SObjectType => ContactSelector.class,
                        Contact_Extended_Field__c.SObjectType => ContactExtendedFieldSelector.class,
                        Contact_Relationship__c.SObjectType => ContactRelationshipSelector.class,
                        Contact_Relationship_Type__c.SObjectType => ContactRelationshipTypeSelector.class,
                        CRUSH_Settings_Obj__c.SObjectType => CrushSettingsObjSelector.class,
                        CustomPermission.SObjectType => CustomPermissionSelector.class,
                        Document.SObjectType => DocumentSelector.class,
                        EmailTemplate.SObjectType => EmailTemplatesSelector.class,
                        Event.SObjectType => EventSelector.class,
                        Key_Date__c.SObjectType => KeyDateSelector.class,
                        Key_Stakeholder__c.SObjectType => KeyStakeholderSelector.class,
                        Key_Stakeholder_Lead__c.SObjectType => KeyStakeholderLeadSelector.class,
                        Lead.SObjectType => LeadSelector.class,
                        Map_Member_Lead__c.SObjectType => MapMemberLeadSelector.class,
                        Map_Member_User__c.SObjectType => MapMemberUserSelector.class,
                        Map_Member_Placeholder__c.SObjectType => MapMemberPlaceholderSelector.class,
                        Map_Member_Placeholder_Relationship__c.SObjectType => MapMemberPlaceholderRelationshipSelector.class,
                        Objective__c.SObjectType => ObjectiveSelector.class,
                        Objective_Task_Association__c.SObjectType => ObjectiveTaskAssociationSelector.class,
                        PQ_AP_Score__mdt.SObjectType => HealthScoreMetadataSelector.class,
                        Relationship_Map__c.SObjectType => RelationshipMapSelector.class,
                        Relationship_Map_Member__c.SObjectType => RelationshipMapMemberSelector.class,
                        Account_Relationship_Map__c.SObjectType => AccountRelationshipMapSelector.class,
                        Account_Map_Member__c.SObjectType => AccountRelationshipMapMemberSelector.class,
                        Mapping__c.SObjectType => MappingSelector.class,
                        Mapping_Condition_Group__c.SObjectType => MappingConditionGroupSelector.class,
                        Mapping_Condition__c.SObjectType => MappingConditionSelector.class,
                        Master_Account_Plan_Associations__c.SObjectType => MasterAccountPlanAssociationSelector.class,
                        Master_Account_Plan_User_Setting__c.SObjectType => MasterAccountPlanUserSettingSelector.class,
                        Objective__c.SObjectType => ObjectiveSelector.class,
                        Objective_Opportunity__c.SObjectType => ObjectiveOpportunitySelector.class,
                        Opportunity.SObjectType => OpportunitySelector.class,
                        Opportunity_List_User_Filter__c.SObjectType => OpportunityListUserFilterSelector.class,
                        Relationship_Map_Member_Auto_History__c.SObjectType => RMMAutoHistorySelector.class,
                        OpportunityContactRole.SObjectType => OpportunityContactRoleSelector.class,
                        Org_Chart_Field__c.SObjectType => OrgChartFieldSelector.class,
                        Organization.SObjectType => OrganizationSelector.class,
                        pq_CRUSH_Plan_Overview__c.SObjectType => PlanOverviewSelector.class,
                        pq_Account_Plan_Matrix_Association__c.SObjectType => AccountPlanMatrixAssociationSelector.class,
                        pq_Account_Plan_Score_History__c.SObjectType => AccountPlanScoreHistorySelector.class,
                        pq_Crush_User_Setting__c.SObjectType => CrushUserSettingSelector.class,
                        pq_CRUSH_Account_Plan_User_Setting__c.SObjectType => AccountPlanUserSettingSelector.class,
                        pq_Influence__c.SObjectType => InfluenceSelector.class,
                        pq_Influence_Matrix_Association__c.SObjectType => InfluenceMatrixAssociationSelector.class,
                        pq_Influence_And_Support_Matrix__c.SObjectType => InfluenceSupportMatrixSelector.class,
                        pq_Master_Account_Plan__c.SObjectType => MasterAccountPlanSelector.class,
                        pq_Opportunity_Effectiveness_Index__c.SObjectType => OpportunityEffectivenessIndexSelector.class,
                        pq_Opportunity_Effectiveness_Association__c.SObjectType => OpportunityEIAssociationSelector.class,
                        pq_Opportunity_Manager_Setting__c.SObjectType => OpportunityManagerSettingSelector.class,
                        PQ_Opportunity_Plan__c.SObjectType => OpportunityPlanSelector.class,
                        pq_Relationship_Map_Matrix_Association__c.SObjectType => RMMatrixAssociationSelector.class,
                        pq_Support__c.SObjectType => SupportSelector.class,
                        pq_Support_Matrix_Association__c.SObjectType => SupportMatrixAssociationSelector.class,
                        Relationship_Group__c.SObjectType => RelationshipGroupSelector.class,
                        Relationship_Group_Contact_Association__c.SObjectType => RelationshipGroupContactSelector.class,
                        Relationship_Group_Lead_Association__c.SObjectType => RelationshipGroupLeadSelector.class,
                        Relationship_Group_Placeholder_Assoc__c.SObjectType => RelationshipGroupPlaceholderSelector.class,
                        Relationship_Group_User_Association__c.SObjectType => RelationshipGroupUserSelector.class,
                        RM_Anchor__c.SObjectType => RMAnchorSelector.class,
                        RM_Chart_Setting__c.SObjectType => RMChartSettingSelector.class,
                        RM_Node_Coordinate__c.SObjectType => RMNodeCoordinateSelector.class,
                        RM_Org_Setting__c.SObjectType => RMOrgSettingSelector.class,
                        RM_Svg__c.SObjectType => RMSvgSelector.class,
                        RM_Svg_Node_Association__c.SObjectType => RMSvgNodeAssociationSelector.class,
                        SetupEntityAccess.SObjectType => SetupEntityAccessSelector.class,
                        StaticResource.SObjectType => StaticResourcesSelector.class,
                        SWOT_Analysis__c.SObjectType => SWOTAnalysisSelector.class,
                        Task.SObjectType => TasksSelector.class,
                        TaskStatus.SObjectType => TaskStatusSelector.class,
                        Team_Member__c.SObjectType => TeamMemberSelector.class,
                        User.SObjectType => UsersSelector.class,
                        UserRecordAccess.SObjectType => UserRecordAccessSelector.class,
                        White_Space__c.SObjectType => WhiteSpaceSelector.class,
                        White_Space_Cell__c.SObjectType => WhiteSpaceCellSelector.class,
                        White_Space_Column__c.SObjectType => WhiteSpaceColumnSelector.class,
                        White_Space_Highlight_Association__c.SObjectType => WSHighlightAssociationSelector.class,
                        White_Space_Row__c.SObjectType => WhiteSpaceRowSelector.class,
                        White_Space_Amount_Type__c.SObjectType => WhiteSpaceAmountTypeSelector.class,
                        White_Space_Amount_Type_Association__c.SObjectType => WhiteSpaceAmountTypeAssociationSelector.class,
                        White_Space_Template__c.SObjectType => WhiteSpaceTemplateSelector.class,
                        White_Space_Template_Cell_Field__c.SObjectType => WhiteSpaceTemplateCellFieldSelector.class,
                        WS_Data_Type__c.SObjectType => WSDataTypeSelector.class,
                        WS_Data_Type_Association__c.SObjectType => WSDataTypeAssociationSelector.class,
                        WS_Highlight__c.SObjectType => WSHighlightSelector.class,
                        WS_Summary_Formula__c.SObjectType => WSSummaryFormulaSelector.class,
                        pq_Condition__c.SObjectType => PqConditionSelector.class,
                        WS_User_Setting__c.SObjectType => WSUserSettingSelector.class,
                        ContentVersion.SObjectType => ContentVersionSelector.class
                    }
                );
            }
            return Selector;
        }
        set;
    }

    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain {
        get {
            if (Domain == null) {
                Domain = new fflib_Application.DomainFactory(
                    Application.Selector,
                    new Map<SObjectType, Type>{
                        Account_Plan__c.SObjectType => AccountPlans.Constructor.class,
                        Account_Plan_Opportunity__c.SObjectType => AccountPlanOpportunities.Constructor.class,
                        Account_Plan__Share.SObjectType => AccountPlanShares.Constructor.class,
                        Contact.SObjectType => Contacts.Constructor.class,
                        Key_Date__c.SObjectType => KeyDates.Constructor.class,
                        Key_Stakeholder__c.SObjectType => KeyStakeholders.Constructor.class,
                        Map_Member_User__c.SObjectType => MapMemberUsers.Constructor.class,
                        Relationship_Map_Member__c.SObjectType => RelationshipMapMembers.Constructor.class,
                        Objective__c.SObjectType => Objectives.Constructor.class,
                        Objective_Opportunity__c.SObjectType => ObjectiveOpportunities.Constructor.class,
                        SWOT_Analysis__c.SObjectType => SWOTAnalysis.Constructor.class,
                        Task.SObjectType => Tasks.Constructor.class,
                        Team_Member__c.SObjectType => TeamMembers.Constructor.class,
                        White_Space_Cell__c.SObjectType => WhiteSpaceCells.class,
                        White_Space_Column__c.SObjectType => WhiteSpaceColumns.class,
                        White_Space_Row__c.SObjectType => WhiteSpaceRows.class,
                        White_Space__c.SObjectType => WhiteSpaces.Constructor.class
                    }
                );
            }
            return Domain;
        }
        set;
    }

    public static Map<String, Schema.SObjectType> getGlobalDescribe() {
        if (gd == null) {
            gd = Schema.getGlobalDescribe();
        }
        return gd;
    }

    /**
     * exposes custome ACE permissions in an easy to access way
     */
    public static final PermissionsFactory Permissions = new PermissionsFactory(Account_Plan__c.SObjectType); //NOPMD

    public class PermissionsFactory extends CustomPermissionsReader {
        public PermissionsFactory(SObjectType managedObject) {
            super(managedObject);
        }
        public Boolean customSettings {
            get {
                return hasPermission('Crush_Settings_Permission');
            }
        }
    }

    public static Exception genericException(String message) {
        return new fflib_Application.ApplicationException(message);
    }

    public static AuraHandledException createAuraHandledException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    /**
     * Utility method to throw Application exceptions to Lightning Components
     **/
    public static void throwAuraHandledException(Exception e) {
        AuraHandledException error = createAuraHandledException(e.getMessage());
        throw error;
    }

    /**
     * check for chatter without triggering package to require chatter and works in managed package
     */
    public static Boolean isChatterEnabled() {
        return ConnectApi.Organization.getSettings().features.chatter;
    }
}