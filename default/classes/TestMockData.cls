@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields,PMD.NcssTypeCount')
@isTest
public with sharing class TestMockData {
    /******************************
     *       MOCK IDS
     ******************************/

    public Id mockAccountPlanId {
        get {
            if (mockAccountPlanId == null) {
                mockAccountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
            }
            return mockAccountPlanId;
        }
        set;
    }

    public Id mockAccountId {
        get {
            if (mockAccountId == null) {
                mockAccountId = fflib_IDGenerator.generate(Account.SObjectType);
            }
            return mockAccountId;
        }
        set;
    }

    public Id mockTaskId {
        get {
            if (mockTaskId == null) {
                mockTaskId = fflib_IDGenerator.generate(Task.SObjectType);
            }
            return mockTaskId;
        }
        set;
    }

    public Id mockUserId {
        get {
            if (mockUserId == null) {
                mockUserId = fflib_IDGenerator.generate(User.SObjectType);
            }
            return mockUserId;
        }
        set;
    }

    public Id mockProfileId {
        get {
            if (mockProfileId == null) {
                mockProfileId = fflib_IDGenerator.generate(Profile.SObjectType);
            }
            return mockProfileId;
        }
        set;
    }

    public Id mockParentContactId {
        get {
            if (mockParentContactId == null) {
                mockParentContactId = fflib_IDGenerator.generate(Contact.SObjectType);
            }
            return mockParentContactId;
        }
        set;
    }

    public Id mockContactId {
        get {
            if (mockContactId == null) {
                mockContactId = fflib_IDGenerator.generate(Contact.SObjectType);
            }
            return mockContactId;
        }
        set;
    }

    public Id mockContactWithAccountId {
        get {
            if (mockContactWithAccountId == null) {
                mockContactWithAccountId = fflib_IDGenerator.generate(Contact.SObjectType);
            }
            return mockContactWithAccountId;
        }
        set;
    }

    public Id mockWhiteSpaceId {
        get {
            if (mockWhiteSpaceId == null) {
                mockWhiteSpaceId = fflib_IDGenerator.generate(White_Space__c.SObjectType);
            }
            return mockWhiteSpaceId;
        }
        set;
    }

    public Id mockWhiteSpaceRowId {
        get {
            if (mockWhiteSpaceRowId == null) {
                mockWhiteSpaceRowId = fflib_IDGenerator.generate(White_Space_Row__c.SObjectType);
            }
            return mockWhiteSpaceRowId;
        }
        set;
    }

    public Id mockWhiteSpaceColumnId {
        get {
            if (mockWhiteSpaceColumnId == null) {
                mockWhiteSpaceColumnId = fflib_IDGenerator.generate(White_Space_Column__c.SObjectType);
            }
            return mockWhiteSpaceColumnId;
        }
        set;
    }

    public Id mockWhiteSpaceCellId {
        get {
            if (mockWhiteSpaceCellId == null) {
                mockWhiteSpaceCellId = fflib_IDGenerator.generate(White_Space_Cell__c.SObjectType);
            }
            return mockWhiteSpaceCellId;
        }
        set;
    }

    public Id mockWhiteSpaceAmountTypeId {
        get {
            if (mockWhiteSpaceAmountTypeId == null) {
                mockWhiteSpaceAmountTypeId = fflib_IDGenerator.generate(White_Space_Amount_Type__c.SObjectType);
            }
            return mockWhiteSpaceAmountTypeId;
        }
        set;
    }

    public Id mockWhiteSpaceAmountTypeAssociationId {
        get {
            if (mockWhiteSpaceAmountTypeAssociationId == null) {
                mockWhiteSpaceAmountTypeAssociationId = fflib_IDGenerator.generate(
                    White_Space_AMount_Type_Association__c.SObjectType
                );
            }
            return mockWhiteSpaceAmountTypeAssociationId;
        }
        set;
    }

    public Id mockObjectiveId {
        get {
            if (mockObjectiveId == null) {
                mockObjectiveId = fflib_IDGenerator.generate(Objective__c.SObjectType);
            }
            return mockObjectiveId;
        }
        set;
    }

    public Id mockOpportunityId {
        get {
            if (mockOpportunityId == null) {
                mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
            }
            return mockOpportunityId;
        }
        set;
    }

    public Id mockProductId {
        get {
            if (mockProductId == null) {
                mockProductId = fflib_IDGenerator.generate(Product2.SObjectType);
            }
            return mockProductId;
        }
        set;
    }

    public Id mockOppLineItemId {
        get {
            if (mockOppLineItemId == null) {
                mockOppLineItemId = fflib_IDGenerator.generate(OpportunityLineItem.SObjectType);
            }
            return mockOppLineItemId;
        }
        set;
    }

    public Id mockObjectiveOpportunityId {
        get {
            if (mockObjectiveOpportunityId == null) {
                mockObjectiveOpportunityId = fflib_IDGenerator.generate(Objective_Opportunity__c.SObjectType);
            }
            return mockObjectiveOpportunityId;
        }
        set;
    }

    public Id mockTeamMemberId {
        get {
            if (mockTeamMemberId == null) {
                mockTeamMemberId = fflib_IDGenerator.generate(Team_Member__c.SObjectType);
            }
            return mockTeamMemberId;
        }
        set;
    }

    public Id mockWhiteSpaceTemplateId {
        get {
            if (mockWhiteSpaceTemplateId == null) {
                mockWhiteSpaceTemplateId = fflib_IDGenerator.generate(White_Space_Template__c.SObjectType);
            }
            return mockWhiteSpaceTemplateId;
        }
        set;
    }

    public Id mockLegacyWhiteSpaceTemplateId {
        get {
            if (mockLegacyWhiteSpaceTemplateId == null) {
                mockLegacyWhiteSpaceTemplateId = fflib_IDGenerator.generate(White_Space_Template__c.SObjectType);
            }
            return mockLegacyWhiteSpaceTemplateId;
        }
        set;
    }

    public Id mockCellFieldId {
        get {
            if (mockCellFieldId == null) {
                mockCellFieldId = fflib_IDGenerator.generate(White_Space_Template_Cell_Field__c.SObjectType);
            }
            return mockCellFieldId;
        }
        set;
    }

    public Id mockBasicCellFieldId {
        get {
            if (mockBasicCellFieldId == null) {
                mockBasicCellFieldId = fflib_IDGenerator.generate(White_Space_Template_Cell_Field__c.SObjectType);
            }
            return mockBasicCellFieldId;
        }
        set;
    }

    public Id mockOppMappingId {
        get {
            if (mockOppMappingId == null) {
                mockOppMappingId = fflib_IDGenerator.generate(Mapping__c.SObjectType);
            }
            return mockOppMappingId;
        }
        set;
    }

    public Id mockProductMappingId {
        get {
            if (mockProductMappingId == null) {
                mockProductMappingId = fflib_IDGenerator.generate(Mapping__c.SObjectType);
            }
            return mockProductMappingId;
        }
        set;
    }

    public Id mockAccountMappingId {
        get {
            if (mockAccountMappingId == null) {
                mockAccountMappingId = fflib_IDGenerator.generate(Mapping__c.SObjectType);
            }
            return mockAccountMappingId;
        }
        set;
    }

    public Id mockAssetMappingId {
        get {
            if (mockAssetMappingId == null) {
                mockAssetMappingId = fflib_IDGenerator.generate(Mapping__c.SObjectType);
            }
            return mockAssetMappingId;
        }
        set;
    }

    public Id mockAssetId {
        get {
            if (mockAssetId == null) {
                mockAssetId = fflib_IDGenerator.generate(Asset.SObjectType);
            }
            return mockAssetId;
        }
        set;
    }

    public Id mockSettingsId {
        get {
            if (mockSettingsId == null) {
                mockSettingsId = fflib_IDGenerator.generate(CRUSH_Settings_Obj__c.SObjectType);
            }
            return mockSettingsId;
        }
        set;
    }

    public Id mockKeyStakeholderId {
        get {
            if (mockKeyStakeholderId == null) {
                mockKeyStakeholderId = fflib_IDGenerator.generate(pqcrush__Key_Stakeholder__c.SObjectType);
            }
            return mockKeyStakeholderId;
        }
        set;
    }

    public Id mockRelationshipMapId {
        get {
            if (mockRelationshipMapId == null) {
                mockRelationshipMapId = fflib_IDGenerator.generate(pqcrush__Relationship_Map__c.SObjectType);
            }
            return mockRelationshipMapId;
        }
        set;
    }

    public Id mockRelationshipMapMemberId {
        get {
            if (mockRelationshipMapMemberId == null) {
                mockRelationshipMapMemberId = fflib_IDGenerator.generate(
                    pqcrush__Relationship_Map_Member__c.SObjectType
                );
            }
            return mockRelationshipMapMemberId;
        }
        set;
    }

    public Id mockRelationshipGroupId {
        get {
            if (mockRelationshipGroupId == null) {
                mockRelationshipGroupId = fflib_IDGenerator.generate(pqcrush__Relationship_Group__c.SObjectType);
            }
            return mockRelationshipGroupId;
        }
        set;
    }

    public Id mockRelationshipGroupParentId {
        get {
            if (mockRelationshipGroupParentId == null) {
                mockRelationshipGroupParentId = fflib_IDGenerator.generate(pqcrush__Relationship_Group__c.SObjectType);
            }
            return mockRelationshipGroupParentId;
        }
        set;
    }

    public Id mockRelationshipGroupContactAssociationId {
        get {
            if (mockRelationshipGroupContactAssociationId == null) {
                mockRelationshipGroupContactAssociationId = fflib_IDGenerator.generate(
                    Relationship_Group_Contact_Association__c.SObjectType
                );
            }
            return mockRelationshipGroupContactAssociationId;
        }
        set;
    }

    public Id mockRelationshipGroupPlaceholderAssociationId {
        get {
            if (mockRelationshipGroupPlaceholderAssociationId == null) {
                mockRelationshipGroupPlaceholderAssociationId = fflib_IDGenerator.generate(
                    Relationship_Group_Placeholder_Assoc__c.SObjectType
                );
            }
            return mockRelationshipGroupPlaceholderAssociationId;
        }
        set;
    }

    public Id mockRelationshipGroupUserAssociationId {
        get {
            if (mockRelationshipGroupUserAssociationId == null) {
                mockRelationshipGroupUserAssociationId = fflib_IDGenerator.generate(
                    Relationship_Group_User_Association__c.SObjectType
                );
            }
            return mockRelationshipGroupUserAssociationId;
        }
        set;
    }

    public Id mockRMChartSettingForAccountPlanId {
        get {
            if (mockRMChartSettingForAccountPlanId == null) {
                mockRMChartSettingForAccountPlanId = fflib_IDGenerator.generate(RM_Chart_Setting__C.SObjectType);
            }
            return mockRMChartSettingForAccountPlanId;
        }
        set;
    }

    public Id mockRMOrgSettingForAccountPlanId {
        get {
            if (mockRMOrgSettingForAccountPlanId == null) {
                mockRMOrgSettingForAccountPlanId = fflib_IDGenerator.generate(RM_Org_Setting__C.SObjectType);
            }
            return mockRMOrgSettingForAccountPlanId;
        }
        set;
    }

    public Id mockRMOrgSettingForRMId {
        get {
            if (mockRMOrgSettingForRMId == null) {
                mockRMOrgSettingForRMId = fflib_IDGenerator.generate(RM_Org_Setting__C.SObjectType);
            }
            return mockRMOrgSettingForRMId;
        }
        set;
    }

    public Id mockMapMemberPlaceholderId {
        get {
            if (mockMapMemberPlaceholderId == null) {
                mockMapMemberPlaceholderId = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
            }
            return mockMapMemberPlaceholderId;
        }
        set;
    }

    public Id mockMapMemberPlaceholderRelationshipId {
        get {
            if (mockMapMemberPlaceholderRelationshipId == null) {
                mockMapMemberPlaceholderRelationshipId = fflib_IDGenerator.generate(
                    Map_Member_Placeholder_Relationship__c.SObjectType
                );
            }
            return mockMapMemberPlaceholderRelationshipId;
        }
        set;
    }

    public Id mockRMChartSettingForRelationshipMapId {
        get {
            if (mockRMChartSettingForRelationshipMapId == null) {
                mockRMChartSettingForRelationshipMapId = fflib_IDGenerator.generate(RM_Chart_Setting__C.SObjectType);
            }
            return mockRMChartSettingForRelationshipMapId;
        }
        set;
    }

    public Id mockRelationshipGroupPlaceholderAssocId {
        get {
            if (mockRelationshipGroupPlaceholderAssocId == null) {
                mockRelationshipGroupPlaceholderAssocId = fflib_IDGenerator.generate(
                    Relationship_Group_Placeholder_Assoc__c.SObjectType
                );
            }
            return mockRelationshipGroupPlaceholderAssocId;
        }
        set;
    }

    public Id mockPlaceholderId {
        get {
            if (mockPlaceholderId == null) {
                mockPlaceholderId = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType);
            }
            return mockPlaceholderId;
        }
        set;
    }

    public Id mockRMAnchorId {
        get {
            if (mockRMAnchorId == null) {
                mockRMAnchorId = fflib_IDGenerator.generate(RM_Anchor__c.SObjectType);
            }
            return mockRMAnchorId;
        }
        set;
    }

    public Id mockRMNodeCoordinateForAccountPlanId {
        get {
            if (mockRMNodeCoordinateForAccountPlanId == null) {
                mockRMNodeCoordinateForAccountPlanId = fflib_IDGenerator.generate(RM_Node_Coordinate__c.SObjectType);
            }
            return mockRMNodeCoordinateForAccountPlanId;
        }
        set;
    }

    public Id mockRMNodeCoordinateForRMId {
        get {
            if (mockRMNodeCoordinateForRMId == null) {
                mockRMNodeCoordinateForRMId = fflib_IDGenerator.generate(RM_Node_Coordinate__c.SObjectType);
            }
            return mockRMNodeCoordinateForRMId;
        }
        set;
    }

    public Id mockWSHighlightId {
        get {
            if (mockWSHighlightId == null) {
                mockWSHighlightId = fflib_IDGenerator.generate(WS_Highlight__c.SObjectType);
            }
            return mockWSHighlightId;
        }
        set;
    }

    public Id mockWSFormulaId {
        get {
            if (mockWSFormulaId == null) {
                mockWSFormulaId = fflib_IDGenerator.generate(WS_Summary_Formula__c.SObjectType);
            }
            return mockWSFormulaId;
        }
        set;
    }

    public Id mockWSUserSettingId {
        get {
            if (mockWSUserSettingId == null) {
                mockWSUserSettingId = fflib_IDGenerator.generate(WS_User_Setting__c.SObjectType);
            }
            return mockWSUserSettingId;
        }
        set;
    }

    public Id mockWSDataTypeId {
        get {
            if (mockWSDataTypeId == null) {
                mockWSDataTypeId = fflib_IDGenerator.generate(WS_Data_Type__c.SObjectType);
            }
            return mockWSDataTypeId;
        }
        set;
    }

    public Id mockWSDataTypeAssociationId {
        get {
            if (mockWSDataTypeAssociationId == null) {
                mockWSDataTypeAssociationId = fflib_IDGenerator.generate(WS_Data_Type_Association__c.SObjectType);
            }
            return mockWSDataTypeAssociationId;
        }
        set;
    }

    public Id mockContactExtendedFieldId {
        get {
            if (mockContactExtendedFieldId == null) {
                mockContactExtendedFieldId = fflib_IDGenerator.generate(Contact_Extended_Field__c.SObjectType);
            }
            return mockContactExtendedFieldId;
        }
        set;
    }

    public Id mockRMSvgId {
        get {
            if (mockRMSvgId == null) {
                mockRMSvgId = fflib_IDGenerator.generate(RM_Svg__c.SObjectType);
            }
            return mockRMSvgId;
        }
        set;
    }

    public Id mockRMSvgNodeAssociationId {
        get {
            if (mockRMSvgNodeAssociationId == null) {
                mockRMSvgNodeAssociationId = fflib_IDGenerator.generate(RM_Svg_Node_Association__c.SObjectType);
            }
            return mockRMSvgNodeAssociationId;
        }
        set;
    }

    public Id mockMapMemberLeadId {
        get {
            if (mockMapMemberLeadId == null) {
                mockMapMemberLeadId = fflib_IDGenerator.generate(Map_Member_Lead__c.SObjectType);
            }
            return mockMapMemberLeadId;
        }
        set;
    }

    public Id mockKeyStakeholderLeadId {
        get {
            if (mockKeyStakeholderLeadId == null) {
                mockKeyStakeholderLeadId = fflib_IDGenerator.generate(Key_Stakeholder_Lead__c.SObjectType);
            }
            return mockKeyStakeholderLeadId;
        }
        set;
    }

    public Id mockRelationshipGroupLeadAssociationId {
        get {
            if (mockRelationshipGroupLeadAssociationId == null) {
                mockRelationshipGroupLeadAssociationId = fflib_IDGenerator.generate(
                    Relationship_Group_Lead_Association__c.SObjectType
                );
            }
            return mockRelationshipGroupLeadAssociationId;
        }
        set;
    }

    public Id mockLeadId {
        get {
            if (mockLeadId == null) {
                mockLeadId = fflib_IDGenerator.generate(Lead.SObjectType);
            }
            return mockLeadId;
        }
        set;
    }

    public Id mockInfluenceSupportMatrixId {
        get {
            if (mockInfluenceSupportMatrixId == null) {
                mockInfluenceSupportMatrixId = fflib_IDGenerator.generate(
                    pq_Influence_And_Support_Matrix__c.SObjectType
                );
            }
            return mockInfluenceSupportMatrixId;
        }
        set;
    }

    public Id mockInfluenceId {
        get {
            if (mockInfluenceId == null) {
                mockInfluenceId = fflib_IDGenerator.generate(pq_Influence__c.SObjectType);
            }
            return mockInfluenceId;
        }
        set;
    }

    public Id mockSupportId {
        get {
            if (mockSupportId == null) {
                mockSupportId = fflib_IDGenerator.generate(pq_Support__c.SObjectType);
            }
            return mockSupportId;
        }
        set;
    }

    public Id mockAPScoreId {
        get {
            if (mockAPScoreId == null) {
                mockAPScoreId = fflib_IDGenerator.generate(PQ_AP_Score__mdt.SObjectType);
            }
            return mockAPScoreId;
        }
        set;
    }

    public Id mockMasterAccountPlanId {
        get {
            if (mockMasterAccountPlanId == null) {
                mockMasterAccountPlanId = fflib_IDGenerator.generate(pq_Master_Account_Plan__c.SObjectType);
            }
            return mockMasterAccountPlanId;
        }
        set;
    }

    public Id mockMasterAccountPlanUserSettingId {
        get {
            if (mockMasterAccountPlanUserSettingId == null) {
                mockMasterAccountPlanId = fflib_IDGenerator.generate(Master_Account_Plan_User_Setting__c.SObjectType);
            }
            return mockMasterAccountPlanUserSettingId;
        }
        set;
    }

    public Id mockMasterAccountPlanAssociationId {
        get {
            if (mockMasterAccountPlanAssociationId == null) {
                mockMasterAccountPlanAssociationId = fflib_IDGenerator.generate(
                    Master_Account_Plan_Associations__c.SObjectType
                );
            }
            return mockMasterAccountPlanAssociationId;
        }
        set;
    }

    public Id mockOpportunityPlanId {
        get {
            if (mockOpportunityPlanId == null) {
                mockOpportunityPlanId = fflib_IDGenerator.generate(PQ_Opportunity_Plan__c.SObjectType);
            }
            return mockOpportunityPlanId;
        }
        set;
    }

    public Id mockOpportunityContactRoleId {
        get {
            if (mockOpportunityContactRoleId == null) {
                mockOpportunityContactRoleId = fflib_IDGenerator.generate(OpportunityContactRole.SObjectType);
            }
            return mockOpportunityContactRoleId;
        }
        set;
    }

    public Id mockRelationshipMapMemberAutoHistoryId {
        get {
            if (mockRelationshipMapMemberAutoHistoryId == null) {
                mockRelationshipMapMemberAutoHistoryId = fflib_IDGenerator.generate(
                    Relationship_Map_Member_Auto_History__c.SObjectType
                );
            }
            return mockRelationshipMapMemberAutoHistoryId;
        }
        set;
    }

    /******************************
     *       MOCK OBJECTS
     ******************************/

    public Account mockAccount {
        get {
            if (mockAccount == null) {
                mockAccount = new Account(
                    Name = 'Fake account name',
                    OwnerId = UserInfo.getUserId(),
                    Id = mockAccountId
                );
            }
            return mockAccount;
        }
        set;
    }

    public Task mockTask {
        get {
            if (mockTask == null) {
                mockTask = new Task(
                    Subject = 'Fake task subject',
                    WhatId = mockAccountId,
                    WhoId = mockContactId,
                    Id = mockTaskId
                );
            }
            return mockTask;
        }
        set;
    }

    public pq_Master_Account_Plan__c mockMasterAccountPlan {
        get {
            if (mockMasterAccountPlan == null) {
                mockMasterAccountPlan = new pq_Master_Account_Plan__c(
                    Name = 'Fake master account name',
                    OwnerId = UserInfo.getUserId(),
                    Id = mockMasterAccountPlanId,
                    Account__c = mockAccountId
                );
            }
            return mockMasterAccountPlan;
        }
        set;
    }

    public Master_Account_Plan_User_Setting__c mockMasterAccountPlanUserSetting {
        get {
            if (mockMasterAccountPlanUserSetting == null) {
                mockMasterAccountPlanUserSetting = new Master_Account_Plan_User_Setting__c(
                    Name = 'Fake master account user settings name',
                    User__c = UserInfo.getUserId(),
                    Id = mockMasterAccountPlanUserSettingId,
                    Show_Closed_Account_Plans__c = true,
                    Master_Account_Plan__c = mockMasterAccountPlanId
                );
            }
            return mockMasterAccountPlanUserSetting;
        }
        set;
    }

    public Master_Account_Plan_Associations__c mockMasterAccountPlanAssociation {
        get {
            if (mockMasterAccountPlanAssociation == null) {
                mockMasterAccountPlanAssociation = new Master_Account_Plan_Associations__c(
                    Master_Account_Plan__c = mockMasterAccountPlanId,
                    Id = mockMasterAccountPlanAssociationId,
                    Account_Plan__c = mockAccountPlanId
                );
            }
            return mockMasterAccountPlanAssociation;
        }
        set;
    }

    public Contact mockParentContact {
        get {
            if (mockParentContact == null) {
                mockParentContact = new Contact(
                    FirstName = 'Fake contact first name',
                    LastName = 'Fake contact last name',
                    ReportsToId = fflib_IDGenerator.generate(Contact.SObjectType),
                    Id = mockParentContactId
                );
            }
            return mockParentContact;
        }
        set;
    }

    public Contact mockContact {
        get {
            if (mockContact == null) {
                mockContact = new Contact(
                    FirstName = 'Fake_Contact_First_Name',
                    LastName = 'Fake_Contact_Last_Name',
                    Email = 'FakeContactEmail@FakeTMDTestDomain.com',
                    ReportsToId = mockParentContactId,
                    Id = mockContactId
                );
            }
            return mockContact;
        }
        set;
    }

    public Contact mockContactWithAccount {
        get {
            if (mockContactWithAccount == null) {
                mockContactWithAccount = new Contact(
                    FirstName = 'Fake_Contact_First_Name2',
                    LastName = 'Fake_Contact_Last_Name2',
                    Email = 'FakeContactEmail2@FakeTMDTestDomain.com',
                    ReportsToId = mockParentContactId,
                    AccountId = mockAccountId,
                    Account = mockAccount,
                    Id = mockContactWithAccountId
                );
            }
            return mockContactWithAccount;
        }
        set;
    }

    public Lead mockLead {
        get {
            if (mockLead == null) {
                mockLead = new Lead(
                    FirstName = 'Fake_Lead_First_Name',
                    LastName = 'Fake_Lead_Last_Name',
                    Email = 'FakeLeadEmail@FakeTMDTestDomain.com',
                    Company = 'ACME',
                    Id = mockLeadId
                );
            }
            return mockLead;
        }
        set;
    }

    public User mockUser {
        get {
            if (mockUser == null) {
                mockUser = new User(
                    Alias = 'FakeUser',
                    FirstName = 'Fake_User_First_Name',
                    LastName = 'Fake_User_Last_Name',
                    Email = 'FakeUserEmail@FakeTMDTestDomain.com',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    UserName = 'FakeUser@FakeTMDTestDomain.com',
                    ProfileId = mockProfileId,
                    Id = mockUserId
                );
            }
            return mockUser;
        }
        set;
    }

    public Account_Plan__c mockAccountPlan {
        get {
            if (mockAccountPlan == null) {
                Id recordTypeId = Account_Plan__c.SObjectType.getDescribe()
                    .getRecordTypeInfosByDeveloperName()
                    .get('Account_Plan')
                    .getRecordTypeId();
                mockAccountPlan = new Account_Plan__c(
                    Name = 'Fake account plan name',
                    OwnerId = UserInfo.getUserId(),
                    Summary__c = 'Fake account plan summary',
                    RecordTypeId = recordTypeId,
                    Plan_Overview_Title__c = 'Fake account plan overview title',
                    Plan_Overview__c = 'Fake account plan overview details',
                    Id = mockAccountPlanId,
                    Account__c = mockAccountId
                );
            }
            return mockAccountPlan;
        }
        set;
    }

    public White_Space__c mockWhiteSpace {
        get {
            if (mockWhiteSpace == null) {
                mockWhiteSpace = new White_Space__c(Id = mockWhiteSpaceId, Account_Plan__c = mockAccountPlanId);
            }
            return mockWhiteSpace;
        }
        set;
    }

    public White_Space_Row__c mockWhiteSpaceRow {
        get {
            if (mockWhiteSpaceRow == null) {
                mockWhiteSpaceRow = new White_Space_Row__c(
                    Id = mockWhiteSpaceRowId,
                    White_Space__c = mockWhiteSpaceId,
                    Name = 'mock whitespace row',
                    Order__c = 1
                );
            }
            return mockWhiteSpaceRow;
        }
        set;
    }

    public White_Space_Column__c mockWhiteSpaceColumn {
        get {
            if (mockWhiteSpaceColumn == null) {
                mockWhiteSpaceColumn = new White_Space_Column__c(
                    Id = mockWhiteSpaceColumnId,
                    White_Space__c = mockWhiteSpaceId,
                    Name = 'mock whitespace column',
                    Order__c = 5
                );
            }
            return mockWhiteSpaceColumn;
        }
        set;
    }

    public White_Space_Cell__c mockWhiteSpaceCell {
        get {
            if (mockWhiteSpaceCell == null) {
                mockWhiteSpaceCell = new White_Space_Cell__c(
                    Id = mockWhiteSpaceCellId,
                    White_Space__c = mockWhiteSpaceId,
                    White_Space_Column__c = mockWhiteSpaceColumnId,
                    White_Space_Row__c = mockWhiteSpaceRowId,
                    Info__c = 'mock whitespace cell info'
                );
            }
            return mockWhiteSpaceCell;
        }
        set;
    }

    public WhiteSpaceTileWrapper mockWhiteSpaceTileWrapper {
        get {
            if (mockWhiteSpaceTileWrapper == null) {
                mockWhiteSpaceTileWrapper = new WhiteSpaceTileWrapper(
                    mockWhiteSpaceCellId,
                    mockWhiteSpaceAmountType.pqcrush__Color_RGB__c,
                    mockWhiteSpaceAmountType.Name,
                    mockWhiteSpaceAmountTypeId,
                    mockWSHighlight,
                    new List<WSDataTypeValue>(),
                    new List<WhiteSpaceDisplayFieldWrapper>()
                );
            }
            return mockWhiteSpaceTileWrapper;
        }
        set;
    }

    public WhiteSpaceDisplayFieldWrapper mockDisplayFieldWrapper {
        get {
            if (mockDisplayFieldWrapper == null) {
                mockDisplayFieldWrapper = WhiteSpaceDisplayFieldWrapper.createFor(
                    mockWhiteSpaceAmountType,
                    null,
                    false
                );
                mockDisplayFieldWrapper.isEditable = true;
                mockDisplayFieldWrapper.isPrimary = false;
                mockDisplayFieldWrapper.isInfoField = false;
                mockDisplayFieldWrapper.abbreviation = mockWhiteSpaceAmountType.Abbreviation__c;
                mockDisplayFieldWrapper.displayName = mockWhiteSpaceAmountType.Name;
                mockDisplayFieldWrapper.color = mockWhiteSpaceAmountType.Color_RGB__c;
                mockDisplayFieldWrapper.displayOrder = mockWhiteSpaceAmountType.Order__c;
                mockDisplayFieldWrapper.id = mockWhiteSpaceAmountTypeId;
                mockDisplayFieldWrapper.data = new List<WhiteSpaceDisplayFieldDataWrapper>();
            }
            return mockDisplayFieldWrapper;
        }
        set;
    }

    public White_Space_Amount_Type__c mockWhiteSpaceAmountType {
        get {
            if (mockWhiteSpaceAmountType == null) {
                mockWhiteSpaceAmountType = new White_Space_Amount_Type__c(
                    Id = mockWhiteSpaceAmountTypeId,
                    Name = 'Mock Amount Type 1',
                    Abbreviation__c = 'MAT 1',
                    Color_RGB__c = '#0000ff',
                    Order__c = 3,
                    Display_Type__c = 'Currency'
                );
            }
            return mockWhiteSpaceAmountType;
        }
        set;
    }

    public White_Space_Amount_Type_Association__c mockWhiteSpaceAmountTypeAssociation {
        get {
            if (mockWhiteSpaceAmountTypeAssociation == null) {
                mockWhiteSpaceAmountTypeAssociation = new White_Space_Amount_Type_Association__c(
                    Id = mockWhiteSpaceAmountTypeAssociationId,
                    White_Space_Amount_Type__c = mockWhiteSpaceAmountTypeId,
                    White_Space_Cell__c = mockWhiteSpaceCellId,
                    Amount__c = 42
                );
            }
            return mockWhiteSpaceAmountTypeAssociation;
        }
        set;
    }

    public Asset mockAsset {
        get {
            if (mockAsset == null) {
                mockAsset = new Asset(Name = 'mock asset name', Price = 42, Id = mockAssetId);
            }
            return mockAsset;
        }
        set;
    }

    public Objective__c mockObjective {
        get {
            if (mockObjective == null) {
                mockObjective = new Objective__c(
                    Name = 'Fake objective name',
                    Description__c = 'Fake objective description',
                    Account_Plan__c = mockAccountPlanId,
                    Id = mockObjectiveId
                );
            }
            return mockObjective;
        }
        set;
    }

    public Opportunity mockOpportunity {
        get {
            if (mockOpportunity == null) {
                mockOpportunity = new Opportunity(
                    Name = 'Fake Opportunity name',
                    CloseDate = Date.today(),
                    StageName = 'Prospecting',
                    Amount = 12.05,
                    Id = mockOpportunityId
                );
            }
            return mockOpportunity;
        }
        set;
    }

    public OpportunityLineItem mockOppLineItem {
        get {
            if (mockOppLineItem == null) {
                mockOppLineItem = new OpportunityLineItem(
                    OpportunityId = mockOpportunityId,
                    Product2Id = mockProductId,
                    Quantity = 1,
                    Id = mockOppLineItemId
                );
            }
            return mockOppLineItem;
        }
        set;
    }

    public Objective_Opportunity__c mockObjectiveOpportunity {
        get {
            if (mockObjectiveOpportunity == null) {
                mockObjectiveOpportunity = new Objective_Opportunity__c(
                    Objective__c = mockObjectiveId,
                    Opportunity__c = mockOpportunityId,
                    Id = mockObjectiveOpportunityId
                );
            }
            return mockObjectiveOpportunity;
        }
        set;
    }

    public Team_Member__c mockTeamMember {
        get {
            if (mockTeamMember == null) {
                mockTeamMember = new Team_Member__c(
                    Account_Plan__c = mockAccountPlanId,
                    Role__c = 'Edit',
                    User__c = mockUserId,
                    Id = mockTeamMemberId
                );
            }
            return mockTeamMember;
        }
        set;
    }

    public White_Space_Template_Cell_Field__c mockCellField {
        get {
            if (mockCellField == null) {
                mockCellField = new White_Space_Template_Cell_Field__c(
                    Id = mockCellFieldId,
                    displayFieldId__c = mockWhiteSpaceAmountTypeId,
                    ValueMapping__c = mockAssetMappingId,
                    ValueMapping__r = mockAssetMapping,
                    WhiteSpaceTemplate__c = mockWhiteSpaceTemplateId
                );
            }
            return mockCellField;
        }
        set;
    }

    public White_Space_Template_Cell_Field__c mockBasicCellField {
        get {
            if (mockBasicCellField == null) {
                mockBasicCellField = new White_Space_Template_Cell_Field__c(
                    Id = mockBasicCellFieldId,
                    ValueMapping__c = mockAssetMappingId,
                    ValueMapping__r = mockAssetMapping,
                    WhiteSpaceTemplate__c = mockWhiteSpaceTemplateId
                );
            }
            return mockBasicCellField;
        }
        set;
    }

    public Mapping__c mockOppMapping {
        get {
            if (mockOppMapping == null) {
                mockOppMapping = new Mapping__c(
                    ObjectType__c = 'Opportunity',
                    DisplayLabelField__c = 'Name',
                    ValueField__c = 'Amount',
                    Id = mockOppMappingId
                );
            }
            return mockOppMapping;
        }
        set;
    }

    public Mapping__c mockProductMapping {
        get {
            if (mockProductMapping == null) {
                mockProductMapping = new Mapping__c(
                    ObjectType__c = 'Product2',
                    DisplayLabelField__c = 'Name',
                    ValueField__c = 'Name',
                    Id = mockProductMappingId
                );
            }
            return mockProductMapping;
        }
        set;
    }

    public Mapping__c mockAccountMapping {
        get {
            if (mockAccountMapping == null) {
                mockAccountMapping = new Mapping__c(
                    ObjectType__c = 'Account',
                    DisplayLabelField__c = 'Name',
                    ValueField__c = 'Name',
                    ParentField__c = 'ParentId',
                    GroupResults__c = false,
                    Id = mockAccountMappingId
                );
            }
            return mockAccountMapping;
        }
        set;
    }

    public Mapping__c mockAssetMapping {
        get {
            if (mockAssetMapping == null) {
                mockAssetMapping = new Mapping__c(
                    ObjectType__c = 'Asset',
                    DisplayLabelField__c = 'Name',
                    ValueField__c = 'Price',
                    Id = mockAssetMappingId
                );
            }
            return mockAssetMapping;
        }
        set;
    }

    public White_Space_Template__c mockWhiteSpaceTemplate {
        get {
            if (mockWhiteSpaceTemplate == null) {
                mockWhiteSpaceTemplate = new White_Space_Template__c(
                    Name = 'Mock Whitespace Template',
                    RowMapping__c = mockAccountMapping.id,
                    RowMapping__r = mockAccountMapping,
                    ColumnMapping__c = mockProductMapping.id,
                    ColumnMapping__r = mockProductMapping,
                    Id = mockWhiteSpaceTemplateId
                );
            }
            return mockWhiteSpaceTemplate;
        }
        set;
    }

    public White_Space_Template__c mockLegacyWhiteSpaceTemplate {
        get {
            if (mockLegacyWhiteSpaceTemplate == null) {
                mockLegacyWhiteSpaceTemplate = new White_Space_Template__c(
                    Name = 'Mock Legacy Whitespace Template',
                    Row_Object_Name__c = 'Account',
                    Row_Label_Field_Name__c = 'Name',
                    Column_Object_Name__c = 'Product2',
                    Column_Label_Field_Name__c = 'Name',
                    Id = mockLegacyWhiteSpaceTemplateId
                );
            }
            return mockLegacyWhiteSpaceTemplate;
        }
        set;
    }

    public Key_Stakeholder__c mockKeyStakeholder {
        get {
            if (mockKeyStakeholder == null) {
                String ksString =
                    '{"Id": "' +
                    mockKeyStakeholderId +
                    '", "pqcrush__ContactFirstName__c": "' +
                    mockContact.FirstName +
                    '", "pqcrush__ContactLastName__c": "' +
                    mockContact.LastName +
                    '", "pqcrush__ReportsToId__c": "' +
                    mockContact.reportsToId +
                    '", "pqcrush__Account_Plan__c": "' +
                    mockAccountPlanId +
                    '"}'; //These fields not writeable, also need the pqcrush__
                mockKeyStakeholder = (Key_Stakeholder__c) JSON.deserialize(ksString, Key_Stakeholder__c.class);
                mockKeyStakeholder.Contact__c = mockContactId;
            }
            return mockKeyStakeholder;
        }
        set;
    }

    public Relationship_Map_Member__c mockRelationshipMapMember {
        get {
            if (mockRelationshipMapMember == null) {
                mockRelationshipMapMember = new Relationship_Map_Member__c(
                    Id = mockRelationshipMapMemberId,
                    Relationship_Map__c = mockRelationshipMapId,
                    Contact__c = mockContactId,
                    Contact__r = mockContact
                );
            }
            return mockRelationshipMapMember;
        }
        set;
    }

    public MatrixMember mockMatrixMemberWithRelationshipMapMember {
        get {
            if (mockMatrixMemberWithRelationshipMapMember == null) {
                mockMatrixMemberWithRelationshipMapMember = new MatrixMember(mockRelationshipMapMember);
            }
            return mockMatrixMemberWithRelationshipMapMember;
        }
        set;
    }

    public MatrixMember mockMatrixMemberWithKeyStakeholder {
        get {
            if (mockMatrixMemberWithKeyStakeholder == null) {
                mockMatrixMemberWithKeyStakeholder = new MatrixMember(mockKeyStakeholder);
            }
            return mockMatrixMemberWithKeyStakeholder;
        }
        set;
    }

    public Org_Chart_Field__c mockMapMemberOrgChartField {
        get {
            if (mockMapMemberOrgChartField == null) {
                mockMapMemberOrgChartField = new Org_Chart_Field__c(
                    ObjectName__c = Relationship_Map_Member__c.sObjectType.getDescribe().getName(),
                    FieldName__c = 'Name',
                    Map_Type__c = 'Map Member'
                );
            }
            return mockMapMemberOrgChartField;
        }
        set;
    }

    public Org_Chart_Field__c mockMapMemberContactOrgChartField {
        get {
            if (mockContactOrgChartField == null) {
                mockContactOrgChartField = new Org_Chart_Field__c(
                    ObjectName__c = Contact.sObjectType.getDescribe().getName(),
                    FieldName__c = 'Name',
                    Map_Type__c = 'Map Member'
                );
            }
            return mockContactOrgChartField;
        }
        set;
    }

    public Org_Chart_Field__c mockKeyStakeholderOrgChartField {
        get {
            if (mockKeyStakeholderOrgChartField == null) {
                mockKeyStakeholderOrgChartField = new Org_Chart_Field__c(
                    ObjectName__c = Key_Stakeholder__c.sObjectType.getDescribe().getName(),
                    FieldName__c = 'Name',
                    Map_Type__c = 'Key Stakeholder'
                );
            }
            return mockKeyStakeholderOrgChartField;
        }
        set;
    }

    public Org_Chart_Field__c mockContactOrgChartField {
        get {
            if (mockContactOrgChartField == null) {
                mockContactOrgChartField = new Org_Chart_Field__c(
                    ObjectName__c = Contact.sObjectType.getDescribe().getName(),
                    FieldName__c = 'Name',
                    Map_Type__c = 'Key Stakeholder'
                );
            }
            return mockContactOrgChartField;
        }
        set;
    }

    public CRUSH_Settings_Obj__c mockSettings {
        get {
            if (mockSettings == null) {
                mockSettings = new CRUSH_Settings_Obj__c();
                mockSettings.Id = mockSettingsId;
            }
            return mockSettings;
        }
        set;
    }

    public Relationship_Group__c mockRelationshipGroupParent {
        get {
            if (mockRelationshipGroupParent == null) {
                mockRelationshipGroupParent = new Relationship_Group__c(
                    Id = mockRelationshipGroupId,
                    Label__c = 'mock RelationshipGroupParent Label'
                );
            }
            return mockRelationshipGroupParent;
        }
        set;
    }

    public Relationship_Group__c mockRelationshipGroup {
        get {
            if (mockRelationshipGroup == null) {
                mockRelationshipGroup = new Relationship_Group__c(
                    Id = mockRelationshipGroupId,
                    Label__c = 'mock RelationshipGroup Label',
                    Parent_Relationship_Group__c = mockRelationshipGroupParentId
                );
            }
            return mockRelationshipGroup;
        }
        set;
    }

    public Relationship_Group_Contact_Association__c mockRelationshipGroupContactAssociation {
        get {
            if (mockRelationshipGroupContactAssociation == null) {
                mockRelationshipGroupContactAssociation = new Relationship_Group_Contact_Association__c(
                    Id = mockRelationshipGroupContactAssociationId
                );
            }
            return mockRelationshipGroupContactAssociation;
        }
        set;
    }

    public Relationship_Group_Placeholder_Assoc__c mockRelationshipGroupPlaceholderAssociation {
        get {
            if (mockRelationshipGroupPlaceholderAssociation == null) {
                mockRelationshipGroupPlaceholderAssociation = new Relationship_Group_Placeholder_Assoc__c(
                    Id = mockRelationshipGroupPlaceholderAssociationId
                );
            }
            return mockRelationshipGroupPlaceholderAssociation;
        }
        set;
    }

    public Relationship_Group_User_Association__c mockRelationshipGroupUserAssociation {
        get {
            if (mockRelationshipGroupUserAssociation == null) {
                mockRelationshipGroupUserAssociation = new Relationship_Group_User_Association__c(
                    Id = mockRelationshipGroupUserAssociationId
                );
            }
            return mockRelationshipGroupUserAssociation;
        }
        set;
    }

    public Relationship_Map__c mockRelationshipMap {
        get {
            if (mockRelationshipMap == null) {
                mockRelationshipMap = new Relationship_Map__c(
                    Id = mockRelationshipMapId,
                    Name = 'mock Relationship Map Name'
                );
            }
            return mockRelationshipMap;
        }
        set;
    }

    public RM_Chart_Setting__C mockRMChartSettingForAccountPlan {
        get {
            if (mockRMChartSettingForAccountPlan == null) {
                mockRMChartSettingForAccountPlan = new RM_Chart_Setting__C(
                    Id = mockRMChartSettingForAccountPlanId,
                    Description__c = 'Desc',
                    Account_Plan__c = mockAccountPlanId,
                    Show_Parents__c = true,
                    Show_Empty_Fields__c = true
                );
            }
            return mockRMChartSettingForAccountPlan;
        }
        set;
    }

    public RM_Org_Setting__C mockRMOrgSettingForAccountPlan {
        get {
            if (mockRMOrgSettingForAccountPlan == null) {
                mockRMOrgSettingForAccountPlan = new RM_Org_Setting__C(
                    Id = mockRMOrgSettingForAccountPlanId,
                    Type__c = 'keystakeholder',
                    Auto_Layout__c = true,
                    Card_Style__c = 'Detail',
                    Display_Style__c = 'Horizontal',
                    Enable_Drag_Select__c = false,
                    Is_Group_Global_Scope__c = false,
                    Is_Relationship_Line_Global_Scope__c = false,
                    Relationship_Line_Opacity__c = 100.0,
                    Reports_To_Line_Opacity__c = 100.0,
                    Prolifiq_Extended_Tools_URL__c = 'https://example.com',
                    Show_Empty_Fields__c = false,
                    Show_Overview__c = false,
                    Show_Parents__c = true,
                    Lead_Tab__c = true,
                    User_Tab__c = true,
                    Create_New_Contact__c = true,
                    Is_Influence_Support_Global_Scope__c = false,
                    Is_Reports_To_Global_Scope__c = true
                );
            }
            return mockRMOrgSettingForAccountPlan;
        }
        set;
    }

    public RM_Org_Setting__C mockRMOrgSettingForRM {
        get {
            if (mockRMOrgSettingForAccountPlan == null) {
                mockRMOrgSettingForAccountPlan = new RM_Org_Setting__C(
                    Id = mockRMOrgSettingForRMId,
                    Type__c = 'rm',
                    Auto_Layout__c = true,
                    Card_Style__c = 'Detail',
                    Display_Style__c = 'Horizontal',
                    Enable_Drag_Select__c = false,
                    Is_Group_Global_Scope__c = false,
                    Is_Relationship_Line_Global_Scope__c = false,
                    Relationship_Line_Opacity__c = 100.0,
                    Reports_To_Line_Opacity__c = 100.0,
                    Prolifiq_Extended_Tools_URL__c = 'https://example.com',
                    Show_Empty_Fields__c = false,
                    Show_Overview__c = false,
                    Show_Parents__c = true,
                    Is_Influence_Support_Global_Scope__c = false
                );
            }
            return mockRMOrgSettingForAccountPlan;
        }
        set;
    }

    public Map_Member_Placeholder__c mockMapMemberPlaceholder {
        get {
            if (mockMapMemberPlaceholder == null) {
                mockMapMemberPlaceholder = new Map_Member_Placeholder__c(
                    Id = mockMapMemberPlaceholderId,
                    Name = 'mock Map Member Placeholder Label',
                    Label__c = 'mock Map Member Placeholder Label',
                    Description__c = 'mock Map Member Placeholder Description'
                );
            }
            return mockMapMemberPlaceholder;
        }
        set;
    }

    public RM_Chart_Setting__C mockRMChartSettingForRelationshipMap {
        get {
            if (mockRMChartSettingForRelationshipMap == null) {
                mockRMChartSettingForRelationshipMap = new RM_Chart_Setting__C(
                    Id = mockRMChartSettingForRelationshipMapId,
                    Relationship_Map__c = mockRelationshipMapId,
                    Show_Parents__c = true,
                    Show_Empty_Fields__c = true,
                    Is_Influence_Support_Global_Scope__c = false
                );
            }
            return mockRMChartSettingForRelationshipMap;
        }
        set;
    }
    public Map_Member_Placeholder_Relationship__c mockMapMemberPlaceholderRelationship {
        get {
            if (mockMapMemberPlaceholderRelationship == null) {
                mockMapMemberPlaceholderRelationship = new Map_Member_Placeholder_Relationship__c(
                    Id = mockMapMemberPlaceholderRelationshipId,
                    To__c = mockMapMemberPlaceholderId,
                    From__c = mockContactId
                );
            }
            return mockMapMemberPlaceholderRelationship;
        }
        set;
    }

    public Relationship_Group_Placeholder_Assoc__c mockRelationshipGroupPlaceholderAssoc {
        get {
            if (mockRelationshipGroupPlaceholderAssoc == null) {
                mockRelationshipGroupPlaceholderAssoc = new Relationship_Group_Placeholder_Assoc__c(
                    Id = mockRelationshipGroupPlaceholderAssocId,
                    Map_Member_Placeholder__c = mockMapMemberPlaceholderId,
                    Relationship_Group__c = mockRelationshipGroupId
                );
            }
            return mockRelationshipGroupPlaceholderAssoc;
        }
        set;
    }

    public Map_Member_Placeholder__c mockPlaceholder {
        get {
            if (mockPlaceholder == null) {
                mockPlaceholder = new Map_Member_Placeholder__c(
                    Account_Plan__c = mockAccountPlanId,
                    Description__c = 'Mock Placeholder Description',
                    Label__c = 'Mock Placeholder Label',
                    TempId__c = 'Mock Placeholder Temp Id',
                    Id = mockPlaceholderId
                );
            }
            return mockPlaceholder;
        }
        set;
    }

    public Map_Member_Placeholder_Relationship__c mockPlaceholderRelationship {
        get {
            if (mockPlaceholderRelationship == null) {
                mockPlaceholderRelationship = new Map_Member_Placeholder_Relationship__c(
                    From__c = mockPlaceholderId,
                    To__c = fflib_IDGenerator.generate(Map_Member_Placeholder__c.SObjectType),
                    Is_Hierarchy__c = true
                );
            }
            return mockPlaceholderRelationship;
        }
        set;
    }

    public RM_Anchor__c mockRMAnchor {
        get {
            if (mockRMAnchor == null) {
                mockRMAnchor = new RM_Anchor__c(
                    From__c = mockKeyStakeholderId,
                    To__c = mockContactId,
                    Id = mockRMAnchorId
                );
            }
            return mockRMAnchor;
        }
        set;
    }

    public RM_Node_Coordinate__c mockRMNodeCoordinateForAccountPlan {
        get {
            if (mockRMNodeCoordinateForAccountPlan == null) {
                mockRMNodeCoordinateForAccountPlan = new RM_Node_Coordinate__c(
                    Key__c = 'key1',
                    TempId__c = 'tempId1',
                    X__c = (Double) 111.11,
                    Y__c = (Double) 222.22,
                    Account_Plan__c = mockAccountPlanId,
                    Id = mockRMNodeCoordinateForAccountPlanId
                );
            }
            return mockRMNodeCoordinateForAccountPlan;
        }
        set;
    }

    public RM_Node_Coordinate__c mockRMNodeCoordinateForRM {
        get {
            if (mockRMNodeCoordinateForRM == null) {
                mockRMNodeCoordinateForRM = new RM_Node_Coordinate__c(
                    Key__c = 'key2',
                    TempId__c = 'tempId2',
                    X__c = (Double) 333.33,
                    Y__c = (Double) 444.44,
                    Relationship_Map__c = mockRelationshipMapId,
                    Id = mockRMNodeCoordinateForRMId
                );
            }
            return mockRMNodeCoordinateForRM;
        }
        set;
    }

    public WS_Highlight__c mockWSHighlight {
        get {
            if (mockWSHighlight == null) {
                mockWSHighlight = new WS_Highlight__c(
                    Id = mockWSHighlightId,
                    Color__c = '#0080ff',
                    Label__c = 'Sample Highlight'
                );
            }
            return mockWSHighlight;
        }
        set;
    }

    public WS_Data_Type__c mockWSDataType {
        get {
            if (mockWSDataType == null) {
                mockWSDataType = new WS_Data_Type__c(
                    Id = mockWSDataTypeId,
                    Data_Type__c = 'Picklist',
                    Color__c = '#123456',
                    Picklist_Values__c = 'one\ntwo\nthree\ntest',
                    White_Space__c = mockWhiteSpaceId,
                    Label__c = 'Sample Data Type',
                    Apply_To_All_Cross_Sell_Maps__c = false
                );
            }
            return mockWSDataType;
        }
        set;
    }

    public WS_Data_Type_Association__c mockWSDataTypeAssociation {
        get {
            if (mockWSDataTypeAssociation == null) {
                mockWSDataTypeAssociation = new WS_Data_Type_Association__c(
                    Id = mockWSDataTypeAssociationId,
                    White_Space_Cell__c = mockWhiteSpaceCellId,
                    WS_Data_Type__c = mockWSDataTypeId,
                    WS_Data_Value__c = 'test'
                );
            }
            return mockWSDataTypeAssociation;
        }
        set;
    }

    public WS_Summary_Formula__c mockWSFormula {
        get {
            if (mockWSFormula == null) {
                mockWSFormula = new WS_Summary_Formula__c(
                    Apply_To_All_Cross_Sell_Maps__c = false,
                    Color__c = '#123456',
                    Display_Type__c = 'Double',
                    Formula__c = '2 + 3',
                    Label__c = 'Mock Test Formula Label',
                    White_Space__c = mockWhiteSpaceId,
                    Id = mockWSFormulaId
                );
            }
            return mockWSFormula;
        }
        set;
    }

    public WS_User_Setting__c mockWSUserSetting {
        get {
            if (mockWSUserSetting == null) {
                mockWSUserSetting = new WS_User_Setting__c(
                    White_Space__c = mockRelationshipMapId,
                    User__c = mockUserId,
                    Id = mockWSUserSettingId
                );
            }
            return mockWSUserSetting;
        }
        set;
    }

    public Contact_Extended_Field__c mockContactExtendedField {
        get {
            if (mockContactExtendedField == null) {
                mockContactExtendedField = new Contact_Extended_Field__c(
                    Profile_Picture_Data__c = 'abc',
                    Contact__c = mockContactId,
                    Id = mockContactExtendedFieldId,
                    Influence__c = mockInfluenceId,
                    Support__c = mockSupportId
                );
            }
            return mockContactExtendedField;
        }
        set;
    }

    public RM_Svg__c mockRMSvg {
        get {
            if (mockRMSvg == null) {
                mockRMSvg = new RM_Svg__c(Name = 'Fake rm svg name', Label__c = 'Fake Label', Id = mockRMSvgId);
            }
            return mockRMSvg;
        }
        set;
    }

    public RM_Svg_Node_Association__c mockRMSvgNodeAssociation {
        get {
            if (mockRMSvgNodeAssociation == null) {
                mockRMSvgNodeAssociation = new RM_Svg_Node_Association__c(RM_Svg__c = mockRMSvgId, Key__c = 'FakeKey');
            }
            return mockRMSvgNodeAssociation;
        }
        set;
    }

    public Map_Member_Lead__c mockMapMemberLead {
        get {
            if (mockMapMemberLead == null) {
                mockMapMemberLead = new Map_Member_Lead__c(
                    Relationship_Map__c = mockRelationshipMapId,
                    Lead__c = mockLeadId,
                    Id = mockMapMemberLeadId
                );
            }
            return mockMapMemberLead;
        }
        set;
    }

    public Key_Stakeholder_Lead__c mockKeyStakeholderLead {
        get {
            if (mockKeyStakeholderLead == null) {
                mockKeyStakeholderLead = new Key_Stakeholder_Lead__c(
                    Account_Plan__c = mockAccountPlanId,
                    Lead__c = mockLeadId,
                    Id = mockKeyStakeholderLeadId
                );
            }
            return mockKeyStakeholderLead;
        }
        set;
    }

    public Relationship_Group_Lead_Association__c mockRelationshipGroupLeadAssociation {
        get {
            if (mockRelationshipGroupLeadAssociation == null) {
                mockRelationshipGroupLeadAssociation = new Relationship_Group_Lead_Association__c(
                    Relationship_Group__c = mockRelationshipGroupId,
                    Lead__c = mockLeadId,
                    Id = mockRelationshipGroupLeadAssociationId
                );
            }
            return mockRelationshipGroupLeadAssociation;
        }
        set;
    }

    public WhiteSpaceTemplateCellFieldWrapper mockRelatedCellFieldWrapper {
        get {
            if (mockRelatedCellFieldWrapper == null) {
                mockRelatedCellFieldWrapper = new WhiteSpaceTemplateCellFieldWrapper(this.mockWSRelatedObjectWrapper);
            }
            return mockRelatedCellFieldWrapper;
        }
        set;
    }

    public WhiteSpaceTemplateCellFieldWrapper mockRelatedCellFieldWrapperCompound {
        get {
            if (mockRelatedCellFieldWrapperCompound == null) {
                mockRelatedCellFieldWrapperCompound = new WhiteSpaceTemplateCellFieldWrapper(
                    this.mockWSRelatedObjectWrapperCompound
                );
            }
            return mockRelatedCellFieldWrapperCompound;
        }
        set;
    }

    public WSRelatedObjectWrapper mockWSRelatedObjectWrapper {
        get {
            if (mockWSRelatedObjectWrapper == null) {
                mockWSRelatedObjectWrapper = new WSRelatedObjectWrapper();
                mockWSRelatedObjectWrapper.objDesc = Account.sObjectType.getDescribe();
                mockWSRelatedObjectWrapper.relationshipField = Schema.SObjectType.Account.fields.OwnerId;
                mockWSRelatedObjectWrapper.labelFieldDesc = Schema.SObjectType.Account.fields.Name;
                mockWSRelatedObjectWrapper.labelFieldName = Schema.SObjectType.Account.fields.Name.getName();
                mockWSRelatedObjectWrapper.fieldList = new List<String>{
                    Schema.SObjectType.Account.fields.Name.getName()
                };
            }
            return mockWSRelatedObjectWrapper;
        }
        set;
    }

    public WSRelatedObjectWrapper mockWSRelatedObjectWrapperCompound {
        get {
            if (mockWSRelatedObjectWrapperCompound == null) {
                mockWSRelatedObjectWrapperCompound = new WSRelatedObjectWrapper();
                mockWSRelatedObjectWrapperCompound.objDesc = Contact.sObjectType.getDescribe();
                mockWSRelatedObjectWrapperCompound.relationshipField = Schema.SObjectType.Contact.fields.OwnerId;
                mockWSRelatedObjectWrapperCompound.labelFieldDesc = Schema.SObjectType.Account.fields.Name;
                mockWSRelatedObjectWrapperCompound.labelFieldName = 'Account.Name';
                mockWSRelatedObjectWrapperCompound.fieldList = new List<String>{ 'Account.Name', 'Account.Id' };
            }
            return mockWSRelatedObjectWrapperCompound;
        }
        set;
    }

    public Cell_Relationship_Configuration__c mockWSCellRelationshipConfig {
        get {
            if (mockWSCellRelationshipConfig == null) {
                mockWSCellRelationshipConfig = new Cell_Relationship_Configuration__c();
                mockWSCellRelationshipConfig.Object_API_Name__c = 'Contact';
                mockWSCellRelationshipConfig.Color__c = '#FFF';
                mockWSCellRelationshipConfig.Display_Field__c = 'Name';
            }
            return mockWSCellRelationshipConfig;
        }
        set;
    }

    public pq_Influence_And_Support_Matrix__c mockInfluenceSupportMatrix {
        get {
            if (mockInfluenceSupportMatrix == null) {
                mockInfluenceSupportMatrix = new pq_Influence_And_Support_Matrix__c();
                mockInfluenceSupportMatrix.Id = mockInfluenceSupportMatrixId;
                mockInfluenceSupportMatrix.Name = 'Default Matrix';
                mockInfluenceSupportMatrix.Is_Default__c = true;
            }
            return mockInfluenceSupportMatrix;
        }
        set;
    }

    public pq_Influence__c mockInfluence {
        get {
            if (mockInfluence == null) {
                mockInfluence = new pq_Influence__c();
                mockInfluence.Id = mockInfluenceId;
                mockInfluence.Name = 'Low';
                mockInfluence.Label__c = 'Low Label';
            }
            return mockInfluence;
        }
        set;
    }

    public pq_Support__c mockSupport {
        get {
            if (mockSupport == null) {
                mockSupport = new pq_Support__c();
                mockSupport.Id = mockSupportId;
                mockSupport.Name = 'Champ';
                mockSupport.Label__c = 'Champ Label';
                mockSupport.Color__c = '#112233';
            }
            return mockSupport;
        }
        set;
    }

    public PQ_AP_Score__mdt mockAPScoreData {
        get {
            if (mockAPScoreData == null) {
                mockAPScoreData = new PQ_AP_Score__mdt(
                    Id = mockAPScoreId,
                    DeveloperName = 'Mock_Score',
                    Label = 'Mock AP Score Data Points',
                    Score_Label__c = '',
                    Score_Object__c = true,
                    Score_Field_API_Name__c = 'pqcrush__Intermediate_Score__c',
                    Count_BP_Low__c = 0,
                    Count_BP_Mid__c = 10,
                    Count_BP_High__c = 20,
                    Score_BP_Low__c = 3,
                    Score_BP_Mid__c = 7,
                    Score_BP_High__c = 10,
                    Use_Time_Decay__c = true,
                    Date_Field_API_Name__c = 'pqcrush__Cell_Max_LMD__c',
                    Time_BP_Low__c = 7,
                    Time_BP_Mid__c = 30,
                    Time_BP_High__c = 90,
                    Time_BP_Mult_Low__c = .75,
                    Time_BP_Mult_Mid__c = .5,
                    Time_BP_Mult_High__c = .25
                );
            }
            return mockAPScoreData;
        }
        set;
    }

    public RecentlyViewed mockRecentlyViewed {
        get {
            if (mockRecentlyViewed == null) {
                String jsonString =
                    '{"Id": "' +
                    mockAccountId +
                    '", "Name": "' +
                    mockAccount.Name +
                    '", "Type": "Account"}'; //These fields not writeable
                mockRecentlyViewed = (RecentlyViewed) JSON.deserialize(jsonString, RecentlyViewed.class);
            }
            return mockRecentlyViewed;
        }
        set;
    }

    public PQ_Opportunity_Plan__c mockOpportunityPlan {
        get {
            if (mockOpportunityPlan == null) {
                mockOpportunityPlan = new PQ_Opportunity_Plan__c(
                    Id = mockOpportunityPlanId,
                    Name = 'Plan - Fake Opportunity name',
                    Opportunity__c = mockOpportunityId
                );
            }
            return mockOpportunityPlan;
        }
        set;
    }

    public OpportunityContactRole mockOpportunityContactRole {
        get {
            if (mockOpportunityContactRole == null) {
                mockOpportunityContactRole = new OpportunityContactRole(
                    Id = mockOpportunityContactRoleId,
                    OpportunityId = mockOpportunityId,
                    ContactId = mockContactId,
                    Role = 'Decision Maker'
                );
            }
            return mockOpportunityContactRole;
        }
        set;
    }

    public Relationship_Map_Member_Auto_History__c mockRelationshipMapMemberAutoHistory {
        get {
            if (mockRelationshipMapMemberAutoHistory == null) {
                mockRelationshipMapMemberAutoHistory = new Relationship_Map_Member_Auto_History__c(
                    Id = mockRelationshipMapMemberAutoHistoryId,
                    RelationshipMapId__c = mockRelationshipMapId,
                    ContactId__c = mockContactId
                );
            }
            return mockRelationshipMapMemberAutoHistory;
        }
        set;
    }

    /******************************
     *     BASIC MOCK CLASSES
     ******************************/
    public fflib_ApexMocks mocks = new fflib_ApexMocks(); //NOPMD
    public fflib_ISObjectUnitOfWork mockUow {
        get {
            if (mockUow == null) {
                mockUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
                Application.UnitOfWork.setMock(mockUow);
            }
            return mockUow;
        }
        set;
    }

    public fflib_ISObjectUnitOfWork mockOpportunityPlanUow {
        get {
            if (mockOpportunityPlanUow == null) {
                mockOpportunityPlanUow = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
                Application.OpportunityPlanUnitOfWork.setMock(mockOpportunityPlanUow);
            }
            return mockOpportunityPlanUow;
        }
        set;
    }

    /******************************
     *       MOCK SERVICES
     ******************************/
    public WhiteSpaceServiceImpl mockWhiteSpaceService {
        get {
            if (mockWhiteSpaceService == null) {
                mockWhiteSpaceService = (WhiteSpaceServiceImpl) mocks.mock(WhiteSpaceServiceImpl.class);
                Application.Service.setMock(WhiteSpaceServiceImpl.class, mockWhiteSpaceService);
            }
            return mockWhiteSpaceService;
        }
        set;
    }
    public WhiteSpaceUtilsImpl mockWhiteSpaceUtils {
        get {
            if (mockWhiteSpaceUtils == null) {
                mockWhiteSpaceUtils = (WhiteSpaceUtilsImpl) mocks.mock(WhiteSpaceUtilsImpl.class);
                Application.Service.setMock(WhiteSpaceUtilsImpl.class, mockWhiteSpaceUtils);
            }
            return mockWhiteSpaceUtils;
        }
        set;
    }

    public SettingServiceImpl mockSettingService {
        get {
            if (mockSettingService == null) {
                mockSettingService = (SettingServiceImpl) mocks.mock(SettingServiceImpl.class);
                Application.Service.setMock(SettingServiceImpl.class, mockSettingService);
            }
            return mockSettingService;
        }
        set;
    }

    public ContactRelationshipServiceImpl mockContactRelationshipService {
        get {
            if (mockContactRelationshipService == null) {
                mockContactRelationshipService = (ContactRelationshipServiceImpl) mocks.mock(
                    ContactRelationshipServiceImpl.class
                );
                Application.Service.setMock(ContactRelationshipServiceImpl.class, mockContactRelationshipService);
            }
            return mockContactRelationshipService;
        }
        set;
    }

    public RelationshipGroupServiceImpl mockRelationshipGroupService {
        get {
            if (mockRelationshipGroupService == null) {
                mockRelationshipGroupService = (RelationshipGroupServiceImpl) mocks.mock(
                    RelationshipGroupServiceImpl.class
                );
                Application.Service.setMock(RelationshipGroupServiceImpl.class, mockRelationshipGroupService);
            }
            return mockRelationshipGroupService;
        }
        set;
    }

    public GraphDataServiceImpl mockGraphDataService {
        get {
            if (mockGraphDataService == null) {
                mockGraphDataService = (GraphDataServiceImpl) mocks.mock(GraphDataServiceImpl.class);
                Application.Service.setMock(GraphDataServiceImpl.class, mockGraphDataService);
            }
            return mockGraphDataService;
        }
        set;
    }

    public StaticResourceServiceImpl mockStaticResourceService {
        get {
            if (mockStaticResourceService == null) {
                mockStaticResourceService = (StaticResourceServiceImpl) mocks.mock(StaticResourceServiceImpl.class);
                Application.Service.setMock(StaticResourceServiceImpl.class, mockStaticResourceService);
            }
            return mockStaticResourceService;
        }
        set;
    }

    public RelationshipMapServiceImpl mockRelationshipMapService {
        get {
            if (mockRelationshipMapService == null) {
                mockRelationshipMapService = (RelationshipMapServiceImpl) mocks.mock(RelationshipMapServiceImpl.class);
                Application.Service.setMock(RelationshipMapServiceImpl.class, mockRelationshipMapService);
            }
            return mockRelationshipMapService;
        }
        set;
    }

    public RMChartSettingServiceImpl mockRMChartSettingService {
        get {
            if (mockRMChartSettingService == null) {
                mockRMChartSettingService = (RMChartSettingServiceImpl) mocks.mock(RMChartSettingServiceImpl.class);
                Application.Service.setMock(RMChartSettingServiceImpl.class, mockRMChartSettingService);
            }
            return mockRMChartSettingService;
        }
        set;
    }

    public MapMemberPlaceholderServiceImpl mockMapMemberPlaceholderService {
        get {
            if (mockMapMemberPlaceholderService == null) {
                mockMapMemberPlaceholderService = (MapMemberPlaceholderServiceImpl) mocks.mock(
                    MapMemberPlaceholderServiceImpl.class
                );
                Application.Service.setMock(MapMemberPlaceholderServiceImpl.class, mockMapMemberPlaceholderService);
            }
            return mockMapMemberPlaceholderService;
        }
        set;
    }

    public RMNodeCoordinateServiceImpl mockRMNodeCoordinateService {
        get {
            if (mockRMNodeCoordinateService == null) {
                mockRMNodeCoordinateService = (RMNodeCoordinateServiceImpl) mocks.mock(
                    RMNodeCoordinateServiceImpl.class
                );
                Application.Service.setMock(RMNodeCoordinateServiceImpl.class, mockRMNodeCoordinateService);
            }
            return mockRMNodeCoordinateService;
        }
        set;
    }

    public WSSummaryFormulaServiceImpl mockWSSummaryFormulaService {
        get {
            if (mockWSSummaryFormulaService == null) {
                mockWSSummaryFormulaService = (WSSummaryFormulaServiceImpl) mocks.mock(
                    WSSummaryFormulaServiceImpl.class
                );
                Application.Service.setMock(WSSummaryFormulaServiceImpl.class, mockWSSummaryFormulaService);
            }
            return mockWSSummaryFormulaService;
        }
        set;
    }

    public SObjectServiceImpl mockSObjectService {
        get {
            if (mockSObjectService == null) {
                mockSObjectService = (SObjectServiceImpl) mocks.mock(SObjectServiceImpl.class);
                Application.Service.setMock(SObjectServiceImpl.class, mockSObjectService);
            }
            return mockSObjectService;
        }
        set;
    }

    public DynamicObjectQueryServiceImpl mockDynamicObjectQueryService {
        get {
            if (mockDynamicObjectQueryService == null) {
                mockDynamicObjectQueryService = (DynamicObjectQueryServiceImpl) mocks.mock(
                    DynamicObjectQueryServiceImpl.class
                );
                Application.Service.setMock(DynamicObjectQueryServiceImpl.class, mockDynamicObjectQueryService);
            }
            return mockDynamicObjectQueryService;
        }
        set;
    }

    public WSDataTypeServiceImpl mockWSDataTypeService {
        get {
            if (mockWSDataTypeService == null) {
                mockWSDataTypeService = (WSDataTypeServiceImpl) mocks.mock(WSDataTypeServiceImpl.class);
                Application.Service.setMock(WSDataTypeServiceImpl.class, mockWSDataTypeService);
            }
            return mockWSDataTypeService;
        }
        set;
    }

    public AccountPlanShareServiceImpl mockAccountPlanShareService {
        get {
            if (mockAccountPlanShareService == null) {
                mockAccountPlanShareService = (AccountPlanShareServiceImpl) mocks.mock(
                    AccountPlanShareServiceImpl.class
                );
                Application.Service.setMock(AccountPlanShareServiceImpl.class, mockAccountPlanShareService);
            }
            return mockAccountPlanShareService;
        }
        set;
    }

    public AccountTeamServiceImpl mockAccountTeamService {
        get {
            if (mockAccountTeamService == null) {
                mockAccountTeamService = (AccountTeamServiceImpl) mocks.mock(AccountTeamServiceImpl.class);
                Application.Service.setMock(AccountTeamServiceImpl.class, mockAccountTeamService);
            }
            return mockAccountTeamService;
        }
        set;
    }

    public RMOrgSettingServiceImpl mockRMOrgSettingService {
        get {
            if (mockRMOrgSettingService == null) {
                mockRMOrgSettingService = (RMOrgSettingServiceImpl) mocks.mock(RMOrgSettingServiceImpl.class);
                Application.Service.setMock(RMOrgSettingServiceImpl.class, mockRMOrgSettingService);
            }
            return mockRMOrgSettingService;
        }
        set;
    }

    public RMSvgServiceImpl mockRMSvgService {
        get {
            if (mockRMSvgService == null) {
                mockRMSvgService = (RMSvgServiceImpl) mocks.mock(RMSvgServiceImpl.class);
                Application.Service.setMock(RMSvgServiceImpl.class, mockRMSvgService);
            }
            return mockRMSvgService;
        }
        set;
    }

    public MapMemberLeadServiceImpl mockMapMemberLeadService {
        get {
            if (mockMapMemberLeadService == null) {
                mockMapMemberLeadService = (MapMemberLeadServiceImpl) mocks.mock(MapMemberLeadServiceImpl.class);
                Application.Service.setMock(MapMemberLeadServiceImpl.class, mockMapMemberLeadService);
            }
            return mockMapMemberLeadService;
        }
        set;
    }

    public AccountServiceImpl mockAccountService {
        get {
            if (mockAccountService == null) {
                mockAccountService = (AccountServiceImpl) mocks.mock(AccountServiceImpl.class);
                Application.Service.setMock(AccountServiceImpl.class, mockAccountService);
            }
            return mockAccountService;
        }
        set;
    }

    public InfluenceSupportMatrixServiceImpl mockInfluenceSupportMatrixService {
        get {
            if (mockInfluenceSupportMatrixService == null) {
                mockInfluenceSupportMatrixService = (InfluenceSupportMatrixServiceImpl) mocks.mock(
                    InfluenceSupportMatrixServiceImpl.class
                );
                Application.Service.setMock(InfluenceSupportMatrixServiceImpl.class, mockInfluenceSupportMatrixService);
            }
            return mockInfluenceSupportMatrixService;
        }
        set;
    }

    public AccountPlanServiceImpl mockAccountPlanService {
        get {
            if (mockAccountPlanService == null) {
                mockAccountPlanService = (AccountPlanServiceImpl) mocks.mock(AccountPlanServiceImpl.class);
                Application.Service.setMock(AccountPlanServiceImpl.class, mockAccountPlanService);
            }
            return mockAccountPlanService;
        }
        set;
    }

    public ContactExtendedFieldServiceImpl mockContactExtendedFieldService {
        get {
            if (mockContactExtendedFieldService == null) {
                mockContactExtendedFieldService = (ContactExtendedFieldServiceImpl) mocks.mock(
                    ContactExtendedFieldServiceImpl.class
                );
                Application.Service.setMock(ContactExtendedFieldServiceImpl.class, mockContactExtendedFieldService);
            }
            return mockContactExtendedFieldService;
        }
        set;
    }

    public ObjectiveServiceImpl mockObjectiveService {
        get {
            if (mockObjectiveService == null) {
                mockObjectiveService = (ObjectiveServiceImpl) mocks.mock(ObjectiveServiceImpl.class);
                Application.Service.setMock(ObjectiveServiceImpl.class, mockObjectiveService);
            }
            return mockObjectiveService;
        }
        set;
    }

    public WhiteSpaceHighlightServiceImpl mockWhiteSpaceHighlightService {
        get {
            if (mockWhiteSpaceHighlightService == null) {
                mockWhiteSpaceHighlightService = (WhiteSpaceHighlightServiceImpl) mocks.mock(
                    WhiteSpaceHighlightServiceImpl.class
                );
                Application.Service.setMock(WhiteSpaceHighlightServiceImpl.class, mockWhiteSpaceHighlightService);
            }
            return mockWhiteSpaceHighlightService;
        }
        set;
    }

    public WSUserSettingServiceImpl mockWSUserSettingService {
        get {
            if (mockWSUserSettingService == null) {
                mockWSUserSettingService = (WSUserSettingServiceImpl) mocks.mock(WSUserSettingServiceImpl.class);
                Application.Service.setMock(WSUserSettingServiceImpl.class, mockWSUserSettingService);
            }
            return mockWSUserSettingService;
        }
        set;
    }

    public AccountPlanUserSettingServiceImpl mockAccountPlanUserSettingService {
        get {
            if (mockAccountPlanUserSettingService == null) {
                mockAccountPlanUserSettingService = (AccountPlanUserSettingServiceImpl) mocks.mock(
                    AccountPlanUserSettingServiceImpl.class
                );
                Application.Service.setMock(AccountPlanUserSettingServiceImpl.class, mockAccountPlanUserSettingService);
            }
            return mockAccountPlanUserSettingService;
        }
        set;
    }

    public GraphDataLeadServiceImpl mockGraphDataLeadService {
        get {
            if (mockGraphDataLeadService == null) {
                mockGraphDataLeadService = (GraphDataLeadServiceImpl) mocks.mock(GraphDataLeadServiceImpl.class);
                Application.Service.setMock(GraphDataLeadServiceImpl.class, mockGraphDataLeadService);
            }
            return mockGraphDataLeadService;
        }
        set;
    }

    public HealthScoreServiceImpl mockHealthScoreService {
        get {
            if (mockHealthScoreService == null) {
                mockHealthScoreService = (HealthScoreServiceImpl) mocks.mock(HealthScoreServiceImpl.class);
                Application.Service.setMock(HealthScoreServiceImpl.class, mockHealthScoreService);
            }
            return mockHealthScoreService;
        }
        set;
    }

    public ReportStructureWrapperServiceImpl mockReportStructureWrapperService {
        get {
            if (mockReportStructureWrapperService == null) {
                mockReportStructureWrapperService = (ReportStructureWrapperServiceImpl) mocks.mock(
                    ReportStructureWrapperServiceImpl.class
                );
                Application.Service.setMock(ReportStructureWrapperServiceImpl.class, mockReportStructureWrapperService);
            }
            return mockReportStructureWrapperService;
        }
        set;
    }

    public RelationshipLineWrapperServiceImpl mockRelationshipLineWrapperService {
        get {
            if (mockRelationshipLineWrapperService == null) {
                mockRelationshipLineWrapperService = (RelationshipLineWrapperServiceImpl) mocks.mock(
                    RelationshipLineWrapperServiceImpl.class
                );
                Application.Service.setMock(
                    RelationshipLineWrapperServiceImpl.class,
                    mockRelationshipLineWrapperService
                );
            }
            return mockRelationshipLineWrapperService;
        }
        set;
    }

    public RMGroupHelperServiceImpl mockRMGroupHelperService {
        get {
            if (mockRMGroupHelperService == null) {
                mockRMGroupHelperService = (RMGroupHelperServiceImpl) mocks.mock(RMGroupHelperServiceImpl.class);
                Application.Service.setMock(RMGroupHelperServiceImpl.class, mockRMGroupHelperService);
            }
            return mockRMGroupHelperService;
        }
        set;
    }

    public RelationshipMapCloneServiceImpl mockRelationshipMapCloneService {
        get {
            if (mockRelationshipMapCloneService == null) {
                mockRelationshipMapCloneService = (RelationshipMapCloneServiceImpl) mocks.mock(
                    RelationshipMapCloneServiceImpl.class
                );
                Application.Service.setMock(RelationshipMapCloneServiceImpl.class, mockRelationshipMapCloneService);
            }
            return mockRelationshipMapCloneService;
        }
        set;
    }

    public RMSvgHelperServiceImpl mockRMSvgHelperService {
        get {
            if (mockRMSvgHelperService == null) {
                mockRMSvgHelperService = (RMSvgHelperServiceImpl) mocks.mock(RMSvgHelperServiceImpl.class);
                Application.Service.setMock(RMSvgHelperServiceImpl.class, mockRMSvgHelperService);
            }
            return mockRMSvgHelperService;
        }
        set;
    }

    public AccountContactRelationServiceImpl mockAccountContactRelationService {
        get {
            if (mockAccountContactRelationService == null) {
                mockAccountContactRelationService = (AccountContactRelationServiceImpl) mocks.mock(
                    AccountContactRelationServiceImpl.class
                );
                Application.Service.setMock(AccountContactRelationServiceImpl.class, mockAccountContactRelationService);
            }
            return mockAccountContactRelationService;
        }
        set;
    }

    public CrushUserSettingServiceImpl mockCrushUserSettingService {
        get {
            if (mockCrushUserSettingService == null) {
                mockCrushUserSettingService = (CrushUserSettingServiceImpl) mocks.mock(
                    CrushUserSettingServiceImpl.class
                );
                Application.Service.setMock(CrushUserSettingServiceImpl.class, mockCrushUserSettingService);
            }
            return mockCrushUserSettingService;
        }
        set;
    }

    public PostInstallHelperServiceImpl mockPostInstallHelperService {
        get {
            if (mockPostInstallHelperService == null) {
                mockPostInstallHelperService = (PostInstallHelperServiceImpl) mocks.mock(
                    PostInstallHelperServiceImpl.class
                );
                Application.PostInstallService.setMock(
                    PostInstallHelperServiceImpl.class,
                    mockPostInstallHelperService
                );
            }
            return mockPostInstallHelperService;
        }
        set;
    }

    public InfluenceSupportMatrixServiceImpl influenceSupportMatrixService {
        get {
            if (influenceSupportMatrixService == null) {
                influenceSupportMatrixService = (InfluenceSupportMatrixServiceImpl) mocks.mock(
                    InfluenceSupportMatrixServiceImpl.class
                );
                Application.Service.setMock(InfluenceSupportMatrixServiceImpl.class, influenceSupportMatrixService);
            }
            return influenceSupportMatrixService;
        }
        set;
    }

    public MasterAccountPlanServiceImpl mockMasterAccountPlanService {
        get {
            if (mockMasterAccountPlanService == null) {
                mockMasterAccountPlanService = (MasterAccountPlanServiceImpl) mocks.mock(
                    MasterAccountPlanServiceImpl.class
                );
                Application.Service.setMock(MasterAccountPlanServiceImpl.class, mockMasterAccountPlanService);
            }
            return mockMasterAccountPlanService;
        }
        set;
    }

    public OpportunityPlanServiceImpl mockOpportunityPlanService {
        get {
            if (mockOpportunityPlanService == null) {
                mockOpportunityPlanService = (OpportunityPlanServiceImpl) mocks.mock(OpportunityPlanServiceImpl.class);
                Application.Service.setMock(OpportunityPlanServiceImpl.class, mockOpportunityPlanService);
            }
            return mockOpportunityPlanService;
        }
        set;
    }

    public SendEmailNotificationsImpl mockSendEmailNotificationsService {
        get {
            if (mockSendEmailNotificationsService == null) {
                mockSendEmailNotificationsService = (SendEmailNotificationsImpl) mocks.mock(
                    SendEmailNotificationsImpl.class
                );
                Application.Service.setMock(SendEmailNotificationsImpl.class, mockSendEmailNotificationsService);
            }
            return mockSendEmailNotificationsService;
        }
        set;
    }

    public OpportunityScoreServiceImpl mockOpportunityScoreService {
        get {
            if (mockOpportunityScoreService == null) {
                mockOpportunityScoreService = (OpportunityScoreServiceImpl) mocks.mock(
                    OpportunityScoreServiceImpl.class
                );
                Application.Service.setMock(OpportunityScoreServiceImpl.class, mockOpportunityScoreService);
            }
            return mockOpportunityScoreService;
        }
        set;
    }

    public OpportunityScoreHelperServiceImpl mockOpportunityScoreHelperService {
        get {
            if (mockOpportunityScoreHelperService == null) {
                mockOpportunityScoreHelperService = (OpportunityScoreHelperServiceImpl) mocks.mock(
                    OpportunityScoreHelperServiceImpl.class
                );
                Application.Service.setMock(OpportunityScoreHelperServiceImpl.class, mockOpportunityScoreHelperService);
            }
            return mockOpportunityScoreHelperService;
        }
        set;
    }

    public OpportunityEIServiceImpl mockOpportunityEIService {
        get {
            if (mockOpportunityEIService == null) {
                mockOpportunityEIService = (OpportunityEIServiceImpl) mocks.mock(OpportunityEIServiceImpl.class);
                Application.Service.setMock(OpportunityEIServiceImpl.class, mockOpportunityEIService);
            }
            return mockOpportunityEIService;
        }
        set;
    }

    /******************************
     *       MOCK SELECTORS
     ******************************/

    public AccountPlanSelector mockAccountPlanSelector {
        get {
            if (mockAccountPlanSelector == null) {
                mockAccountPlanSelector = (AccountPlanSelector) FFLibHelper.mockSelector(
                    AccountPlanSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockAccountPlanSelector);
            }
            return mockAccountPlanSelector;
        }
        set;
    }

    public AccountPlanSharesSelector mockAccountPlanSharesSelector {
        get {
            if (mockAccountPlanSharesSelector == null) {
                mockAccountPlanSharesSelector = (AccountPlanSharesSelector) FFLibHelper.mockSelector(
                    AccountPlanSharesSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockAccountPlanSharesSelector);
            }
            return mockAccountPlanSharesSelector;
        }
        set;
    }

    public WhiteSpaceSelector mockWhiteSpaceSelector {
        get {
            if (mockWhiteSpaceSelector == null) {
                mockWhiteSpaceSelector = (WhiteSpaceSelector) FFLibHelper.mockSelector(WhiteSpaceSelector.class, mocks);
                Application.Selector.setMock(mockWhiteSpaceSelector);
            }
            return mockWhiteSpaceSelector;
        }
        set;
    }

    public WhiteSpaceColumnSelector mockWhiteSpaceColumnSelector {
        get {
            if (mockWhiteSpaceColumnSelector == null) {
                mockWhiteSpaceColumnSelector = (WhiteSpaceColumnSelector) FFLibHelper.mockSelector(
                    WhiteSpaceColumnSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWhiteSpaceColumnSelector);
            }
            return mockWhiteSpaceColumnSelector;
        }
        set;
    }

    public WhiteSpaceRowSelector mockWhiteSpaceRowSelector {
        get {
            if (mockWhiteSpaceRowSelector == null) {
                mockWhiteSpaceRowSelector = (WhiteSpaceRowSelector) FFLibHelper.mockSelector(
                    WhiteSpaceRowSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWhiteSpaceRowSelector);
            }
            return mockWhiteSpaceRowSelector;
        }
        set;
    }

    public WhiteSpaceCellSelector mockWhiteSpaceCellSelector {
        get {
            if (mockWhiteSpaceCellSelector == null) {
                mockWhiteSpaceCellSelector = (WhiteSpaceCellSelector) FFLibHelper.mockSelector(
                    WhiteSpaceCellSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWhiteSpaceCellSelector);
            }
            return mockWhiteSpaceCellSelector;
        }
        set;
    }

    public WhiteSpaceAmountTypeSelector mockWhiteSpaceAmountTypeSelector {
        get {
            if (mockWhiteSpaceAmountTypeSelector == null) {
                mockWhiteSpaceAmountTypeSelector = (WhiteSpaceAmountTypeSelector) FFLibHelper.mockSelector(
                    WhiteSpaceAmountTypeSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWhiteSpaceAmountTypeSelector);
            }
            return mockWhiteSpaceAmountTypeSelector;
        }
        set;
    }

    public WhiteSpaceAmountTypeAssociationSelector mockWhiteSpaceAmountTypeAssociationSelector {
        get {
            if (mockWhiteSpaceAmountTypeAssociationSelector == null) {
                mockWhiteSpaceAmountTypeAssociationSelector = (WhiteSpaceAmountTypeAssociationSelector) FFLibHelper.mockSelector(
                    WhiteSpaceAmountTypeAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWhiteSpaceAmountTypeAssociationSelector);
            }
            return mockWhiteSpaceAmountTypeAssociationSelector;
        }
        set;
    }

    public UserRecordAccessSelector mockUserRecordAccessSelector {
        get {
            if (mockUserRecordAccessSelector == null) {
                mockUserRecordAccessSelector = (UserRecordAccessSelector) FFLibHelper.mockSelector(
                    UserRecordAccessSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockUserRecordAccessSelector);
            }
            return mockUserRecordAccessSelector;
        }
        set;
    }

    public UsersSelector mockUsersSelector {
        get {
            if (mockUsersSelector == null) {
                mockUsersSelector = (UsersSelector) FFLibHelper.mockSelector(UsersSelector.class, mocks);
                Application.Selector.setMock(mockUsersSelector);
            }
            return mockUsersSelector;
        }
        set;
    }

    public WhiteSpaceTemplateCellFieldSelector mockWSTCellFieldSelector {
        get {
            if (mockWSTCellFieldSelector == null) {
                mockWSTCellFieldSelector = (WhiteSpaceTemplateCellFieldSelector) FFLibHelper.mockSelector(
                    WhiteSpaceTemplateCellFieldSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWSTCellFieldSelector);
            }
            return mockWSTCellFieldSelector;
        }
        set;
    }

    public MappingSelector mockMappingSelector {
        get {
            if (mockMappingSelector == null) {
                mockMappingSelector = (MappingSelector) FFLibHelper.mockSelector(MappingSelector.class, mocks);
                Application.Selector.setMock(mockMappingSelector);
            }
            return mockMappingSelector;
        }
        set;
    }

    public WhiteSpaceTemplateSelector mockWSTSelector {
        get {
            if (mockWSTSelector == null) {
                mockWSTSelector = (WhiteSpaceTemplateSelector) FFLibHelper.mockSelector(
                    WhiteSpaceTemplateSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWSTSelector);
            }
            return mockWSTSelector;
        }
        set;
    }

    public OrgChartFieldSelector mockOrgChartFieldSelector {
        get {
            if (mockOrgChartFieldSelector == null) {
                mockOrgChartFieldSelector = (OrgChartFieldSelector) FFLibHelper.mockSelector(
                    OrgChartFieldSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockOrgChartFieldSelector);
            }
            return mockOrgChartFieldSelector;
        }
        set;
    }

    public RelationshipMapMemberSelector mockRelationshipMapMemberSelector {
        get {
            if (mockRelationshipMapMemberSelector == null) {
                mockRelationshipMapMemberSelector = (RelationshipMapMemberSelector) FFLibHelper.mockSelector(
                    RelationshipMapMemberSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRelationshipMapMemberSelector);
            }
            return mockRelationshipMapMemberSelector;
        }
        set;
    }

    public ContactSelector mockContactSelector {
        get {
            if (mockContactSelector == null) {
                mockContactSelector = (ContactSelector) FFLibHelper.mockSelector(ContactSelector.class, mocks);
                Application.Selector.setMock(mockContactSelector);
            }
            return mockContactSelector;
        }
        set;
    }

    public ContactRelationshipSelector mockContactRelationshipSelector {
        get {
            if (mockContactRelationshipSelector == null) {
                mockContactRelationshipSelector = (ContactRelationshipSelector) FFLibHelper.mockSelector(
                    ContactRelationshipSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockContactRelationshipSelector);
            }
            return mockContactRelationshipSelector;
        }
        set;
    }

    public RelationshipGroupContactSelector mockRelationshipGroupContactSelector {
        get {
            if (mockRelationshipGroupContactSelector == null) {
                mockRelationshipGroupContactSelector = (RelationshipGroupContactSelector) FFLibHelper.mockSelector(
                    RelationshipGroupContactSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRelationshipGroupContactSelector);
            }
            return mockRelationshipGroupContactSelector;
        }
        set;
    }

    public RelationshipGroupSelector mockRelationshipGroupSelector {
        get {
            if (mockRelationshipGroupSelector == null) {
                mockRelationshipGroupSelector = (RelationshipGroupSelector) FFLibHelper.mockSelector(
                    RelationshipGroupSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRelationshipGroupSelector);
            }
            return mockRelationshipGroupSelector;
        }
        set;
    }

    public RelationshipGroupUserSelector mockRelationshipGroupUserSelector {
        get {
            if (mockRelationshipGroupUserSelector == null) {
                mockRelationshipGroupUserSelector = (RelationshipGroupUserSelector) FFLibHelper.mockSelector(
                    RelationshipGroupUserSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRelationshipGroupUserSelector);
            }
            return mockRelationshipGroupUserSelector;
        }
        set;
    }

    public RelationshipMapSelector mockRelationshipMapSelector {
        get {
            if (mockRelationshipMapSelector == null) {
                mockRelationshipMapSelector = (RelationshipMapSelector) FFLibHelper.mockSelector(
                    RelationshipMapSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRelationshipMapSelector);
            }
            return mockRelationshipMapSelector;
        }
        set;
    }

    public KeystakeholderSelector mockKeystakeholderSelector {
        get {
            if (mockKeystakeholderSelector == null) {
                mockKeystakeholderSelector = (KeystakeholderSelector) FFLibHelper.mockSelector(
                    KeystakeholderSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockKeystakeholderSelector);
            }
            return mockKeystakeholderSelector;
        }
        set;
    }

    public RMChartSettingSelector mockRMChartSettingSelector {
        get {
            if (mockRMChartSettingSelector == null) {
                mockRMChartSettingSelector = (RMChartSettingSelector) FFLibHelper.mockSelector(
                    RMChartSettingSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRMChartSettingSelector);
            }
            return mockRMChartSettingSelector;
        }
        set;
    }

    public MapMemberPlaceholderSelector mockMapMemberPlaceholderSelector {
        get {
            if (mockMapMemberPlaceholderSelector == null) {
                mockMapMemberPlaceholderSelector = (MapMemberPlaceholderSelector) FFLibHelper.mockSelector(
                    MapMemberPlaceholderSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockMapMemberPlaceholderSelector);
            }
            return mockMapMemberPlaceholderSelector;
        }
        set;
    }

    public MapMemberPlaceholderRelationshipSelector mockMapMemberPlaceholderRelationshipSelector {
        get {
            if (mockMapMemberPlaceholderRelationshipSelector == null) {
                mockMapMemberPlaceholderRelationshipSelector = (MapMemberPlaceholderRelationshipSelector) FFLibHelper.mockSelector(
                    MapMemberPlaceholderRelationshipSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockMapMemberPlaceholderRelationshipSelector);
            }
            return mockMapMemberPlaceholderRelationshipSelector;
        }
        set;
    }

    public RelationshipGroupPlaceholderSelector mockRelationshipGroupPlaceholderSelector {
        get {
            if (mockRelationshipGroupPlaceholderSelector == null) {
                mockRelationshipGroupPlaceholderSelector = (RelationshipGroupPlaceholderSelector) FFLibHelper.mockSelector(
                    RelationshipGroupPlaceholderSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRelationshipGroupPlaceholderSelector);
            }
            return mockRelationshipGroupPlaceholderSelector;
        }
        set;
    }

    public ContactRelationshipTypeSelector mockContactRelationshipTypeSelector {
        get {
            if (mockContactRelationshipTypeSelector == null) {
                mockContactRelationshipTypeSelector = (ContactRelationshipTypeSelector) FFLibHelper.mockSelector(
                    ContactRelationshipTypeSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockContactRelationshipTypeSelector);
            }
            return mockContactRelationshipTypeSelector;
        }
        set;
    }

    public RMAnchorSelector mockRMAnchorSelector {
        get {
            if (mockRMAnchorSelector == null) {
                mockRMAnchorSelector = (RMAnchorSelector) FFLibHelper.mockSelector(RMAnchorSelector.class, mocks);
                Application.Selector.setMock(mockRMAnchorSelector);
            }
            return mockRMAnchorSelector;
        }
        set;
    }

    public RMNodeCoordinateSelector mockRMNodeCoordinateSelector {
        get {
            if (mockRMNodeCoordinateSelector == null) {
                mockRMNodeCoordinateSelector = (RMNodeCoordinateSelector) FFLibHelper.mockSelector(
                    RMNodeCoordinateSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRMNodeCoordinateSelector);
            }
            return mockRMNodeCoordinateSelector;
        }
        set;
    }

    public WSHighlightSelector mockWSHighlightSelector {
        get {
            if (mockWSHighlightSelector == null) {
                mockWSHighlightSelector = (WSHighlightSelector) FFLibHelper.mockSelector(
                    WSHighlightSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWSHighlightSelector);
            }
            return mockWSHighlightSelector;
        }
        set;
    }

    public WSHighlightAssociationSelector mockWSHighlightAssociationSelector {
        get {
            if (mockWSHighlightAssociationSelector == null) {
                mockWSHighlightAssociationSelector = (WSHighlightAssociationSelector) FFLibHelper.mockSelector(
                    WSHighlightAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWSHighlightAssociationSelector);
            }
            return mockWSHighlightAssociationSelector;
        }
        set;
    }

    public WSSummaryFormulaSelector mockWSSummaryFormulaSelector {
        get {
            if (mockWSSummaryFormulaSelector == null) {
                mockWSSummaryFormulaSelector = (WSSummaryFormulaSelector) FFLibHelper.mockSelector(
                    WSSummaryFormulaSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWSSummaryFormulaSelector);
            }
            return mockWSSummaryFormulaSelector;
        }
        set;
    }

    public WSDataTypeSelector mockWSDataTypeSelector {
        get {
            if (mockWSDataTypeSelector == null) {
                mockWSDataTypeSelector = (WSDataTypeSelector) FFLibHelper.mockSelector(WSDataTypeSelector.class, mocks);
                Application.Selector.setMock(mockWSDataTypeSelector);
            }
            return mockWSDataTypeSelector;
        }
        set;
    }

    public WSDataTypeAssociationSelector mockWSDataTypeAssociationSelector {
        get {
            if (mockWSDataTypeAssociationSelector == null) {
                mockWSDataTypeAssociationSelector = (WSDataTypeAssociationSelector) FFLibHelper.mockSelector(
                    WSDataTypeAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWSDataTypeAssociationSelector);
            }
            return mockWSDataTypeAssociationSelector;
        }
        set;
    }

    public WSUserSettingSelector mockWSUserSettingSelector {
        get {
            if (mockWSUserSettingSelector == null) {
                mockWSUserSettingSelector = (WSUserSettingSelector) FFLibHelper.mockSelector(
                    WSUserSettingSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWSUserSettingSelector);
            }
            return mockWSUserSettingSelector;
        }
        set;
    }

    public ContactExtendedFieldSelector mockContactExtendedFieldSelector {
        get {
            if (mockContactExtendedFieldSelector == null) {
                mockContactExtendedFieldSelector = (ContactExtendedFieldSelector) FFLibHelper.mockSelector(
                    ContactExtendedFieldSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockContactExtendedFieldSelector);
            }
            return mockContactExtendedFieldSelector;
        }
        set;
    }

    public RMOrgSettingSelector mockRMOrgSettingSelector {
        get {
            if (mockRMOrgSettingSelector == null) {
                mockRMOrgSettingSelector = (RMOrgSettingSelector) FFLibHelper.mockSelector(
                    RMOrgSettingSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRMOrgSettingSelector);
            }
            return mockRMOrgSettingSelector;
        }
        set;
    }

    public OpportunityListUserFilterSelector mockOpportunityListUserFilterSelector {
        get {
            if (mockOpportunityListUserFilterSelector == null) {
                mockOpportunityListUserFilterSelector = (OpportunityListUserFilterSelector) FFLibHelper.mockSelector(
                    OpportunityListUserFilterSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockOpportunityListUserFilterSelector);
            }
            return mockOpportunityListUserFilterSelector;
        }
        set;
    }

    public RMSvgSelector mockRMSvgSelector {
        get {
            if (mockRMSvgSelector == null) {
                mockRMSvgSelector = (RMSvgSelector) FFLibHelper.mockSelector(RMSvgSelector.class, mocks);
                Application.Selector.setMock(mockRMSvgSelector);
            }
            return mockRMSvgSelector;
        }
        set;
    }

    public RMSvgNodeAssociationSelector mockRMSvgNodeAssociationSelector {
        get {
            if (mockRMSvgNodeAssociationSelector == null) {
                mockRMSvgNodeAssociationSelector = (RMSvgNodeAssociationSelector) FFLibHelper.mockSelector(
                    RMSvgNodeAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRMSvgNodeAssociationSelector);
            }
            return mockRMSvgNodeAssociationSelector;
        }
        set;
    }

    public MapMemberLeadSelector mockMapMemberLeadSelector {
        get {
            if (mockMapMemberLeadSelector == null) {
                mockMapMemberLeadSelector = (MapMemberLeadSelector) FFLibHelper.mockSelector(
                    MapMemberLeadSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockMapMemberLeadSelector);
            }
            return mockMapMemberLeadSelector;
        }
        set;
    }

    public KeyStakeholderLeadSelector mockKeyStakeholderLeadSelector {
        get {
            if (mockKeyStakeholderLeadSelector == null) {
                mockKeyStakeholderLeadSelector = (KeyStakeholderLeadSelector) FFLibHelper.mockSelector(
                    KeyStakeholderLeadSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockKeyStakeholderLeadSelector);
            }
            return mockKeyStakeholderLeadSelector;
        }
        set;
    }

    public RelationshipGroupLeadSelector mockRelationshipGroupLeadSelector {
        get {
            if (mockRelationshipGroupLeadSelector == null) {
                mockRelationshipGroupLeadSelector = (RelationshipGroupLeadSelector) FFLibHelper.mockSelector(
                    RelationshipGroupLeadSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRelationshipGroupLeadSelector);
            }
            return mockRelationshipGroupLeadSelector;
        }
        set;
    }

    public WSCellRelationshipConfigSelector mockWSCellRelationshipConfigSelector {
        get {
            if (mockWSCellRelationshipConfigSelector == null) {
                mockWSCellRelationshipConfigSelector = (WSCellRelationshipConfigSelector) FFLibHelper.mockSelector(
                    WSCellRelationshipConfigSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockWSCellRelationshipConfigSelector);
            }
            return mockWSCellRelationshipConfigSelector;
        }
        set;
    }

    public RMMatrixAssociationSelector mockRMMatrixAssociationSelector {
        get {
            if (mockRMMatrixAssociationSelector == null) {
                mockRMMatrixAssociationSelector = (RMMatrixAssociationSelector) FFLibHelper.mockSelector(
                    RMMatrixAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRMMatrixAssociationSelector);
            }
            return mockRMMatrixAssociationSelector;
        }
        set;
    }

    public AccountPlanMatrixAssociationSelector mockAccountPlanMatrixAssociationSelector {
        get {
            if (mockAccountPlanMatrixAssociationSelector == null) {
                mockAccountPlanMatrixAssociationSelector = (AccountPlanMatrixAssociationSelector) FFLibHelper.mockSelector(
                    AccountPlanMatrixAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockAccountPlanMatrixAssociationSelector);
            }
            return mockAccountPlanMatrixAssociationSelector;
        }
        set;
    }

    public InfluenceMatrixAssociationSelector mockInfluenceMatrixAssociationSelector {
        get {
            if (mockInfluenceMatrixAssociationSelector == null) {
                mockInfluenceMatrixAssociationSelector = (InfluenceMatrixAssociationSelector) FFLibHelper.mockSelector(
                    InfluenceMatrixAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockInfluenceMatrixAssociationSelector);
            }
            return mockInfluenceMatrixAssociationSelector;
        }
        set;
    }

    public SupportMatrixAssociationSelector mockSupportMatrixAssociationSelector {
        get {
            if (mockSupportMatrixAssociationSelector == null) {
                mockSupportMatrixAssociationSelector = (SupportMatrixAssociationSelector) FFLibHelper.mockSelector(
                    SupportMatrixAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockSupportMatrixAssociationSelector);
            }
            return mockSupportMatrixAssociationSelector;
        }
        set;
    }

    public InfluenceSupportMatrixSelector mockInfluenceSupportMatrixSelector {
        get {
            if (mockInfluenceSupportMatrixSelector == null) {
                mockInfluenceSupportMatrixSelector = (InfluenceSupportMatrixSelector) FFLibHelper.mockSelector(
                    InfluenceSupportMatrixSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockInfluenceSupportMatrixSelector);
            }
            return mockInfluenceSupportMatrixSelector;
        }
        set;
    }

    public InfluenceSelector mockInfluenceSelector {
        get {
            if (mockInfluenceSelector == null) {
                mockInfluenceSelector = (InfluenceSelector) FFLibHelper.mockSelector(InfluenceSelector.class, mocks);
                Application.Selector.setMock(mockInfluenceSelector);
            }
            return mockInfluenceSelector;
        }
        set;
    }

    public SupportSelector mockSupportSelector {
        get {
            if (mockSupportSelector == null) {
                mockSupportSelector = (SupportSelector) FFLibHelper.mockSelector(SupportSelector.class, mocks);
                Application.Selector.setMock(mockSupportSelector);
            }
            return mockSupportSelector;
        }
        set;
    }

    public TasksSelector mockTasksSelector {
        get {
            if (mockTasksSelector == null) {
                mockTasksSelector = (TasksSelector) FFLibHelper.mockSelector(TasksSelector.class, mocks);
                Application.Selector.setMock(mockTasksSelector);
            }
            return mockTasksSelector;
        }
        set;
    }

    public ObjectiveSelector mockObjectiveSelector {
        get {
            if (mockObjectiveSelector == null) {
                mockObjectiveSelector = (ObjectiveSelector) FFLibHelper.mockSelector(ObjectiveSelector.class, mocks);
                Application.Selector.setMock(mockObjectiveSelector);
            }
            return mockObjectiveSelector;
        }
        set;
    }

    public ObjectiveTaskAssociationSelector mockObjectiveTaskAssociationSelector {
        get {
            if (mockObjectiveTaskAssociationSelector == null) {
                mockObjectiveTaskAssociationSelector = (ObjectiveTaskAssociationSelector) FFLibHelper.mockSelector(
                    ObjectiveTaskAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockObjectiveTaskAssociationSelector);
            }
            return mockObjectiveTaskAssociationSelector;
        }
        set;
    }

    public AccountPlanUserSettingSelector mockAccountPlanUserSettingSelector {
        get {
            if (mockAccountPlanUserSettingSelector == null) {
                mockAccountPlanUserSettingSelector = (AccountPlanUserSettingSelector) FFLibHelper.mockSelector(
                    AccountPlanUserSettingSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockAccountPlanUserSettingSelector);
            }
            return mockAccountPlanUserSettingSelector;
        }
        set;
    }

    public PlanOverviewSelector mockPlanOverviewSelector {
        get {
            if (mockPlanOverviewSelector == null) {
                mockPlanOverviewSelector = (PlanOverviewSelector) FFLibHelper.mockSelector(
                    PlanOverviewSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockPlanOverviewSelector);
            }
            return mockPlanOverviewSelector;
        }
        set;
    }

    public TeamMemberSelector mockTeamMemberSelector {
        get {
            if (mockTeamMemberSelector == null) {
                mockTeamMemberSelector = (TeamMemberSelector) FFLibHelper.mockSelector(TeamMemberSelector.class, mocks);
                Application.Selector.setMock(mockTeamMemberSelector);
            }
            return mockTeamMemberSelector;
        }
        set;
    }

    public HealthScoreMetadataSelector mockHealthScoreMetadataSelector {
        get {
            if (mockHealthScoreMetadataSelector == null) {
                mockHealthScoreMetadataSelector = (HealthScoreMetadataSelector) FFLibHelper.mockSelector(
                    HealthScoreMetadataSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockHealthScoreMetadataSelector);
            }
            return mockHealthScoreMetadataSelector;
        }
        set;
    }

    public LeadSelector mockLeadSelector {
        get {
            if (mockLeadSelector == null) {
                mockLeadSelector = (LeadSelector) FFLibHelper.mockSelector(LeadSelector.class, mocks);
                Application.Selector.setMock(mockLeadSelector);
            }
            return mockLeadSelector;
        }
        set;
    }

    public OpportunityContactRoleSelector mockOpportunityContactRoleSelector {
        get {
            if (mockOpportunityContactRoleSelector == null) {
                mockOpportunityContactRoleSelector = (OpportunityContactRoleSelector) FFLibHelper.mockSelector(
                    OpportunityContactRoleSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockOpportunityContactRoleSelector);
            }
            return mockOpportunityContactRoleSelector;
        }
        set;
    }

    public CampaignMemberSelector mockCampaignMemberSelector {
        get {
            if (mockCampaignMemberSelector == null) {
                mockCampaignMemberSelector = (CampaignMemberSelector) FFLibHelper.mockSelector(
                    CampaignMemberSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockCampaignMemberSelector);
            }
            return mockCampaignMemberSelector;
        }
        set;
    }

    public CrushUserSettingSelector mockCrushUserSettingSelector {
        get {
            if (mockCrushUserSettingSelector == null) {
                mockCrushUserSettingSelector = (CrushUserSettingSelector) FFLibHelper.mockSelector(
                    CrushUserSettingSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockCrushUserSettingSelector);
            }
            return mockCrushUserSettingSelector;
        }
        set;
    }

    public MasterAccountPlanSelector mockMasterAccountPlanSelector {
        get {
            if (mockMasterAccountPlanSelector == null) {
                mockMasterAccountPlanSelector = (MasterAccountPlanSelector) FFLibHelper.mockSelector(
                    MasterAccountPlanSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockMasterAccountPlanSelector);
            }
            return mockMasterAccountPlanSelector;
        }
        set;
    }

    public MasterAccountPlanAssociationSelector mockMasterAccountPlanAssociationSelector {
        get {
            if (mockMasterAccountPlanAssociationSelector == null) {
                mockMasterAccountPlanAssociationSelector = (MasterAccountPlanAssociationSelector) FFLibHelper.mockSelector(
                    MasterAccountPlanAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockMasterAccountPlanAssociationSelector);
            }
            return mockMasterAccountPlanAssociationSelector;
        }
        set;
    }

    public MAsterAccountPlanUserSettingSelector mockMAsterAccountPlanUserSettingSelector {
        get {
            if (mockMAsterAccountPlanUserSettingSelector == null) {
                mockMAsterAccountPlanUserSettingSelector = (MAsterAccountPlanUserSettingSelector) FFLibHelper.mockSelector(
                    MAsterAccountPlanUserSettingSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockMAsterAccountPlanUserSettingSelector);
            }
            return mockMAsterAccountPlanUserSettingSelector;
        }
        set;
    }

    public AccountPlanScoreHistorySelector mockAccountPlanScoreHistorySelector {
        get {
            if (mockAccountPlanScoreHistorySelector == null) {
                mockAccountPlanScoreHistorySelector = (AccountPlanScoreHistorySelector) FFLibHelper.mockSelector(
                    AccountPlanScoreHistorySelector.class,
                    mocks
                );
                Application.Selector.setMock(mockAccountPlanScoreHistorySelector);
            }
            return mockAccountPlanScoreHistorySelector;
        }
        set;
    }

    public OpportunityPlanSelector mockOpportunityPlanSelector {
        get {
            if (mockOpportunityPlanSelector == null) {
                mockOpportunityPlanSelector = (OpportunityPlanSelector) FFLibHelper.mockSelector(
                    OpportunityPlanSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockOpportunityPlanSelector);
            }
            return mockOpportunityPlanSelector;
        }
        set;
    }

    public RMMAutoHistorySelector mockRMMAutoHistorySelector {
        get {
            if (mockRMMAutoHistorySelector == null) {
                mockRMMAutoHistorySelector = (RMMAutoHistorySelector) FFLibHelper.mockSelector(
                    RMMAutoHistorySelector.class,
                    mocks
                );
                Application.Selector.setMock(mockRMMAutoHistorySelector);
            }
            return mockRMMAutoHistorySelector;
        }
        set;
    }

    public OpportunityEffectivenessIndexSelector mockOpportunityEffectivenessIndexSelector {
        get {
            if (mockOpportunityEffectivenessIndexSelector == null) {
                mockOpportunityEffectivenessIndexSelector = (OpportunityEffectivenessIndexSelector) FFLibHelper.mockSelector(
                    OpportunityEffectivenessIndexSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockOpportunityEffectivenessIndexSelector);
            }
            return mockOpportunityEffectivenessIndexSelector;
        }
        set;
    }

    public OpportunityEIAssociationSelector mockOpportunityEIAssociationSelector {
        get {
            if (mockOpportunityEIAssociationSelector == null) {
                mockOpportunityEIAssociationSelector = (OpportunityEIAssociationSelector) FFLibHelper.mockSelector(
                    OpportunityEIAssociationSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockOpportunityEIAssociationSelector);
            }
            return mockOpportunityEIAssociationSelector;
        }
        set;
    }

    public OpportunityManagerSettingSelector mockOpportunityManagerSettingSelector {
        get {
            if (mockOpportunityManagerSettingSelector == null) {
                mockOpportunityManagerSettingSelector = (OpportunityManagerSettingSelector) FFLibHelper.mockSelector(
                    OpportunityManagerSettingSelector.class,
                    mocks
                );
                Application.Selector.setMock(mockOpportunityManagerSettingSelector);
            }
            return mockOpportunityManagerSettingSelector;
        }
        set;
    }

    /******************************
     *       MOCK DOMAIN
     ******************************/

    public RelationshipMapMembers mockRelationshipMapMembersDomain {
        get {
            if (mockRelationshipMapMembersDomain == null) {
                mockRelationshipMapMembersDomain = (RelationshipMapMembers) FFLibHelper.mockDomain(
                    Relationship_Map_Member__c.getSObjectType(),
                    RelationshipMapMembers.class,
                    mocks
                );
                Application.Domain.setMock((fflib_ISObjectDomain) mockRelationshipMapMembersDomain);
            }
            return mockRelationshipMapMembersDomain;
        }
        set;
    }

    public AccountPlanShares mockAccountPlanSharesDomain {
        get {
            if (mockAccountPlanSharesDomain == null) {
                mockAccountPlanSharesDomain = (AccountPlanShares) FFLibHelper.mockDomain(
                    Account_Plan__Share.sObjectType,
                    AccountPlanShares.class,
                    mocks
                );
                Application.Domain.setMock((fflib_ISObjectDomain) mockAccountPlanSharesDomain);
            }
            return mockAccountPlanSharesDomain;
        }
        set;
    }
}