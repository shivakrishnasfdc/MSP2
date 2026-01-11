@SuppressWarnings('PMD.ExcessivePublicCount')
@isTest
public with sharing class TestDataFactory {
    public static User createUser(String firstName, String lastName, Id profileId) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while (randomString.length() < 4) {
            Integer i = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randomString += chars.substring(i, i + 1);
        }

        String alias = firstName.charAt(0) + lastName;
        String nameDirty = firstName + '.' + lastName;
        String name = nameDirty.replace(' ', '');
        User user = new User(
            Alias = alias.length() > 8 ? alias.substring(0, 8) : alias,
            Email = name + '@example.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = firstName,
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = name + '.' + randomString + '@example.com'
        );

        insert user;
        return user;
    }

    public static PermissionSetAssignment createPermissionSetAssignment(Id userId, Id permissionSetId) {
        PermissionSetAssignment result = null;
        Boolean needsPermission = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId AND PermissionSetId = :permissionSetId
            ]
            .isEmpty();

        if (needsPermission) {
            result = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSetId);
        }

        return result;
    }

    public static Account createAccount(String name) {
        Account account = new Account(Name = name);
        insert account;
        return account;
    }

    public static Account_Plan__c createAccountPlan(String name) {
        return createAccountPlan(name, createAccount('ACME'), 'Open');
    }

    public static Account_Plan__c createAccountPlan(String name, Account account) {
        return createAccountPlan(name, account, 'Open');
    }

    public static Account_Plan__c createAccountPlan(String name, Account account, String status) {
        Account_Plan__c accountPlan = new Account_Plan__c(Name = name, Account__c = account.Id, Status__c = status);

        insert accountPlan;
        return accountPlan;
    }

    public static Account_Plan__c createAccountPlan(String name, Account account, User owner, String status) {
        Account_Plan__c accountPlan = new Account_Plan__c(
            Name = name,
            Account__c = account.Id,
            Status__c = status,
            OwnerId = owner.Id
        );

        insert accountPlan;
        return accountPlan;
    }

    public static Opportunity createOpportunity(Account testAccount, String name) {
        return new Opportunity(
            AccountId = testAccount.Id,
            Name = name,
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
    }

    public static Opportunity createOpportunity(String name) {
        return createOpportunity(createAccount('ACME'), name);
    }

    public static PQ_Opportunity_Plan__c createOpportunityPlan(Opportunity testOpportunity) {
        String oppName = 'Plan - ' + testOpportunity.Name;
        oppName = oppName.length() > 80 ? oppName.substring(0, 80) : oppName;
        PQ_Opportunity_Plan__c oppPlan = new PQ_Opportunity_Plan__c(
            Name = oppName,
            Opportunity__c = testOpportunity.Id
        );
        insert oppPlan;
        return oppPlan;
    }

    public static Relationship_Map_Member_Auto_History__c createRelationshipMapMemberAutoHistory(
        Relationship_Map__c rm,
        Contact c
    ) {
        Relationship_Map_Member_Auto_History__c history = new Relationship_Map_Member_Auto_History__c(
            RelationshipMapId__c = rm.Id,
            ContactId__c = c.Id
        );
        insert history;
        return history;
    }

    public static Objective_Opportunity__c createObjectiveOpportunity(
        Objective__c testObjective,
        Opportunity testOpportunity
    ) {
        return new Objective_Opportunity__c(Objective__c = testObjective.Id, Opportunity__c = testOpportunity.Id);
    }

    public static Account_Plan_Opportunity__c createAccountPlanOpportunity(
        Account_Plan__c testAccountPlan,
        Opportunity testOpportunity
    ) {
        return new Account_Plan_Opportunity__c(
            Account_Plan__c = testAccountPlan.Id,
            Opportunity__c = testOpportunity.Id
        );
    }

    public static Key_Stakeholder__c createKeyStakeholder(Account_Plan__c accountPlan, Contact contact) {
        Key_Stakeholder__c stakeholder = new Key_Stakeholder__c(
            Account_Plan__c = accountPlan.Id,
            Contact__c = contact.Id,
            Influence__c = 'High',
            Support__c = 'Floater'
        );

        insert stakeholder;
        return stakeholder;
    }

    public static Key_Stakeholder__c createKeyStakeholder(
        Account_Plan__c accountPlan,
        Contact contact,
        Id influenceId,
        Id supportId
    ) {
        Key_Stakeholder__c stakeholder = new Key_Stakeholder__c(
            Account_Plan__c = accountPlan.Id,
            Contact__c = contact.Id,
            InfluenceId__c = influenceId,
            SupportId__c = supportId
        );

        insert stakeholder;
        return stakeholder;
    }

    public static Account_Plan__Share createAccountPlanShare(
        User user,
        Account_Plan__c accountPlan,
        String accessLevel
    ) {
        return createAccountPlanShare(
            user,
            accountPlan,
            accessLevel,
            Schema.Account_Plan__Share.RowCause.Account_Plan_Team__c
        );
    }

    public static Account_Plan__Share createAccountPlanShare(
        User user,
        Account_Plan__c accountPlan,
        String accessLevel,
        String shareReason
    ) {
        Account_Plan__Share accountPlanShare = new Account_Plan__Share(
            ParentId = accountPlan.Id,
            UserOrGroupId = user.Id,
            AccessLevel = accessLevel,
            RowCause = shareReason
        );

        insert accountPlanShare;
        return accountPlanShare;
    }

    public static Team_Member__c createTeamMember(User user, Account_Plan__c accountPlan, String role) {
        Team_Member__c teamMember = new Team_Member__c(
            Account_Plan__c = accountPlan.Id,
            User__c = user.Id,
            Role__c = role
        );

        insert teamMember;
        return teamMember;
    }

    public static Task createTask(String subject, User owner, Account_Plan__c accountPlan) {
        Task newTask = new Task(Subject = subject, WhatId = accountPlan.Id, OwnerId = owner.Id);

        insert newTask;
        return newTask;
    }

    public static Objective__c createObjective(Account_Plan__c accountPlan, String name) {
        return createObjective(accountPlan, name, null);
    }

    public static Objective__c createObjective(Account_Plan__c accountPlan, String name, String description) {
        Objective__c newObjective = new Objective__c(
            Account_Plan__c = accountPlan.Id,
            Name = name,
            Description__c = description
        );

        insert newObjective;
        return newObjective;
    }

    public static Contact createContact(String firstName, String lastName) {
        Contact contact = new Contact(FirstName = firstName, LastName = lastName);

        insert contact;
        return contact;
    }

    public static Contact_Relationship__c createContactRelationship(
        Contact fromContact,
        contact toContact,
        String tempKey
    ) {
        return createContactRelationship(fromContact, toContact, tempKey, null, null, null);
    }

    public static Contact_Relationship__c createContactRelationship(
        Contact fromContact,
        contact toContact,
        String tempKey,
        Id relType,
        Id accountPlan,
        Id relMap
    ) {
        Contact_Relationship__c contactRelationship = new Contact_Relationship__c(
            From_Contact__c = fromContact.Id,
            To_Contact__c = toContact.Id,
            TempId__c = tempKey,
            Contact_Relationship_Type__c = relType,
            Relationship_Map__c = relMap,
            Account_Plan__c = accountPlan
        );

        insert contactRelationship;
        return contactRelationship;
    }

    public static Key_Date__c createKeyDate(Account_Plan__c accountPlan, String name) {
        return createKeyDate(accountPlan, name, Date.today());
    }

    public static Key_Date__c createKeyDate(Account_Plan__c accountPlan, String name, Date keyDate) {
        return new Key_Date__c(Account_Plan__c = accountPlan.Id, Date__c = keyDate, Name = name);
    }

    public static Key_Date__c createKeyDate(Account_Plan__c accountPlan, String name, Date keyDate, String reminder) {
        return new Key_Date__c(
            Account_Plan__c = accountPlan.Id,
            Date__c = keyDate,
            Name = name,
            Reminder__c = reminder
        );
    }

    public static EmailTemplate createEmailTemplate(String name) {
        return new EmailTemplate(
            IsActive = true,
            Name = name,
            DeveloperName = name,
            TemplateType = 'text',
            FolderId = UserInfo.getUserId()
        );
    }

    public static White_Space__c createWhiteSpace(String name) {
        Account_Plan__c accountPlan = createAccountPlan('my plan');
        White_Space__c ws = new White_Space__c(
            Account_Plan__c = accountPlan.Id,
            AreUnrelatedCellsFiltered__c = false,
            Name = name
        );

        insert ws;
        return ws;
    }

    public static White_Space__c createWhiteSpace(Account_Plan__c accountPlan, String name) {
        White_Space__c ws = new White_Space__c(
            Account_Plan__c = accountPlan.Id,
            AreUnrelatedCellsFiltered__c = false,
            Name = name
        );

        insert ws;
        return ws;
    }

    public static White_Space__c createWhiteSpaceFromTemplate(
        Account_Plan__c accountPlan,
        White_Space_Template__c template,
        String name
    ) {
        White_Space__c ws = new White_Space__c(
            Account_Plan__c = accountPlan.Id,
            White_Space_Template__c = template.Id,
            AreUnrelatedCellsFiltered__c = false,
            Name = name
        );

        insert ws;
        return ws;
    }

    public static White_Space_Row__c createWhiteSpaceRow(White_Space__c whiteSpace, String rowName) {
        White_Space_Row__c wsRow = new White_Space_Row__c(White_Space__c = whiteSpace.Id, Name = rowName);

        insert wsRow;
        return wsRow;
    }

    public static White_Space_Column__c createWhiteSpaceColumn(White_Space__c whiteSpace, String columnName) {
        White_Space_Column__c wsColumn = new White_Space_Column__c(White_Space__c = whiteSpace.Id, Name = columnName);

        insert wsColumn;
        return wsColumn;
    }

    public static List<White_Space_Cell__c> createWhiteSpaceCells(
        Id whiteSpaceId,
        Set<Id> whiteSpaceColumnIds,
        Set<Id> whiteSpaceRowIds
    ) {
        List<White_Space_Cell__c> newCells = new List<White_Space_Cell__c>();
        for (Id colId : whiteSpaceColumnIds) {
            for (Id rowId : whiteSpaceRowIds) {
                newCells.add(
                    new White_Space_Cell__c(
                        White_Space__c = whiteSpaceId,
                        White_Space_Column__c = colId,
                        White_Space_Row__c = rowId
                    )
                );
            }
        }
        insert newCells;
        return newCells;
    }

    public static White_Space_Amount_Type__c createWhiteSpaceAmountType(String name) {
        White_Space_Amount_Type__c amountType = new White_Space_Amount_Type__c(Name = name, Color_RGB__c = '#0000ff');
        insert amountType;
        return amountType;
    }

    public static White_Space_Amount_Type__c createWhiteSpaceAmountType(String name, Boolean isActive) {
        White_Space_Amount_Type__c amountType = new White_Space_Amount_Type__c(
            Name = name,
            IsActive__c = isActive,
            Color_RGB__c = '#0000ff'
        );
        insert amountType;
        return amountType;
    }

    public static White_Space_Amount_Type_Association__c createWhiteSpaceAmountTypeAssociation(
        Id amountTypeId,
        Id cellId
    ) {
        White_Space_Amount_Type_Association__c association = new White_Space_Amount_Type_Association__c(
            Amount__c = 15,
            White_Space_Amount_Type__c = amountTypeId,
            White_Space_Cell__c = cellId
        );
        insert association;
        return association;
    }

    public static White_Space_Template__c createLegacyWhiteSpaceTemplate(
        String templateName,
        String columnObjectName,
        String columnLabelFieldName,
        String rowObjectName,
        String rowLabelFieldName
    ) {
        White_Space_Template__c template = new White_Space_Template__c(
            Name = templateName,
            Column_Object_Name__c = columnObjectName,
            Column_Label_Field_Name__c = columnLabelFieldName,
            Row_Object_Name__c = rowObjectName,
            Row_Label_Field_Name__c = rowLabelFieldName
        );
        insert template;
        return template;
    }

    public static White_Space_Template__c createWhiteSpaceTemplate(
        String templateName,
        String columnObjectName,
        String columnLabelFieldName,
        String rowObjectName,
        String rowLabelFieldName
    ) {
        return createWhiteSpaceTemplate(
            templateName,
            columnObjectName,
            columnLabelFieldName,
            null,
            rowObjectName,
            rowLabelFieldName,
            null
        );
    }

    public static White_Space_Template__c createWhiteSpaceTemplate(
        String templateName,
        String columnObjectName,
        String columnLabelFieldName,
        String columnParentRelationship,
        String rowObjectName,
        String rowLabelFieldName,
        String rowParentRelationship
    ) {
        Mapping__c rowMapping = createMapping(
            'row',
            rowObjectName,
            rowLabelFieldName,
            rowLabelFieldName,
            rowParentRelationship
        );
        Mapping__c columnMapping = createMapping(
            'column',
            columnObjectName,
            columnLabelFieldName,
            columnLabelFieldName,
            columnParentRelationship
        );
        White_Space_Template__c template = new White_Space_Template__c(
            Name = templateName,
            RowMapping__c = rowMapping.Id,
            RowMapping__r = rowMapping,
            ColumnMapping__c = columnMapping.Id,
            ColumnMapping__r = columnMapping,
            Column_Object_Name__c = columnObjectName,
            Column_Label_Field_Name__c = columnLabelFieldName,
            Row_Object_Name__c = rowObjectName,
            Row_Label_Field_Name__c = rowLabelFieldName
        );
        insert template;
        return template;
    }

    public static White_Space_Template__c createWhiteSpaceTemplate(
        String templateName,
        Mapping__c columnMapping,
        Mapping__c rowMapping
    ) {
        insert new List<Mapping__c>{ columnMapping, rowMapping };

        White_Space_Template__c template = new White_Space_Template__c(
            Name = templateName,
            RowMapping__c = rowMapping.Id,
            RowMapping__r = rowMapping,
            ColumnMapping__c = columnMapping.Id,
            ColumnMapping__r = columnMapping
        );
        insert template;
        return template;
    }

    public static Mapping__c createMapping(String name, String objectType, String labelField, String valueField) {
        return createMapping(name, objectType, labelField, valueField, null);
    }

    public static Mapping__c createMapping(
        String name,
        String objectType,
        String labelField,
        String valueField,
        String parentField
    ) {
        Mapping__c mapping = new Mapping__c(
            Name = name,
            DisplayLabelField__c = labelField,
            ObjectType__c = objectType,
            ValueField__c = valueField,
            GroupResults__c = false,
            ParentField__c = parentField
        );
        insert mapping;
        return mapping;
    }

    public static Mapping_Condition_Group__c createConditionGroup(Mapping__c mapping, String operator) {
        Mapping_Condition_Group__c conditionGroup = new Mapping_Condition_Group__c(
            Mapping__c = mapping.Id,
            Operator__c = operator
        );
        insert conditionGroup;
        return conditionGroup;
    }

    public static Mapping_Condition__c createCondition(
        String field,
        String operator,
        String value,
        Mapping_Condition_Group__c conditionGroup
    ) {
        Mapping_Condition__c condition = new Mapping_Condition__c(
            Field__c = field,
            Operator__c = operator,
            Value__c = value,
            Condition_Group__c = conditionGroup.Id
        );
        insert condition;
        return condition;
    }

    public static White_Space_Template_Cell_Field__c createWhiteSpaceTemplateCellField(
        String name,
        String displayFieldId,
        Id valueMappingId,
        Id templateId
    ) {
        White_Space_Template_Cell_Field__c cellField = new White_Space_Template_Cell_Field__c(
            Name = name,
            displayFieldId__c = displayFieldId,
            ValueMapping__c = valueMappingId,
            WhiteSpaceTemplate__c = templateId
        );
        insert cellField;
        return cellField;
    }

    public static Relationship_Group__c createRelationshipGroup(String name) {
        Relationship_Group__c relGroup = new Relationship_Group__c(Name = name, Label__c = name);
        insert relGroup;
        return relGroup;
    }

    public static Relationship_Group__c createRelationshipGroup(String name, String tempId) {
        Relationship_Group__c relGroup = new Relationship_Group__c(Name = name, Label__c = name, TempId__c = tempId);
        insert relGroup;
        return relGroup;
    }

    public static Relationship_Group__c createRelationshipGroupForMap(String name, Id relationshipMapId) {
        Relationship_Group__c relGroup = new Relationship_Group__c(
            Name = name,
            Label__c = name,
            Relationship_Map__c = relationshipMapId
        );
        insert relGroup;
        return relGroup;
    }

    public static Relationship_Group__c createRelationshipGroupForAccountPlan(String name, Id accountPlanId) {
        Relationship_Group__c relGroup = new Relationship_Group__c(
            Name = name,
            Label__c = name,
            Account_Plan__c = accountPlanId
        );
        insert relGroup;
        return relGroup;
    }

    public static Relationship_Group_Contact_Association__c createRelationshipGroupContactAssoc(
        Id contactId,
        Id groupId
    ) {
        Relationship_Group_Contact_Association__c relGroupAssoc = new Relationship_Group_Contact_Association__c(
            Contact__c = contactId,
            Relationship_Group__c = groupId
        );
        insert relGroupAssoc;
        return relGroupAssoc;
    }

    public static Relationship_Group_Placeholder_Assoc__c createRelationshipGroupPlaceholderAssoc(
        Id placeholderId,
        Id groupId
    ) {
        Relationship_Group_Placeholder_Assoc__c relGroupAssoc = new Relationship_Group_Placeholder_Assoc__c(
            Map_Member_Placeholder__c = placeholderId,
            Relationship_Group__c = groupId
        );
        insert relGroupAssoc;
        return relGroupAssoc;
    }

    public static Relationship_Map__c createRelationshipMap(String name) {
        return createRelationshipMap(name, null);
    }

    public static Relationship_Map__c createRelationshipMap(String name, Id accountPlanId) {
        return createRelationshipMap(name, accountPlanId, null);
    }

    public static Relationship_Map__c createRelationshipMap(String name, Id accountPlanId, Id opportunityPlanId) {
        Relationship_Map__c relMap = new Relationship_Map__c(
            Name = name,
            pq_AccountPlanId__c = accountPlanId,
            pq_Opportunity_Plan__c = opportunityPlanId
        );
        insert relMap;
        return relMap;
    }

    public static Relationship_Map_Member__c createRelationshipMapMember(Id groupId, Id contactId) {
        return createRelationshipMapMember(groupId, contactId, null, null);
    }

    public static Relationship_Map_Member__c createRelationshipMapMember(
        Id groupId,
        Id contactId,
        String influence,
        String support
    ) {
        Relationship_Map_Member__c member = new Relationship_Map_Member__c(
            Relationship_Map__c = groupId,
            Contact__c = contactId,
            Influence__c = influence,
            Support__c = support
        );
        insert member;
        return member;
    }

    public static Map_Member_User__c createMapMemberUser(Relationship_Map__c rm, User u) {
        Map_Member_User__c member = new Map_Member_User__c(Relationship_Map__c = rm.Id, User__c = u.Id);
        insert member;
        return member;
    }

    public static RM_Chart_Setting__C createRMChartSetting(String description, Boolean showParents) {
        RM_Chart_Setting__C setting = new RM_Chart_Setting__C(
            Description__c = description,
            Show_Parents__c = showParents
        );
        insert setting;
        return setting;
    }

    public static RM_Chart_Setting__c createRMChartSetting(
        String description,
        Boolean showParents,
        Id accountPlanId,
        Id relMapId
    ) {
        RM_Chart_Setting__c setting = new RM_Chart_Setting__c(
            Description__c = description,
            Show_Parents__c = showParents,
            Account_Plan__c = accountPlanId,
            Relationship_Map__c = relMapId
        );
        insert setting;
        return setting;
    }

    public static RM_Org_Setting__c createRMOrgSetting(
        String type,
        Boolean autoLayout,
        String cardStyle,
        String displayStyle
    ) {
        RM_Org_Setting__c setting = new RM_Org_Setting__c(
            Type__c = type,
            Auto_Layout__c = autoLayout,
            Card_Style__c = cardStyle,
            Display_Style__c = displayStyle
        );
        insert setting;
        return setting;
    }

    public static pq_Crush_User_Setting__c createUserSetting(String sortOrder, Id userId) {
        pq_Crush_User_Setting__c setting = new pq_Crush_User_Setting__c(
            User__c = userId,
            Account_Plan_Sort__c = sortOrder
        );
        return setting;
    }

    public static RM_Node_Coordinate__c createRMNodeCoordinate(
        String key,
        String tempId,
        Double x,
        Double y,
        Id accountPlanId,
        Id relationshipMapId
    ) {
        RM_Node_Coordinate__c coordinate = new RM_Node_Coordinate__c(
            Key__c = key,
            TempId__c = tempId,
            X__c = x,
            Y__c = y,
            Relationship_Map__c = relationshipMapId,
            Account_Plan__c = accountPlanId
        );
        insert coordinate;
        return coordinate;
    }

    public static RM_Anchor__c createRMAnchor(String fromField, String toField, Id accountPlanId, Id relMapId) {
        RM_Anchor__c anchor = new RM_Anchor__c(
            From__c = fromField,
            To__c = toField,
            Account_Plan__c = accountPlanId,
            Relationship_Map__c = relMapId
        );
        insert anchor;
        return anchor;
    }

    public static Map_Member_Placeholder__c createMapMemberPlaceholder(String label, String description) {
        Map_Member_Placeholder__c placeholder = new Map_Member_Placeholder__c(
            Label__c = label,
            Description__c = description
        );
        insert placeholder;
        return placeholder;
    }

    public static Map_Member_Placeholder__c createMapMemberPlaceholder(
        String label,
        String description,
        String tempId,
        Id accountPlanId,
        Id relationshipMapId
    ) {
        Map_Member_Placeholder__c placeholder = new Map_Member_Placeholder__c(
            Label__c = label,
            Description__c = description,
            TempId__c = tempId,
            Account_Plan__c = accountPlanId,
            Relationship_Map__c = relationshipMapId
        );
        insert placeholder;
        return placeholder;
    }

    public static Map_Member_Placeholder_Relationship__c createMapMemberPlaceholderRelationship(
        String toId,
        String fromId,
        String tempId,
        Id relType,
        Id accountPlanId,
        Id relationshipMapId
    ) {
        Map_Member_Placeholder_Relationship__c placeholderRelationship = new Map_Member_Placeholder_Relationship__c(
            To__c = toId,
            From__c = fromId,
            TempId__c = tempId,
            Contact_Relationship_Type__c = relType,
            Account_Plan__c = accountPlanId,
            Relationship_Map__c = relationshipMapId
        );
        insert placeholderRelationship;
        return placeholderRelationship;
    }

    public static Contact_Relationship_Type__c createContactRelationshipType(
        String color,
        String label,
        Boolean editable,
        Boolean active
    ) {
        Contact_Relationship_Type__c contactRelType = new Contact_Relationship_Type__c(
            Color__c = color,
            Label__c = label,
            Label_Editable__c = editable,
            IsActive__c = active
        );
        insert contactRelType;
        return contactRelType;
    }

    public static Lead createLead(String firstName, String lastName, String company) {
        Lead l = new Lead(FirstName = firstName, LastName = lastName, Company = company);

        insert l;
        return l;
    }

    public static Map_Member_Lead__c createMapMemberLead(Relationship_Map__c relMap, Lead lead) {
        Map_Member_Lead__c mmLead = new Map_Member_Lead__c(Relationship_Map__c = relMap.Id, Lead__c = lead.Id);

        insert mmLead;
        return mmLead;
    }

    public static Key_Stakeholder_Lead__c createKeyStakeholderLead(Account_Plan__c accountPlan, Lead lead) {
        Key_Stakeholder_Lead__c ksLead = new Key_Stakeholder_Lead__c(
            Account_Plan__c = accountPlan.Id,
            Lead__c = lead.Id
        );

        insert ksLead;
        return ksLead;
    }

    public static Relationship_Group_Lead_Association__c createRelationshipGroupLeadAssociation(
        Relationship_Group__c rgroup,
        Lead lead
    ) {
        Relationship_Group_Lead_Association__c rgla = new Relationship_Group_Lead_Association__c(
            Relationship_Group__c = rgroup.Id,
            Lead__c = lead.Id
        );

        insert rgla;
        return rgla;
    }

    public static Relationship_Type_Map_Association__c createRelTypeMapAssociation(
        Relationship_Map__c rm,
        Contact_Relationship_Type__c relType
    ) {
        Relationship_Type_Map_Association__c association = new Relationship_Type_Map_Association__c(
            Relationship_Type__c = relType.Id,
            Relationship_Map__c = rm.Id
        );
        insert association;
        return association;
    }

    public static Relationship_Type_Account_Plan_Assoc__c createRelTypeAccountPlanAssociation(
        Account_Plan__c ap,
        Contact_Relationship_Type__c relType
    ) {
        Relationship_Type_Account_Plan_Assoc__c association = new Relationship_Type_Account_Plan_Assoc__c(
            Relationship_Type__c = relType.Id,
            Account_Plan__c = ap.Id
        );
        insert association;
        return association;
    }

    public static RM_Svg__c createRMSvg(String label) {
        RM_Svg__c rmsvg = new RM_Svg__c(Label__c = label);
        insert rmsvg;
        return rmsvg;
    }

    public static RM_Svg_Node_Association__c createRMSvgNodeAssociation(String key, RM_Svg__c svg) {
        RM_Svg_Node_Association__c rmsvgnodeassociation = new RM_Svg_Node_Association__c(
            Key__c = key,
            RM_Svg__c = svg.Id
        );
        insert rmsvgnodeassociation;
        return rmsvgnodeassociation;
    }

    public static RM_Svg_Node_Association__c createRMSvgNodeAssociation(
        String key,
        RM_Svg__c svg,
        Id relationshipMapId,
        Id accountPlanId
    ) {
        RM_Svg_Node_Association__c rmsvgnodeassociation = new RM_Svg_Node_Association__c(
            Key__c = key,
            RM_Svg__c = svg.Id,
            Relationship_Map__c = relationshipMapId,
            Account_Plan__c = accountPlanId
        );
        insert rmsvgnodeassociation;
        return rmsvgnodeassociation;
    }

    public static RM_Svg_Map_Association__c createRMSvgMapAssociation(Relationship_Map__c rm, RM_Svg__c svg) {
        RM_Svg_Map_Association__c rmSvgMapAssociation = new RM_Svg_Map_Association__c(
            RM_Svg__c = svg.Id,
            Relationship_Map__c = rm.Id
        );
        insert rmSvgMapAssociation;
        return rmSvgMapAssociation;
    }

    public static RM_Svg_Account_Plan_Association__c createRMSvgAccountPlanAssociation(
        Account_Plan__c ap,
        RM_Svg__c svg
    ) {
        RM_Svg_Account_Plan_Association__c rmSvgAccountPlanAssociation = new RM_Svg_Account_Plan_Association__c(
            RM_Svg__c = svg.Id,
            Account_Plan__c = ap.Id
        );
        insert rmSvgAccountPlanAssociation;
        return rmSvgAccountPlanAssociation;
    }

    public static list<pqcrush__Account_Plan_Template__c> createAccountPlanTemplate() {
        List<pqcrush__Account_Plan_Template__c> accPlaTemplate = new List<pqcrush__Account_Plan_Template__c>{
            new pqcrush__Account_Plan_Template__c(Name = 'Test Account Plan')
        };
        insert accPlaTemplate;
        return accPlaTemplate;
    }
    public static ContentVersion createContentVersion(string uploadfileName, string recordId, string image) {
        ContentVersion conVer = new ContentVersion();
        conVer.Title = uploadfileName;
        conVer.PathOnClient = uploadfileName;
        conVer.FirstPublishLocationId = recordId;
        conVer.VersionData = EncodingUtil.base64Decode(image);
        conVer.Description = System.Label.Header_Logo;
        insert conVer;
        return conVer;
    }
    public static pqcrush__Template_Section__c createTemplateSection(string accountPlanId, string templateId) {
        pqcrush__Template_Section__c tempSection = new pqcrush__Template_Section__c(
            pqcrush__Component_Label__c = 'Test',
            pqcrush__Component_Name__c = 'Test',
            pqcrush__Account_Plan__c = accountPlanId,
            pqcrush__Template__c = templateId
        );
        insert tempSection;
        return tempSection;
    }
    public static list<pqcrush__Component_Available__mdt> createComponentMetadata() {
        List<pqcrush__Component_Available__mdt> accPlaTemplate = new List<pqcrush__Component_Available__mdt>{
            new pqcrush__Component_Available__mdt(
                MasterLabel = 'Test Account Plan',
                DeveloperName = 'Test Account Plan'
            )
        };
        // insert accPlaTemplate;
        return accPlaTemplate;
    }
    public static void checkDefaultTest() {
        pqcrush__Account_Plan_Template__c accRecord = new pqcrush__Account_Plan_Template__c(
            pqcrush__Header_Title__c = 'Test Data',
            pqcrush__Default__c = true
        );
        insert accRecord;
    }
    public static WhiteSpaceTemplateMappingWrapper createWhiteSpaceTemplateMappingWrapper(String operator) {
        WhiteSpaceTemplateMappingWrapper whiteSpaceTemplateMappingWrap = new WhiteSpaceTemplateMappingWrapper(
            'Asset',
            'Name',
            null
        );

        List<MappingConditionWrapper> mappingConditionWrapList = new List<MappingConditionWrapper>();

        for (integer i = 0; i < 3; i++) {
            Mapping_Condition__c conditionRecord = new Mapping_Condition__c(
                Field__c = 'AssetLevel',
                Operator__c = 'EQUALS',
                Value__c = '1'
            );

            MappingConditionWrapper mappingConditionWrap = new MappingConditionWrapper();
            mappingConditionWrap.singleCondition = conditionRecord;
            mappingConditionWrap.isFieldCreateable = false;
            mappingConditionWrapList.add(MappingConditionWrap);
        }

        ConditionModel conditionModelWrap = new ConditionModel();
        conditionModelWrap.operator = operator;
        conditionModelWrap.singleConditions = MappingConditionWrapList;

        whiteSpaceTemplateMappingWrap.conditions = conditionModelWrap;

        return whiteSpaceTemplateMappingWrap;
    }
    public static list<pqcrush__Account_Plan_Template__c> createAccountPlanTemplateWithDefault() {
        List<pqcrush__Account_Plan_Template__c> accPlaTemplate = new List<pqcrush__Account_Plan_Template__c>{
            new pqcrush__Account_Plan_Template__c(pqcrush__Default__c = true)
        };
        insert accPlaTemplate;
        return accPlaTemplate;
    }

    public static pqcrush__NoteSection__c createNotesSection(Id recordId, Id templateids) {
        pqcrush__NoteSection__c notesRec = new pqcrush__NoteSection__c(
            pqcrush__Account_Plan__c = recordId,
            pqcrush__Account_Plan_Template__c = templateids
        );
        insert notesRec;
        return notesRec;
    }

    public static ContentVersion createContentVersionWithProlifiqLogoDescription(
        string uploadfileName,
        string recordId,
        string image
    ) {
        ContentVersion conVer = new ContentVersion();
        conVer.Title = uploadfileName;
        conVer.PathOnClient = uploadfileName;
        conVer.FirstPublishLocationId = recordId;
        conVer.VersionData = EncodingUtil.base64Decode(image);
        conVer.Description = System.Label.Prolifiq_PDF;
        insert conVer;
        return conVer;
    }
}