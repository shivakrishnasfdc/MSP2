@SuppressWarnings('PMD.NcssMethodCount')
@isTest
public with sharing class AccountPlanCloneServiceTest {
    public static final String ADMIN_USER_FIRST_NAME = 'Apple';
    public static final String ADMIN_USER_LAST_NAME = 'Create';

    public static final String CRUSH_ADMINISTRATOR = 'CRUSH_Administrator';

    /******************************
     *            SETUP
     ******************************/
    @testSetup
    static void testSetup() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User adminUser = TestDataFactory.createUser(ADMIN_USER_FIRST_NAME, ADMIN_USER_LAST_NAME, standardProfile.Id);
        PermissionSet adminUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = :CRUSH_ADMINISTRATOR LIMIT 1];

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = adminUserPermissionSet.Id)
        };
    }

    /******************************
     *            TESTS
     ******************************/

    /*** cloneAccountPlans() exception tests ***/
    @isTest
    private static void cloneAccountPlansNoPlanIdTest() {
        TestMockData md = new TestMockData();
        // No Plan Id
        AccountPlanCloneWrapper wrapper = new AccountPlanCloneWrapper(
            null,
            'newName',
            UserInfo.getUserId(),
            md.mockAccountId,
            null
        );
        try {
            AccountPlanCloneService.cloneAccountPlans(new List<AccountPlanCloneWrapper>{ wrapper });
            System.assert(false, 'Expected no account plan id exception');
        } catch (Exception e) {
            System.assertEquals(
                'No account plan information passed when trying to clone an account plan',
                e.getMessage()
            );
        }

        // No Account Id
        wrapper = new AccountPlanCloneWrapper(md.mockAccountPlanId, 'newName', UserInfo.getUserId(), null, null);
        try {
            AccountPlanCloneService.cloneAccountPlans(new List<AccountPlanCloneWrapper>{ wrapper });
            System.assert(false, 'Expected no account id exception');
        } catch (Exception e) {
            System.assertEquals('No account information passed when trying to clone an account plan', e.getMessage());
        }
    }

    /*** cloneAccountPlans() functional tests ***/
    @isTest
    private static void cloneAccountPlansValidityTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        TestMockData md = new TestMockData();

        Account account = new Account(Name = 'Account 1');
        insert account;

        Account account2 = new Account(Name = 'Account 2');
        insert account2;

        Account_Plan__c plan = md.mockAccountPlan.clone(false, true);
        plan.Id = null;
        plan.pqcrush__Account__c = account.Id;
        plan.OwnerId = UserInfo.getUserId();
        insert plan;

        //Bypassing after inserting the plan because the plan trigger sets up the owner as a team member
        //All inserts after this do not need the trigger to run
        Application.bypassTrigger = true;

        Objective__c objective = md.mockObjective.clone(false, true);
        objective.Id = null;
        objective.pqcrush__Account_Plan__c = plan.Id;
        insert objective;

        Opportunity opp = md.mockOpportunity.clone(false, true);
        opp.Id = null;
        insert opp;

        Objective_Opportunity__c objOpp = md.mockObjectiveOpportunity.clone(false, true);
        objOpp.Id = null;
        objOpp.Objective__c = objective.Id;
        objOpp.Opportunity__c = opp.Id;
        insert objOpp;

        Team_Member__c member = md.mockTeamMember.clone(false, true);
        member.Id = null;
        member.Account_Plan__c = plan.Id;
        member.User__c = adminUser.Id;
        insert member;

        White_Space__c whitespace = md.mockWhiteSpace.clone(false, true);
        whitespace.Id = null;
        whitespace.Account_Plan__c = plan.Id;
        insert whitespace;

        White_Space_Row__c whitespaceRow = md.mockWhiteSpaceRow.clone(false, true);
        whitespaceRow.Id = null;
        whitespaceRow.White_Space__c = whitespace.Id;
        insert whitespaceRow;

        White_Space_Column__c whitespaceColumn = md.mockWhiteSpaceColumn.clone(false, true);
        whitespaceColumn.Id = null;
        whitespaceColumn.White_Space__c = whitespace.Id;
        insert whitespaceColumn;

        White_Space_Cell__c whitespaceCell = md.mockWhiteSpaceCell.clone(false, true);
        whitespaceCell.Id = null;
        whitespaceCell.White_Space__c = whitespace.Id;
        whitespaceCell.White_Space_Column__c = whitespaceColumn.Id;
        whitespaceCell.White_Space_Row__c = whitespaceRow.Id;
        insert whitespaceCell;

        White_Space_Amount_Type__c whitespaceAmountType = md.mockWhiteSpaceAmountType.clone(false, true);
        whitespaceAmountType.Id = null;
        insert whitespaceAmountType;

        White_Space_Amount_Type_Association__c whitespaceATA = md.mockWhiteSpaceAmountTypeAssociation.clone(
            false,
            true
        );
        whitespaceATA.Id = null;
        whitespaceATA.Amount__c = 15;
        whitespaceATA.White_Space_Amount_Type__c = whitespaceAmountType.Id;
        whitespaceATA.White_Space_Cell__c = whitespaceCell.Id;
        insert whitespaceATA;

        WS_Data_Type__c whitespaceDataType = md.mockWSDataType.clone(false, true);
        whitespaceDataType.Id = null;
        whitespaceDataType.White_Space__c = whitespace.Id;
        whitespaceDataType.Apply_To_All_Cross_Sell_Maps__c = false;
        WS_Data_Type__c whitespaceDataType2 = md.mockWSDataType.clone(false, true);
        whitespaceDataType2.Id = null;
        whitespaceDataType2.White_Space__c = null;
        whitespaceDataType2.Apply_To_All_Cross_Sell_Maps__c = true;
        insert new List<WS_Data_Type__c>{ whitespaceDataType, whitespaceDataType2 };

        WS_Data_Type_Association__c whitespaceDTA = md.mockWSDataTypeAssociation.clone(false, true);
        whitespaceDTA.Id = null;
        whitespaceDTA.WS_Data_Type__c = whitespaceDataType.Id;
        whitespaceDTA.White_Space_Cell__c = whitespaceCell.Id;
        insert whitespaceDTA;

        WS_Summary_Formula__c whitespaceFormula = md.mockWSFormula.clone(false, true);
        whitespaceFormula.Id = null;
        whitespaceFormula.White_Space__c = whitespace.Id;
        insert whitespaceFormula;

        Application.bypassTrigger = false;

        AccountPlanCloneWrapper wrapper = new AccountPlanCloneWrapper(
            plan.Id,
            'Cloned Plan',
            adminUser.Id,
            account2.Id,
            new List<String>{
                AccountPlanCloneService.OBJECTIVES_RELATIONSHIP_NAME,
                AccountPlanCloneService.TEAM_MEMBERS_RELATIONSHIP_NAME,
                'pqcrush_Key_Dates__r',
                AccountPlanCloneService.WHITE_SPACE_RELATIONSHIP_NAME
            }
        );
        AccountPlanCloneWrapper wrapper2 = new AccountPlanCloneWrapper(
            plan.Id,
            'other Cloned Plan',
            adminUser.Id,
            account.Id,
            new List<String>()
        );
        List<AccountPlanCloneWrapper> wrapperList = new List<AccountPlanCloneWrapper>{ wrapper, wrapper2 };

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our new objects created dates are ordered correctly
        }
        Test.startTest();
        AccountPlanCloneService.cloneAccountPlans(wrapperList);
        Test.stopTest();

        Integer plansCount = [SELECT COUNT() FROM Account_Plan__c];
        Account_Plan__c expectedNewPlan = [
            SELECT
                OwnerId,
                Summary__c,
                Plan_Overview_Title__c,
                Plan_Overview__c,
                RecordTypeId,
                pqcrush__Account__c,
                Name,
                Id,
                CreatedDate
            FROM Account_Plan__c
            WHERE Name = 'Cloned Plan'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer objectivesCount = [SELECT COUNT() FROM Objective__c];
        Objective__c expectedNewObjective = [
            SELECT Description__c, Account_Plan__c, Name, Id, CreatedDate
            FROM Objective__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer objectiveOppsCount = [SELECT COUNT() FROM Objective_Opportunity__c];
        Objective_Opportunity__c expectedNewObjectiveOpp = [
            SELECT Objective__c, Opportunity__c, Id, CreatedDate
            FROM Objective_Opportunity__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer teamMembersCount = [SELECT COUNT() FROM Team_Member__c];
        //Latest team member could be from either plan due to the creator being added automatically, so need to specify that we want the one created from the cloning of team members
        Team_Member__c expectedNewTeamMember = [
            SELECT User__c, Account_Plan__c, Name, Id, Role__c
            FROM Team_Member__c
            WHERE Account_Plan__c = :expectedNewPlan.Id AND User__c = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer whitespaceCount = [SELECT COUNT() FROM White_Space__c];
        White_Space__c expectedWhitespace = [
            SELECT Account_Plan__c, Id
            FROM White_Space__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer rowCount = [SELECT COUNT() FROM White_Space_Row__c];
        White_Space_Row__c expectedRow = [
            SELECT Id, Name, White_Space__c, Order__c
            FROM White_Space_Row__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer columnCount = [SELECT COUNT() FROM White_Space_Column__c];
        White_Space_Column__c expectedColumn = [
            SELECT Id, Name, White_Space__c, Order__c
            FROM White_Space_Column__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer cellCount = [SELECT COUNT() FROM White_Space_Cell__c];
        White_Space_Cell__c expectedCell = [
            SELECT White_Space__c, White_Space_Column__c, White_Space_Row__c, Id, Info__c
            FROM White_Space_Cell__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer associationCount = [SELECT COUNT() FROM White_Space_Amount_Type_Association__c];
        White_Space_Amount_Type_Association__c expectedAssociation = [
            SELECT White_Space_Amount_Type__c, White_Space_Cell__c, Amount__c, Id
            FROM White_Space_Amount_Type_Association__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer dtCount = [SELECT COUNT() FROM WS_Data_Type__c];
        Integer dtaCount = [SELECT COUNT() FROM WS_Data_Type_Association__c];
        WS_Data_Type_Association__c expectedDTA = [
            SELECT White_Space_Cell__c, WS_Data_Type__c, WS_Data_Value__c, Id
            FROM WS_Data_Type_Association__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer formulaCount = [SELECT COUNT() FROM WS_Summary_Formula__c];
        WS_Summary_Formula__c expectedFormula = [
            SELECT White_Space__c, Label__c, Color__c, Display_Type__c, Formula__c, Id
            FROM WS_Summary_Formula__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Integer accountCount = [SELECT COUNT() FROM Account];
        Integer amountTypeCount = [SELECT COUNT() FROM White_Space_Amount_Type__c];
        Integer keyDatesCount = [SELECT COUNT() FROM Key_Date__c];

        System.assertEquals(3, plansCount, 'Should be three plans - original and two clones');
        System.assert(expectedNewPlan != null, 'New plan should exist');
        System.assert(expectedNewPlan.Id != plan.Id, 'New plan should not be the same plan as the original plan');
        System.assert(
            expectedNewPlan.CreatedDate != plan.CreatedDate,
            'New plan should not have the same created date as the original'
        );
        System.assertEquals(
            expectedNewPlan.pqcrush__Account__c,
            account2.Id,
            'New plan should be related to account 2'
        );
        System.assertEquals(expectedNewPlan.Name, 'Cloned Plan', 'New plan should be renamed');

        System.assertEquals(2, objectivesCount, 'Should be two objectives after clone');
        System.assert(expectedNewObjective != null, 'New objective should exist');
        System.assert(
            expectedNewObjective.Id != objective.Id,
            'New objective should not be the same objective as the original objective'
        );
        System.assertEquals(
            expectedNewPlan.Id,
            expectedNewObjective.Account_Plan__c,
            'New objective should be related to the new plan'
        );

        System.assertEquals(2, objectiveOppsCount, 'Should be two objective opportunities after clone');
        System.assert(expectedNewObjectiveOpp != null, 'New objective opportunity should exist');
        System.assertNotEquals(
            objOpp.Id,
            expectedNewObjectiveOpp.Id,
            'New objective opportunity should not be the same objective opportunity'
        );
        System.assertEquals(
            expectedNewObjective.Id,
            expectedNewObjectiveOpp.Objective__c,
            'New objective opportunity should be related to the new objective'
        );
        System.assertEquals(
            opp.Id,
            expectedNewObjectiveOpp.Opportunity__c,
            'New objective opportunity should be related to the original opportunity'
        );

        System.assertEquals(
            5,
            teamMembersCount,
            'Should be five team members after clone - two on the original plan, two on the cloned plan with relationships, and one on the cloned plan without relationships'
        );
        System.assertNotEquals(null, expectedNewTeamMember, 'New team member should exist');
        System.assertNotEquals(
            member.Id,
            expectedNewTeamMember.Id,
            'New team member should not be the same team member as the original team member'
        );
        System.assertEquals(
            expectedNewPlan.Id,
            expectedNewTeamMember.Account_Plan__c,
            'New team member should be related to the new plan'
        );
        System.assertEquals(
            plan.OwnerId,
            expectedNewTeamMember.User__c,
            'New team member should be the previous plan owner'
        );

        System.assertEquals(2, whitespaceCount, 'Should be two white spaces after clone');
        System.assertNotEquals(null, expectedWhitespace, 'New whitespace should exist');
        System.assertNotEquals(
            whitespace.Id,
            expectedWhitespace.Id,
            'New whitespace should not be the same whitespace as the original whitespace'
        );
        System.assertEquals(
            expectedNewPlan.Id,
            expectedWhitespace.Account_Plan__c,
            'New whitespace should be related to the new plan'
        );

        System.assertEquals(2, rowCount, 'Should be two rows after clone');
        System.assertNotEquals(null, expectedRow, 'New row should exist');
        System.assertNotEquals(
            whitespaceRow.Id,
            expectedRow.Id,
            'New row should not be the same row as the original row'
        );
        System.assertEquals(
            expectedWhitespace.Id,
            expectedRow.White_Space__c,
            'New row should be related to the new whitespace'
        );
        System.assertEquals(whitespaceRow.Name, expectedRow.Name, 'New row should have the same name as the old row');
        System.assertEquals(
            whitespaceRow.Order__c,
            expectedRow.Order__c,
            'New row should have the same order as the old row'
        );

        System.assertEquals(2, columnCount, 'Should be two columns after clone');
        System.assertNotEquals(null, expectedColumn, 'New column should exist');
        System.assertNotEquals(
            whitespaceColumn.Id,
            expectedColumn.Id,
            'New column should not be the same column as the original column'
        );
        System.assertEquals(
            expectedWhitespace.Id,
            expectedColumn.White_Space__c,
            'New column should be related to the new whitespace'
        );
        System.assertEquals(
            whitespaceColumn.Name,
            expectedColumn.Name,
            'New column should have the same name as the old column'
        );
        System.assertEquals(
            whitespaceColumn.Order__c,
            expectedColumn.Order__c,
            'New column should have the same order as the old column'
        );

        System.assertEquals(2, cellCount, 'Should be two cells after clone');
        System.assertNotEquals(null, expectedCell, 'New cell should exist');
        System.assertNotEquals(
            whitespaceCell.Id,
            expectedCell.Id,
            'New cell should not be the same cell as the original cell'
        );
        System.assertEquals(
            expectedWhitespace.Id,
            expectedCell.White_Space__c,
            'New cell should be related to the new whitespace'
        );
        System.assertEquals(
            expectedRow.Id,
            expectedCell.White_Space_Row__c,
            'New cell should be related to the new row'
        );
        System.assertEquals(
            expectedColumn.Id,
            expectedCell.White_Space_Column__c,
            'New cell should be related to the new column'
        );
        System.assertEquals(
            whitespaceCell.Info__c,
            expectedCell.Info__c,
            'New cell should have the same info as the old cell'
        );

        System.assertEquals(2, associationCount, 'Should be two associations after clone');
        System.assertNotEquals(null, expectedAssociation, 'New association should exist');
        System.assertNotEquals(
            whitespaceATA.Id,
            expectedAssociation.Id,
            'New association should not be the same association as the original association'
        );
        System.assertEquals(
            whitespaceAmountType.Id,
            expectedAssociation.White_Space_Amount_Type__c,
            'New association should be related to the same amount type'
        );
        System.assertEquals(
            expectedCell.Id,
            expectedAssociation.White_Space_Cell__c,
            'New association should be related to the new cell'
        );
        System.assertEquals(
            whitespaceATA.Amount__c,
            expectedAssociation.Amount__c,
            'New association should have the same value as the old association'
        );

        System.assertEquals(
            3,
            dtCount,
            'Should be three data types after clone (2 original and cloned WS specific dt)'
        );
        System.assertEquals(2, dtaCount, 'Should be two dta after clone');
        System.assertNotEquals(null, expectedDTA, 'New dta should exist');
        System.assertNotEquals(
            whitespaceDTA.Id,
            expectedDTA.Id,
            'New association should not be the same dta as the original dta'
        );
        System.assertNotEquals(
            whitespaceDataType.Id,
            expectedDTA.WS_Data_Type__c,
            'New dta should be related to the same amount type'
        );
        System.assertEquals(
            expectedCell.Id,
            expectedDTA.White_Space_Cell__c,
            'New dta should be related to the new cell'
        );
        System.assertEquals(
            whitespaceDTA.WS_Data_Value__c,
            expectedDTA.WS_Data_Value__c,
            'New dta should have the same value as the old dta'
        );

        System.assertEquals(2, formulaCount, 'Should be two formula after clone');
        System.assertNotEquals(null, expectedFormula, 'New formula should exist');
        System.assertNotEquals(
            whitespaceFormula.Id,
            expectedFormula.Id,
            'New association should not be the same formula as the original formula'
        );
        System.assertEquals(
            whitespaceFormula.Label__c,
            expectedFormula.Label__c,
            'New formula should have same label as old formula'
        );
        System.assertEquals(
            whitespaceFormula.Color__c,
            expectedFormula.Color__c,
            'New formula should have same color as old formula'
        );
        System.assertEquals(
            whitespaceFormula.Display_Type__c,
            expectedFormula.Display_Type__c,
            'New formula should have same display type as old formula'
        );
        System.assertEquals(
            whitespaceFormula.Formula__c,
            expectedFormula.Formula__c,
            'New formula should have same formula as old formula'
        );
        System.assertEquals(
            expectedWhitespace.Id,
            expectedFormula.White_Space__c,
            'New formula should be related to the new cell'
        );

        System.assertEquals(2, accountCount, 'The accounts should not be cloned');
        System.assertEquals(1, amountTypeCount, 'The amount type should not be cloned');
        System.assertEquals(0, keyDatesCount, 'Should still be zero key dates after clone');
    }

    @isTest
    private static void cloneAccountPlansStakeholderMapTest() {
        TestMockData md = new TestMockData();

        Account account = new Account(Name = 'Account 1');
        insert account;

        Account_Plan__c plan = md.mockAccountPlan.clone(false, true);
        plan.Id = null;
        plan.pqcrush__Account__c = account.Id;
        plan.OwnerId = UserInfo.getUserId();
        insert plan;

        //Bypassing after inserting the plan because the plan trigger sets up the owner as a team member
        //All inserts after this do not need the trigger to run
        Application.bypassTrigger = true;

        /**************
         *   Map   *
         **************/

        Relationship_Map__c rm = md.mockRelationshipMap.clone(false, true);
        rm.Id = null;
        rm.pq_AccountPlanId__c = plan.Id;
        insert rm;

        /**************
         *   Matrix   *
         **************/

        pq_Influence_And_Support_Matrix__c ism = new pq_Influence_And_Support_Matrix__c();
        ism.Name = 'Test Matrix For crmmt';
        ism.Is_Default__c = false;
        insert ism;

        pq_Account_Plan_Matrix_Association__c assoc = new pq_Account_Plan_Matrix_Association__c();
        assoc.Account_Plan__c = plan.Id;
        assoc.Influence_And_Support_Matrix__c = ism.Id;
        insert assoc;

        pq_Relationship_Map_Matrix_Association__c rmAssoc = new pq_Relationship_Map_Matrix_Association__c();
        rmAssoc.Relationship_Map__c = rm.Id;
        rmAssoc.Influence_And_Support_Matrix__c = ism.Id;
        insert rmAssoc;

        /*************************
         *   Badge Association   *
         *************************/

        RM_Svg__c badgeSVG = TestDataFactory.createRMSvg('The test SVG');

        RM_Svg_Account_Plan_Association__c planBadgeAssoc = TestDataFactory.createRMSvgAccountPlanAssociation(
            plan,
            badgeSVG
        );

        /**************************************
         *   Relationshiip Type Association   *
         **************************************/

        Contact_Relationship_Type__c contactRelType = TestDataFactory.createContactRelationshipType(
            '#123456',
            'Rel Type',
            true,
            true
        );

        Relationship_Type_Account_Plan_Assoc__c planRelTypeAssoc = TestDataFactory.createRelTypeAccountPlanAssociation(
            plan,
            contactRelType
        );

        /**************
         *   Groups   *
         **************/

        //Groups
        Relationship_Group__c localGroup = md.mockRelationshipGroup.clone(false, true);
        localGroup.Id = null;
        localGroup.Parent_Relationship_Group__c = null;
        localGroup.Relationship_Map__c = rm.Id;

        Relationship_Group__c globalGroup = md.mockRelationshipGroup.clone(false, true);
        globalGroup.Id = null;
        globalGroup.Parent_Relationship_Group__c = null;
        globalGroup.Relationship_Map__c = null;
        insert new List<SObject>{ localGroup, globalGroup };

        /********************
         *   Placeholders   *
         ********************/

        //Placeholders
        String placeholderLabel = 'The placeholder to find cloneAccountPlansWithPlaceholderTest';
        Map_Member_Placeholder__c placeholder = md.mockPlaceholder.clone(false, true);
        placeholder.Label__c = placeholderLabel;
        placeholder.Id = null;
        placeholder.Relationship_Map__c = rm.Id;
        placeholder.Account_Plan__c = null;

        Map_Member_Placeholder__c placeholder2 = md.mockPlaceholder.clone(false, true);
        placeholder2.Id = null;
        placeholder2.Relationship_Map__c = rm.Id;
        placeholder2.Account_Plan__c = null;
        insert new List<SObject>{ placeholder, placeholder2 };

        //placeholder group association
        Relationship_Group_Placeholder_Assoc__c plToLocalG = new Relationship_Group_Placeholder_Assoc__c(
            Map_Member_Placeholder__c = placeholder.Id,
            Relationship_Group__c = localGroup.Id
        );
        Relationship_Group_Placeholder_Assoc__c plToGlobalG = new Relationship_Group_Placeholder_Assoc__c(
            Map_Member_Placeholder__c = placeholder.Id,
            Relationship_Group__c = globalGroup.Id
        );
        insert new List<SObject>{ plToLocalG, plToGlobalG };

        /****************
         *   Contacts   *
         ****************/

        //Contact for relationships
        Contact con = md.mockContact.clone(false, true);
        con.Id = null;
        con.ReportsToId = null;
        insert con;

        //contact group association
        Relationship_Group_Contact_Association__c conToLocalG = new Relationship_Group_Contact_Association__c(
            Contact__c = con.Id,
            Relationship_Group__c = localGroup.Id
        );
        Relationship_Group_Contact_Association__c conToGlobalG = new Relationship_Group_Contact_Association__c(
            Contact__c = con.Id,
            Relationship_Group__c = globalGroup.Id
        );
        insert new List<SObject>{ conToLocalG, conToGlobalG };

        /*************
         *   Users   *
         *************/

        //User for Map Member User
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User usr = TestDataFactory.createUser('Joe Bob capwptest', 'Last Name capwptest', standardProfile.Id);

        //Map Member User
        Map_Member_User__c mmu = new Map_Member_User__c(Relationship_Map__c = rm.Id, User__c = usr.Id);
        insert mmu;

        //User group association
        Relationship_Group_User_Association__c usrToLocalG = new Relationship_Group_User_Association__c(
            User__c = usr.Id,
            Relationship_Group__c = localGroup.Id
        );
        Relationship_Group_User_Association__c usrToGlobalG = new Relationship_Group_User_Association__c(
            User__c = usr.Id,
            Relationship_Group__c = globalGroup.Id
        );
        insert new List<SObject>{ usrToLocalG, usrToGlobalG };

        /*************
         *   Leads   *
         *************/

        //Lead member
        Lead ld = md.mockLead.clone(false, true);
        ld.Id = null;
        insert ld;
        Map_Member_Lead__c ksl = new Map_Member_Lead__c(Relationship_Map__c = rm.Id, Lead__c = ld.Id);
        insert ksl;

        //lead group association
        Relationship_Group_Lead_Association__c leadToLocalG = new Relationship_Group_Lead_Association__c(
            Lead__c = ld.Id,
            Relationship_Group__c = localGroup.Id
        );
        Relationship_Group_Lead_Association__c leadToGlobalG = new Relationship_Group_Lead_Association__c(
            Lead__c = ld.Id,
            Relationship_Group__c = globalGroup.Id
        );
        insert new List<SObject>{ leadToLocalG, leadToGlobalG };

        /*********************
         *   Relationships   *
         *********************/

        //Placeholder Relationship Lines
        Map_Member_Placeholder_Relationship__c placeRelateTo = md.mockPlaceholderRelationship.clone(false, true);
        placeRelateTo.Id = null;
        placeRelateTo.Relationship_Map__c = rm.Id;
        placeRelateTo.From__c = placeholder.Id;
        placeRelateTo.To__c = placeholder2.Id;
        placeRelateTo.Is_Hierarchy__c = true;

        Map_Member_Placeholder_Relationship__c placeholderToContact = md.mockPlaceholderRelationship.clone(false, true);
        placeholderToContact.Id = null;
        placeholderToContact.Relationship_Map__c = rm.Id;
        placeholderToContact.From__c = placeholder.Id;
        placeholderToContact.To__c = con.Id;
        placeholderToContact.Is_Hierarchy__c = false;

        Map_Member_Placeholder_Relationship__c contactToPlaceholder = md.mockPlaceholderRelationship.clone(false, true);
        contactToPlaceholder.Id = null;
        contactToPlaceholder.Relationship_Map__c = rm.Id;
        contactToPlaceholder.From__c = con.Id;
        contactToPlaceholder.To__c = placeholder.Id;
        contactToPlaceholder.Is_Hierarchy__c = false;
        insert new List<SObject>{ placeRelateTo, placeholderToContact, contactToPlaceholder };

        Application.bypassTrigger = false;

        AccountPlanCloneWrapper wrapper = new AccountPlanCloneWrapper(
            plan.Id,
            'Cloned Plan',
            UserInfo.getUserId(),
            account.Id,
            new List<String>{ AccountPlanCloneService.RELATIONSHIP_MAP_RELATIONSHIP_NAME }
        );
        List<AccountPlanCloneWrapper> wrapperList = new List<AccountPlanCloneWrapper>{ wrapper };

        Datetime oneSecInFuture = Datetime.now().addSeconds(1);
        while (Datetime.now() < oneSecInFuture) {
            Integer temp = 1 + 1; //NOPMD - loop until time has passed to garauntee our new objects created dates are ordered correctly
        }
        Test.startTest();
        AccountPlanCloneService.cloneAccountPlans(wrapperList);
        Test.stopTest();

        Integer plansCount = [SELECT COUNT() FROM Account_Plan__c];
        Account_Plan__c expectedNewPlan = [
            SELECT
                OwnerId,
                Summary__c,
                Plan_Overview_Title__c,
                Plan_Overview__c,
                RecordTypeId,
                pqcrush__Account__c,
                Name,
                Id,
                CreatedDate
            FROM Account_Plan__c
            WHERE Name = 'Cloned Plan'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, plansCount, 'Should be two plans, original plus cloned');
        System.assertNotEquals(null, expectedNewPlan, 'Should have a new plan');
        System.assertNotEquals(plan.Id, expectedNewPlan.Id, 'Plan should be cloned therefore have a new Id');
        System.assertEquals(wrapper.newOwnerId, expectedNewPlan.OwnerId, 'cloned plan should have new owner');
        System.assertEquals(wrapper.newName, expectedNewPlan.Name, 'cloned plan should have new name');

        //Map
        Integer mapCount = [SELECT COUNT() FROM Relationship_Map__c];
        Relationship_Map__c expectedNewMap = [
            SELECT Name, Id, CreatedDate, pq_AccountPlanId__c
            FROM Relationship_Map__c
            WHERE pq_AccountPlanId__c = :expectedNewPlan.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, mapCount, 'Should be two maps, original plus cloned');
        System.assertNotEquals(null, expectedNewMap, 'Should have a new map');
        System.assertNotEquals(rm.Id, expectedNewMap.Id, 'Map should be cloned therefore have a new Id');
        System.assertEquals(
            expectedNewPlan.Id,
            expectedNewMap.pq_AccountPlanId__c,
            'Map should be associated with new plan'
        );
        System.assertEquals(wrapper.newName, expectedNewMap.Name, 'cloned map should have new name');

        //Matrix
        Integer matrixCount = [SELECT COUNT() FROM pq_Influence_And_Support_Matrix__c];
        System.assertEquals(1, matrixCount, 'Should not clone the matrix itself');

        //Matrix Association
        Integer planAssocCount = [SELECT COUNT() FROM pq_Account_Plan_Matrix_Association__c];
        pq_Account_Plan_Matrix_Association__c expectedNewPlanMatrixAssoc = [
            SELECT Account_Plan__c, Influence_And_Support_Matrix__c, Id, CreatedDate
            FROM pq_Account_Plan_Matrix_Association__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(
            2,
            planAssocCount,
            'Should be two plan matrix associations after clone, original and cloned'
        );
        System.assert(expectedNewPlanMatrixAssoc != null, 'New plan matrix association should exist');
        System.assert(
            expectedNewPlanMatrixAssoc.Id != assoc.Id,
            'New plan matrix association should not be the original association'
        );
        System.assertEquals(
            expectedNewPlan.Id,
            expectedNewPlanMatrixAssoc.Account_Plan__c,
            'New plan matrix association should be related to the new plan'
        );
        System.assertEquals(
            ism.Id,
            expectedNewPlanMatrixAssoc.Influence_And_Support_Matrix__c,
            'New plan matrix association should be related to the original matrix'
        );

        Integer rmAssocCount = [SELECT COUNT() FROM pq_Relationship_Map_Matrix_Association__c];
        pq_Relationship_Map_Matrix_Association__c expectedNewAssoc = [
            SELECT Relationship_Map__c, Influence_And_Support_Matrix__c, Id, CreatedDate
            FROM pq_Relationship_Map_Matrix_Association__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, rmAssocCount, 'Should be two rm associations after clone, original and cloned');
        System.assert(expectedNewAssoc != null, 'New association should exist');
        System.assert(expectedNewAssoc.Id != assoc.Id, 'New association should not be the original association');
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewAssoc.Relationship_Map__c,
            'New association should be related to the new map'
        );
        System.assertEquals(
            ism.Id,
            expectedNewAssoc.Influence_And_Support_Matrix__c,
            'New association should be related to the original matrix'
        );

        //Badge Association
        Integer badgeAssocCount = [SELECT COUNT() FROM RM_Svg_Account_Plan_Association__c];
        RM_Svg_Account_Plan_Association__c expectedNewBadgeAssoc = [
            SELECT Account_Plan__c, RM_Svg__c, Id, CreatedDate
            FROM RM_Svg_Account_Plan_Association__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, badgeAssocCount, 'Should be two badge associations after clone, original and cloned');
        System.assert(expectedNewBadgeAssoc != null, 'New badge association should exist');
        System.assert(
            expectedNewBadgeAssoc.Id != planBadgeAssoc.Id,
            'New badge association should not be the original association'
        );
        System.assertEquals(
            expectedNewPlan.Id,
            expectedNewBadgeAssoc.Account_Plan__c,
            'New badge association should be related to the new plan'
        );
        System.assertEquals(
            badgeSVG.Id,
            expectedNewBadgeAssoc.RM_Svg__c,
            'New badge association should be related to the original badge'
        );

        //Relationship Type Association
        Integer relTypeAssocCount = [SELECT COUNT() FROM Relationship_Type_Account_Plan_Assoc__c];
        Relationship_Type_Account_Plan_Assoc__c expectedNewRelTypeAssoc = [
            SELECT Account_Plan__c, Relationship_Type__c, Id, CreatedDate
            FROM Relationship_Type_Account_Plan_Assoc__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(
            2,
            relTypeAssocCount,
            'Should be two relationship type associations after clone, original and cloned'
        );
        System.assert(expectedNewRelTypeAssoc != null, 'New relationship type association should exist');
        System.assert(
            expectedNewRelTypeAssoc.Id != planRelTypeAssoc.Id,
            'New relationship type association should not be the original association'
        );
        System.assertEquals(
            expectedNewPlan.Id,
            expectedNewRelTypeAssoc.Account_Plan__c,
            'New relationship type association should be related to the new plan'
        );
        System.assertEquals(
            contactRelType.Id,
            expectedNewRelTypeAssoc.Relationship_Type__c,
            'New relationship type association should be related to the original relationship type'
        );

        //Groups
        Integer groupCount = [SELECT COUNT() FROM Relationship_Group__c];
        Relationship_Group__c expectedNewGroup = [
            SELECT Relationship_Map__c, Label__c, Id, CreatedDate
            FROM Relationship_Group__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(
            3,
            groupCount,
            'Should be three groups after clone, original global and local + cloned local'
        );
        System.assert(expectedNewGroup != null, 'New group should exist');
        System.assert(expectedNewGroup.Id != localGroup.Id, 'New group should not be the original local group');
        System.assert(expectedNewGroup.Id != globalGroup.Id, 'New group should not be the original global group');
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewGroup.Relationship_Map__c,
            'New group should be related to the new map'
        );

        //Map Member User
        Integer mmuCount = [SELECT COUNT() FROM Map_Member_User__c];
        Map_Member_User__c expectedNewMmu = [
            SELECT User__c, Relationship_Map__c, Id, CreatedDate
            FROM Map_Member_User__c
            WHERE Relationship_Map__c = :expectedNewMap.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, mmuCount, 'Should be two user members after clone');
        System.assert(expectedNewMmu != null, 'New user member should exist');
        System.assert(
            expectedNewMmu.Id != mmu.Id,
            'New user member should not be the same as the original user member'
        );
        System.assertEquals(expectedNewMmu.User__c, usr.Id, 'New user member should be related to the same user');
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewMmu.Relationship_Map__c,
            'New user member should be related to the new map'
        );

        //Placeholder
        Integer placeholderCount = [SELECT COUNT() FROM Map_Member_Placeholder__c];
        Map_Member_Placeholder__c expectedNewPlaceholder = [
            SELECT Description__c, Relationship_Map__c, Label__c, Id, CreatedDate
            FROM Map_Member_Placeholder__c
            WHERE Label__c = :placeholderLabel
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(4, placeholderCount, 'Should be four placeholders after clone');
        System.assert(expectedNewPlaceholder != null, 'New placeholder should exist');
        System.assert(
            expectedNewPlaceholder.Id != placeholder.Id,
            'New placeholder should not be the same placeholder as the first original placeholder'
        );
        System.assert(
            expectedNewPlaceholder.Id != placeholder2.Id,
            'New placeholder should not be the same placeholder as the second original placeholder'
        );
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewPlaceholder.Relationship_Map__c,
            'New placeholder should be related to the new map'
        );

        //Placeholder Hierarchy Reports To
        Integer placeholderHierarchyCount = [
            SELECT COUNT()
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = TRUE
        ];
        Map_Member_Placeholder_Relationship__c expectedNewPlaceholderHierarchy = [
            SELECT Relationship_Map__c, Is_Hierarchy__c, From__c, To__c, Id, CreatedDate
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = TRUE
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, placeholderHierarchyCount, 'Should be two placeholder hierarchy lines after clone');
        System.assert(expectedNewPlaceholderHierarchy != null, 'New placeholder should exist');
        System.assert(
            expectedNewPlaceholderHierarchy.Id != placeholder.Id,
            'New placeholder Hierarchy Line should not be the same Hierarchy Line as the original Hierarchy Line'
        );
        System.assert(
            expectedNewPlaceholderHierarchy.Relationship_Map__c == expectedNewMap.Id,
            'New placeholder Hierarchy line should be to the cloned map'
        );
        System.assert(
            expectedNewPlaceholderHierarchy.From__c == expectedNewPlaceholder.Id ||
            expectedNewPlaceholderHierarchy.To__c == expectedNewPlaceholder.Id,
            'New placeholder Hierarchy Line should be related to the new Placeholder'
        );

        //Placeholder To Contact
        Integer toContactCount = [
            SELECT COUNT()
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = FALSE AND To__c = :con.Id
        ];
        Map_Member_Placeholder_Relationship__c expectedNewToContact = [
            SELECT Relationship_Map__c, Is_Hierarchy__c, From__c, To__c, Id, CreatedDate
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = FALSE AND To__c = :con.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, toContactCount, 'Should be two placeholder to contact rel lines after clone');
        System.assert(expectedNewToContact != null, 'New placeholder to contact rel line should exist');
        System.assert(
            expectedNewToContact.Id != placeholderToContact.Id,
            'New placeholder to contact rel line should not be the same Line as the original'
        );
        System.assert(
            expectedNewToContact.Relationship_Map__c == expectedNewMap.Id,
            'New placeholder to contact rel line should be to the cloned map'
        );
        System.assert(
            expectedNewToContact.To__c == con.Id,
            'New placeholder to contact rel line should be to the contact'
        );
        System.assert(
            expectedNewToContact.From__c == expectedNewPlaceholder.Id,
            'New placeholder to contact rel line should be from the new placeholder'
        );

        //Contact to Placeholder
        Integer fromContactCount = [
            SELECT COUNT()
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = FALSE AND FROM__c = :con.Id
        ];
        Map_Member_Placeholder_Relationship__c expectedNewFromContact = [
            SELECT Relationship_Map__c, Is_Hierarchy__c, From__c, To__c, Id, CreatedDate
            FROM Map_Member_Placeholder_Relationship__c
            WHERE Is_Hierarchy__c = FALSE AND From__c = :con.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, fromContactCount, 'Should be two placeholder from contact rel lines after clone');
        System.assert(expectedNewFromContact != null, 'New placeholder from contact rel line should exist');
        System.assert(
            expectedNewFromContact.Id != placeholderToContact.Id,
            'New placeholder from contact rel line should not be the same Line as the original'
        );
        System.assert(
            expectedNewFromContact.Relationship_Map__c == expectedNewMap.Id,
            'New placeholder from contact rel line should be to the cloned map'
        );
        System.assert(
            expectedNewFromContact.From__c == con.Id,
            'New placeholder from contact rel line should be from the contact'
        );
        System.assert(
            expectedNewFromContact.To__c == expectedNewPlaceholder.Id,
            'New placeholder from contact rel line should be To the new placeholder'
        );

        //Placeholder to Local Group
        Integer pToLGCount = [
            SELECT COUNT()
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Relationship_Group__c != :globalGroup.Id
        ];
        Relationship_Group_Placeholder_Assoc__c expectedNewPlaceToLG = [
            SELECT Map_Member_Placeholder__c, Relationship_Group__c, Id, CreatedDate
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Relationship_Group__c = :expectedNewGroup.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, pToLGCount, 'Should be two placeholder to local group associations after clone');
        System.assert(expectedNewPlaceToLG != null, 'New placeholder to local group association should exist');
        System.assert(
            expectedNewPlaceToLG.Id != plToLocalG.Id,
            'New placeholder to local group association should not be the same association as the original'
        );
        System.assert(
            expectedNewPlaceToLG.Relationship_Group__c == expectedNewGroup.Id,
            'New placeholder to local group association should relate to the cloned local group'
        );
        System.assert(
            expectedNewPlaceToLG.Map_Member_Placeholder__c == expectedNewPlaceholder.Id,
            'New placeholder to local group association should relate to the cloned placeholder'
        );

        //Placeholder to Global Group
        Integer pToGGCount = [
            SELECT COUNT()
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Relationship_Group__c = :globalGroup.Id
        ];
        Relationship_Group_Placeholder_Assoc__c expectedNewPlaceToGG = [
            SELECT Map_Member_Placeholder__c, Relationship_Group__c, Id, CreatedDate
            FROM Relationship_Group_Placeholder_Assoc__c
            WHERE Relationship_Group__c = :globalGroup.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, pToGGCount, 'Should be two placeholder to global group associations after clone');
        System.assert(expectedNewPlaceToGG != null, 'New placeholder to global group association should exist');
        System.assert(
            expectedNewPlaceToGG.Id != plToGlobalG.Id,
            'New placeholder to global group association should not be the same association as the original'
        );
        System.assert(
            expectedNewPlaceToGG.Relationship_Group__c == globalGroup.Id,
            'New placeholder to global group association should relate to the global group'
        );
        System.assert(
            expectedNewPlaceToGG.Map_Member_Placeholder__c == expectedNewPlaceholder.Id,
            'New placeholder to global group association should relate to the cloned placeholder'
        );

        //Contact to Local Group
        Integer cToLGCount = [
            SELECT COUNT()
            FROM Relationship_Group_Contact_Association__c
            WHERE Relationship_Group__c != :globalGroup.Id
        ];
        Relationship_Group_Contact_Association__c expectedNewConToLG = [
            SELECT Contact__c, Relationship_Group__c, Id, CreatedDate
            FROM Relationship_Group_Contact_Association__c
            WHERE Relationship_Group__c = :expectedNewGroup.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, cToLGCount, 'Should be two contact to local group associations after clone');
        System.assert(expectedNewConToLG != null, 'New contact to local group association should exist');
        System.assert(
            expectedNewConToLG.Id != plToLocalG.Id,
            'New contact to local group association should not be the same association as the original'
        );
        System.assert(
            expectedNewConToLG.Relationship_Group__c == expectedNewGroup.Id,
            'New contact to local group association should relate to the cloned local group'
        );
        System.assert(
            expectedNewConToLG.Contact__c == con.Id,
            'New contact to local group association should relate to the contact'
        );

        //Contact to Global Group
        Integer cToGGCount = [
            SELECT COUNT()
            FROM Relationship_Group_Contact_Association__c
            WHERE Relationship_Group__c = :globalGroup.Id
        ];
        System.assertEquals(1, cToGGCount, 'Should not create new contact group association for global group');

        //User to Local Group
        Integer usrToLGCount = [
            SELECT COUNT()
            FROM Relationship_Group_User_Association__c
            WHERE Relationship_Group__c != :globalGroup.Id
        ];
        Relationship_Group_User_Association__c expectedNewUsrToLG = [
            SELECT User__c, Relationship_Group__c, Id, CreatedDate
            FROM Relationship_Group_User_Association__c
            WHERE Relationship_Group__c = :expectedNewGroup.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(2, usrToLGCount, 'Should be two user to local group associations after clone');
        System.assert(expectedNewUsrToLG != null, 'New user to local group association should exist');
        System.assert(
            expectedNewUsrToLG.Id != usrToLocalG.Id,
            'New user to local group association should not be the same association as the original'
        );
        System.assert(
            expectedNewUsrToLG.Relationship_Group__c == expectedNewGroup.Id,
            'New user to local group association should relate to the cloned local group'
        );
        System.assert(
            expectedNewUsrToLG.User__c == usr.Id,
            'New user to local group association should relate to the user'
        );

        //User to Global Group
        Integer usrToGGCount = [
            SELECT COUNT()
            FROM Relationship_Group_User_Association__c
            WHERE Relationship_Group__c = :globalGroup.Id
        ];
        System.assertEquals(1, usrToGGCount, 'Should not create new user group association for global group');

        Integer mmlCount = [SELECT COUNT() FROM Map_Member_Lead__c];
        Map_Member_Lead__c expectedNewMML = [
            SELECT Relationship_Map__c, Lead__c, Id, CreatedDate
            FROM Map_Member_Lead__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(
            2,
            mmlCount,
            'Should be two Map Member Lead Records in the system after the clone (original and cloned)'
        );
        System.assert(expectedNewMML != null, 'New Map Member Lead should exist');
        System.assert(expectedNewMML.Id != ksl.Id, 'New Map Member Lead should not be the original Map Member Lead');
        System.assertEquals(
            expectedNewMap.Id,
            expectedNewMML.Relationship_Map__c,
            'New Map Member Lead should be related to the new map'
        );
        System.assertEquals(ld.Id, expectedNewMML.Lead__c, 'New Map Member Lead should be related to the same lead');

        Integer rglaCount = [SELECT COUNT() FROM Relationship_Group_Lead_Association__c];
        Integer leadToGlobalGroupCount = [
            SELECT COUNT()
            FROM Relationship_Group_Lead_Association__c
            WHERE Relationship_Group__c = :globalGroup.Id
        ];
        Relationship_Group_Lead_Association__c expectedNewLeadToLocalGroup = [
            SELECT Relationship_Group__c, Lead__c, Id, CreatedDate
            FROM Relationship_Group_Lead_Association__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        System.assertEquals(
            3,
            rglaCount,
            'Should be three Group-Lead Association Records in the system after the clone (original to local, original to global, and cloned to local (To global should not get cloned))'
        );
        System.assertEquals(
            1,
            leadToGlobalGroupCount,
            'Should only be the one existing Lead to global group association (none cloned)'
        );
        System.assert(expectedNewLeadToLocalGroup != null, 'New Group-Lead Association should exist');
        System.assert(
            expectedNewLeadToLocalGroup.Id != leadToLocalG.Id,
            'New Group-Lead Association should not be the original Local Group-Lead Association'
        );
        System.assert(
            expectedNewLeadToLocalGroup.Id != leadToGlobalG.Id,
            'New Group-Lead Association should not be the original Global Group-Lead Association'
        );
        System.assertEquals(
            expectedNewGroup.Id,
            expectedNewLeadToLocalGroup.Relationship_Group__c,
            'New Group-Lead Association should be related to the new local group'
        );
        System.assertEquals(
            ld.Id,
            expectedNewLeadToLocalGroup.Lead__c,
            'New Group-Lead Association should be related to existing lead'
        );
    }

    @isTest
    private static void cloneAccountPlansBatchDifferentPlansTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        TestMockData md = new TestMockData();

        Account account = new Account(Name = 'Account 1');
        insert account;

        Integer initialPlanCount = 200;

        List<Account_Plan__c> plans = new List<Account_Plan__c>();
        for (Integer i = 0; i < initialPlanCount; i++) {
            Account_Plan__c plan = md.mockAccountPlan.clone(false, true);
            plan.Id = null;
            plan.pqcrush__Account__c = account.Id;
            plan.OwnerId = UserInfo.getUserId();
            plans.add(plan);
        }
        insert plans;

        //Bypassing after inserting the plan because the plan trigger sets up the owner as a team member
        //All inserts after this do not need the trigger to run
        Application.bypassTrigger = true;

        List<AccountPlanCloneWrapper> wrappers = new List<AccountPlanCloneWrapper>();
        List<Objective__c> objectives = new List<Objective__c>();
        List<Team_Member__c> members = new List<Team_Member__c>();
        List<White_Space__c> whitespaces = new List<White_Space__c>();
        for (Account_Plan__c plan : plans) {
            Objective__c objective = md.mockObjective.clone(false, true);
            objective.Id = null;
            objective.pqcrush__Account_Plan__c = plan.Id;
            objectives.add(objective);

            Team_Member__c member = md.mockTeamMember.clone(false, true);
            member.Id = null;
            member.Account_Plan__c = plan.Id;
            member.User__c = adminUser.Id;
            members.add(member);

            White_Space__c whitespace = md.mockWhiteSpace.clone(false, true);
            whitespace.Id = null;
            whitespace.Account_Plan__c = plan.Id;
            whitespaces.add(whitespace);

            AccountPlanCloneWrapper wrapper = new AccountPlanCloneWrapper(
                plan.Id,
                'Cloned Plan',
                adminUser.Id,
                account.Id,
                new List<String>{
                    AccountPlanCloneService.OBJECTIVES_RELATIONSHIP_NAME,
                    AccountPlanCloneService.TEAM_MEMBERS_RELATIONSHIP_NAME,
                    'pqcrush_Key_Dates__r',
                    AccountPlanCloneService.WHITE_SPACE_RELATIONSHIP_NAME
                }
            );
            wrappers.add(wrapper);
        }
        insert objectives;
        insert members;
        insert whitespaces;

        List<White_Space_Row__c> rows = new List<White_Space_Row__c>();
        List<White_Space_Column__c> columns = new List<White_Space_Column__c>();
        for (White_Space__c whitespace : whitespaces) {
            White_Space_Row__c whitespaceRow = md.mockWhiteSpaceRow.clone(false, true);
            whitespaceRow.Id = null;
            whitespaceRow.White_Space__c = whitespace.Id;
            rows.add(whitespaceRow);

            White_Space_Column__c whitespaceColumn = md.mockWhiteSpaceColumn.clone(false, true);
            whitespaceColumn.Id = null;
            whitespaceColumn.White_Space__c = whitespace.Id;
            columns.add(whitespaceColumn);
        }
        insert rows;
        insert columns;

        Application.bypassTrigger = false;

        Test.startTest();
        AccountPlanCloneService.cloneAccountPlans(wrappers);
        Test.stopTest();

        Integer planCount = [SELECT COUNT() FROM Account_Plan__c];
        System.assertEquals(2 * initialPlanCount, planCount, 'Should clone all the plans');
    }

    @isTest
    private static void cloneAccountPlansBatchSamePlanTest() {
        User adminUser = [
            SELECT Id
            FROM User
            WHERE FirstName = :ADMIN_USER_FIRST_NAME AND LastName = :ADMIN_USER_LAST_NAME
            LIMIT 1
        ];

        TestMockData md = new TestMockData();

        Account account = new Account(Name = 'Account 1');
        insert account;

        Account account2 = new Account(Name = 'Account 2');
        insert account2;

        Account_Plan__c plan = md.mockAccountPlan.clone(false, true);
        plan.Id = null;
        plan.pqcrush__Account__c = account.Id;
        plan.OwnerId = UserInfo.getUserId();
        insert plan;

        //Bypassing after inserting the plan because the plan trigger sets up the owner as a team member
        //All inserts after this do not need the trigger to run
        Application.bypassTrigger = true;

        Objective__c objective = md.mockObjective.clone(false, true);
        objective.Id = null;
        objective.pqcrush__Account_Plan__c = plan.Id;
        insert objective;

        Opportunity opp = md.mockOpportunity.clone(false, true);
        opp.Id = null;
        insert opp;

        Objective_Opportunity__c objOpp = md.mockObjectiveOpportunity.clone(false, true);
        objOpp.Id = null;
        objOpp.Objective__c = objective.Id;
        objOpp.Opportunity__c = opp.Id;
        insert objOpp;

        Team_Member__c member = md.mockTeamMember.clone(false, true);
        member.Id = null;
        member.Account_Plan__c = plan.Id;
        member.User__c = adminUser.Id;
        insert member;

        White_Space__c whitespace = md.mockWhiteSpace.clone(false, true);
        whitespace.Id = null;
        whitespace.Account_Plan__c = plan.Id;
        insert whitespace;

        White_Space_Row__c whitespaceRow = md.mockWhiteSpaceRow.clone(false, true);
        whitespaceRow.Id = null;
        whitespaceRow.White_Space__c = whitespace.Id;
        insert whitespaceRow;

        White_Space_Column__c whitespaceColumn = md.mockWhiteSpaceColumn.clone(false, true);
        whitespaceColumn.Id = null;
        whitespaceColumn.White_Space__c = whitespace.Id;
        insert whitespaceColumn;

        White_Space_Cell__c whitespaceCell = md.mockWhiteSpaceCell.clone(false, true);
        whitespaceCell.Id = null;
        whitespaceCell.White_Space__c = whitespace.Id;
        whitespaceCell.White_Space_Column__c = whitespaceColumn.Id;
        whitespaceCell.White_Space_Row__c = whitespaceRow.Id;
        insert whitespaceCell;

        White_Space_Amount_Type__c whitespaceAmountType = md.mockWhiteSpaceAmountType.clone(false, true);
        whitespaceAmountType.Id = null;
        insert whitespaceAmountType;

        White_Space_Amount_Type_Association__c whitespaceATA = md.mockWhiteSpaceAmountTypeAssociation.clone(
            false,
            true
        );
        whitespaceATA.Id = null;
        whitespaceATA.Amount__c = 15;
        whitespaceATA.White_Space_Amount_Type__c = whitespaceAmountType.Id;
        whitespaceATA.White_Space_Cell__c = whitespaceCell.Id;
        insert whitespaceATA;

        Application.bypassTrigger = false;

        Integer wrapperCount = 200;

        List<AccountPlanCloneWrapper> wrappers = new List<AccountPlanCloneWrapper>();
        for (Integer i = 0; i < wrapperCount; i++) {
            AccountPlanCloneWrapper wrapper = new AccountPlanCloneWrapper(
                plan.Id,
                'Cloned Plan',
                adminUser.Id,
                account2.Id,
                new List<String>{
                    AccountPlanCloneService.OBJECTIVES_RELATIONSHIP_NAME,
                    AccountPlanCloneService.TEAM_MEMBERS_RELATIONSHIP_NAME,
                    'pqcrush_Key_Dates__r',
                    AccountPlanCloneService.WHITE_SPACE_RELATIONSHIP_NAME
                }
            );
            wrappers.add(wrapper);
        }

        Test.startTest();
        AccountPlanCloneService.cloneAccountPlans(wrappers);
        Test.stopTest();

        Integer planCount = [SELECT COUNT() FROM Account_Plan__c];
        System.assertEquals(wrapperCount + 1, planCount, 'Should clone the plan the correct number of times');
    }
}