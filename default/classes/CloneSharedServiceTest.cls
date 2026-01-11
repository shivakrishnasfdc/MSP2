@isTest
private with sharing class CloneSharedServiceTest {
    /*** cloneWrappedObjectsReplacingParents() edge case tests ***/
    @IsTest
    private static void cloneWrappedObjectsReplacingParentsBadWrappersTest() {
        TestMockData md = new TestMockData();
        Account clonedAccount = new Account(
            Name = 'Fake account name clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        User clonedUser = new User(
            FirstName = 'clone user test first name',
            LastName = 'clone user test last name',
            Email = 'FakeTestEmail@exampleNotRealEmail.com',
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );
        Map<Id, SObject> cloneParentMap = new Map<Id, SObject>{
            md.MockAccountId => clonedAccount,
            UserInfo.getUserId() => clonedUser
        };
        List<SObject> result = CloneSharedService.cloneWrappedObjectsReplacingParents(null, cloneParentMap);
        System.assertEquals(0, result.size());
        result = CloneSharedService.cloneWrappedObjectsReplacingParents(
            new List<CloneSharedService.CloneObjectsWrapper>(),
            cloneParentMap
        );
        System.assertEquals(0, result.size());
    }

    @IsTest
    private static void cloneWrappedObjectsReplacingParentsPartialWrappersTest() {
        TestMockData md = new TestMockData();
        Account clonedAccount = new Account(
            Name = 'Fake account name clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        User clonedUser = new User(
            FirstName = 'clone user test first name',
            LastName = 'clone user test last name',
            Email = 'FakeTestEmail@exampleNotRealEmail.com',
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );
        Map<Id, SObject> cloneParentMap = new Map<Id, SObject>{
            md.MockAccountId => clonedAccount,
            UserInfo.getUserId() => clonedUser
        };
        Set<String> parentRelationships = new Set<String>{
            Account_Plan__c.Account__c.getDescribe().getName(),
            Account_Plan__c.OwnerId.getDescribe().getName()
        };
        CloneSharedService.CloneObjectsWrapper wrapper = new CloneSharedService.CloneObjectsWrapper();
        wrapper.relatedObjects = null;
        wrapper.parentRelationshipNames = parentRelationships;

        List<SObject> result = CloneSharedService.cloneWrappedObjectsReplacingParents(
            new List<CloneSharedService.CloneObjectsWrapper>{ wrapper },
            cloneParentMap
        );
        System.assertEquals(0, result.size());

        wrapper.relatedObjects = new List<SObject>();
        result = CloneSharedService.cloneWrappedObjectsReplacingParents(
            new List<CloneSharedService.CloneObjectsWrapper>{ wrapper },
            cloneParentMap
        );
        System.assertEquals(0, result.size());

        wrapper.relatedObjects = new List<SObject>{ md.mockAccountPlan };
        wrapper.parentRelationshipNames = null;
        result = CloneSharedService.cloneWrappedObjectsReplacingParents(
            new List<CloneSharedService.CloneObjectsWrapper>{ wrapper },
            cloneParentMap
        );
        System.assertEquals(0, result.size());

        wrapper.parentRelationshipNames = new Set<String>();
        result = CloneSharedService.cloneWrappedObjectsReplacingParents(
            new List<CloneSharedService.CloneObjectsWrapper>{ wrapper },
            cloneParentMap
        );
        System.assertEquals(0, result.size());
    }

    @IsTest
    private static void cloneWrappedObjectsReplacingParentsBadParentsMapTest() {
        TestMockData md = new TestMockData();
        Set<String> parentRelationships = new Set<String>{
            Account_Plan__c.Account__c.getDescribe().getName(),
            Account_Plan__c.OwnerId.getDescribe().getName()
        };
        CloneSharedService.CloneObjectsWrapper wrapper = new CloneSharedService.CloneObjectsWrapper();
        wrapper.relatedObjects = new List<SObject>{ md.mockAccountPlan };
        wrapper.parentRelationshipNames = parentRelationships;
        List<CloneSharedService.CloneObjectsWrapper> wrapperList = new List<CloneSharedService.CloneObjectsWrapper>{
            wrapper
        };

        List<SObject> result = CloneSharedService.cloneWrappedObjectsReplacingParents(wrapperList, null);
        System.assertEquals(0, result.size());
        result = CloneSharedService.cloneWrappedObjectsReplacingParents(wrapperList, new Map<Id, SObject>());
        System.assertEquals(0, result.size());
    }

    /*** cloneWrappedObjectsReplacingParents() happy path tests ***/
    @IsTest
    private static void cloneWrappedObjectsReplacingParentsTest() {
        TestMockData md = new TestMockData();
        Account clonedAccount = new Account(
            Name = 'Fake account name clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        User clonedUser = new User(
            FirstName = 'clone user test first name',
            LastName = 'clone user test last name',
            Email = 'FakeTestEmail@exampleNotRealEmail.com',
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );
        Map<Id, SObject> cloneParentMap = new Map<Id, SObject>{
            md.MockAccountId => clonedAccount,
            UserInfo.getUserId() => clonedUser
        };
        md.mockAccountPlan.Account__c = md.MockAccountId;
        md.mockAccountPlan.OwnerId = UserInfo.getUserId();
        Set<String> parentRelationships = new Set<String>{
            Account_Plan__c.Account__c.getDescribe().getName(),
            Account_Plan__c.OwnerId.getDescribe().getName()
        };
        CloneSharedService.CloneObjectsWrapper wrapper = new CloneSharedService.CloneObjectsWrapper();
        wrapper.relatedObjects = new List<SObject>{ md.mockAccountPlan };
        wrapper.parentRelationshipNames = parentRelationships;
        List<CloneSharedService.CloneObjectsWrapper> wrapperList = new List<CloneSharedService.CloneObjectsWrapper>{
            wrapper
        };

        List<SObject> result = CloneSharedService.cloneWrappedObjectsReplacingParents(wrapperList, cloneParentMap);
        System.assertEquals(1, result.size(), 'Should have one object returned');
        Account_Plan__c clonedPlan = (Account_Plan__c) result[0];
        System.assertNotEquals(
            md.mockAccountPlanId,
            clonedPlan.Id,
            'Cloned plan should have different Id than original'
        );
        System.assertEquals(md.mockAccountPlan.Name, clonedPlan.Name, 'Cloned plan should have same name as original');
        System.assertEquals(
            clonedAccount.Id,
            clonedPlan.Account__c,
            'Cloned plan should have updated parent Account Id'
        );
        System.assertEquals(clonedUser.Id, clonedPlan.OwnerId, 'Cloned plan should have updated OwnerId');
    }

    /*** mapClonedGenericRelatedObjectsForParentObjectsByOriginalId() edge case tests ***/
    @isTest
    private static void mapClonedGenericRelatedObjectsForParentObjectsByOriginalIdNullObjListTest() {
        TestMockData md = new TestMockData();
        Account clonedAccount = new Account(
            Name = 'Fake account name clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        User clonedUser = new User(
            FirstName = 'clone user test first name',
            LastName = 'clone user test last name',
            Email = 'FakeTestEmail@exampleNotRealEmail.com',
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );
        Map<Id, SObject> cloneParentMap = new Map<Id, SObject>{
            md.MockAccountId => clonedAccount,
            UserInfo.getUserId() => clonedUser
        };
        md.mockAccountPlan.Account__c = md.MockAccountId;
        md.mockAccountPlan.OwnerId = UserInfo.getUserId();
        Set<String> parentRelationships = new Set<String>{
            Account_Plan__c.Account__c.getDescribe().getName(),
            Account_Plan__c.OwnerId.getDescribe().getName()
        };
        Map<Id, SObject> result = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
            null,
            cloneParentMap,
            parentRelationships
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for null object list passed');
    }

    @isTest
    private static void mapClonedGenericRelatedObjectsForParentObjectsByOriginalIdEmptyObjListTest() {
        TestMockData md = new TestMockData();
        Account clonedAccount = new Account(
            Name = 'Fake account name clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        User clonedUser = new User(
            FirstName = 'clone user test first name',
            LastName = 'clone user test last name',
            Email = 'FakeTestEmail@exampleNotRealEmail.com',
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );
        Map<Id, SObject> cloneParentMap = new Map<Id, SObject>{
            md.MockAccountId => clonedAccount,
            UserInfo.getUserId() => clonedUser
        };
        md.mockAccountPlan.Account__c = md.MockAccountId;
        md.mockAccountPlan.OwnerId = UserInfo.getUserId();
        Set<String> parentRelationships = new Set<String>{
            Account_Plan__c.Account__c.getDescribe().getName(),
            Account_Plan__c.OwnerId.getDescribe().getName()
        };
        Map<Id, SObject> result = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
            new List<pqcrush__Account_Plan__c>(),
            cloneParentMap,
            parentRelationships
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for empty object list passed');
    }

    @isTest
    private static void mapClonedGenericRelatedObjectsForParentObjectsByOriginalIdNullParentMapTest() {
        TestMockData md = new TestMockData();
        Set<String> parentRelationships = new Set<String>{
            Account_Plan__c.Account__c.getDescribe().getName(),
            Account_Plan__c.OwnerId.getDescribe().getName()
        };
        Map<Id, SObject> result = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
            new List<pqcrush__Account_Plan__c>{ md.mockAccountPlan },
            null,
            parentRelationships
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for null parent map passed');
    }

    @isTest
    private static void mapClonedGenericRelatedObjectsForParentObjectsByOriginalIdEmptyParentMapTest() {
        TestMockData md = new TestMockData();
        Set<String> parentRelationships = new Set<String>{
            Account_Plan__c.Account__c.getDescribe().getName(),
            Account_Plan__c.OwnerId.getDescribe().getName()
        };
        Map<Id, SObject> result = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
            new List<pqcrush__Account_Plan__c>{ md.mockAccountPlan },
            new Map<Id, SObject>(),
            parentRelationships
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for empty parent map passed');
    }

    @isTest
    private static void mapClonedGenericRelatedObjectsForParentObjectsByOriginalIdNullRelationshipsTest() {
        TestMockData md = new TestMockData();
        Account clonedAccount = new Account(
            Name = 'Fake account name clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        User clonedUser = new User(
            FirstName = 'clone user test first name',
            LastName = 'clone user test last name',
            Email = 'FakeTestEmail@exampleNotRealEmail.com',
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );
        Map<Id, SObject> cloneParentMap = new Map<Id, SObject>{
            md.MockAccountId => clonedAccount,
            UserInfo.getUserId() => clonedUser
        };
        md.mockAccountPlan.Account__c = md.MockAccountId;
        md.mockAccountPlan.OwnerId = UserInfo.getUserId();
        Map<Id, SObject> result = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
            new List<pqcrush__Account_Plan__c>{ md.mockAccountPlan },
            cloneParentMap,
            null
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for null relationships passed');
    }

    @isTest
    private static void mapClonedGenericRelatedObjectsForParentObjectsByOriginalIdEmptyRelationshipsTest() {
        TestMockData md = new TestMockData();
        Account clonedAccount = new Account(
            Name = 'Fake account name clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        User clonedUser = new User(
            FirstName = 'clone user test first name',
            LastName = 'clone user test last name',
            Email = 'FakeTestEmail@exampleNotRealEmail.com',
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );
        Map<Id, SObject> cloneParentMap = new Map<Id, SObject>{
            md.MockAccountId => clonedAccount,
            UserInfo.getUserId() => clonedUser
        };
        md.mockAccountPlan.Account__c = md.MockAccountId;
        md.mockAccountPlan.OwnerId = UserInfo.getUserId();
        Map<Id, SObject> result = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
            new List<pqcrush__Account_Plan__c>{ md.mockAccountPlan },
            cloneParentMap,
            new Set<String>()
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for empty relationships passed');
    }

    /*** mapClonedGenericRelatedObjectsForParentObjectsByOriginalId() happy  path tests ***/

    @isTest
    private static void mapClonedGenericRelatedObjectsForParentObjectsByOriginalIdTest() {
        TestMockData md = new TestMockData();
        Account clonedAccount = new Account(
            Name = 'Fake account name clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Account.SObjectType)
        );
        User clonedUser = new User(
            FirstName = 'clone user test first name',
            LastName = 'clone user test last name',
            Email = 'FakeTestEmail@exampleNotRealEmail.com',
            Id = fflib_IDGenerator.generate(User.SObjectType)
        );
        Map<Id, SObject> cloneParentMap = new Map<Id, SObject>{
            md.MockAccountId => clonedAccount,
            UserInfo.getUserId() => clonedUser
        };
        md.mockAccountPlan.Account__c = md.MockAccountId;
        md.mockAccountPlan.OwnerId = UserInfo.getUserId();
        Set<String> parentRelationships = new Set<String>{
            Account_Plan__c.Account__c.getDescribe().getName(),
            Account_Plan__c.OwnerId.getDescribe().getName()
        };
        Map<Id, SObject> result = CloneSharedService.mapClonedGenericRelatedObjectsForParentObjectsByOriginalId(
            new List<pqcrush__Account_Plan__c>{ md.mockAccountPlan },
            cloneParentMap,
            parentRelationships
        );
        Account_Plan__c clonedPlan = (Account_Plan__c) result.get(md.mockAccountPlanId);
        System.assertNotEquals(null, clonedPlan, 'Should return a cloned plan for the original plan\'s Id');
        System.assertNotEquals(
            md.mockAccountPlanId,
            clonedPlan.Id,
            'Cloned plan should have different Id than original'
        );
        System.assertEquals(md.mockAccountPlan.Name, clonedPlan.Name, 'Cloned plan should have same name as original');
        System.assertEquals(
            clonedAccount.Id,
            clonedPlan.Account__c,
            'Cloned plan should have updated parent Account Id'
        );
        System.assertEquals(clonedUser.Id, clonedPlan.OwnerId, 'Cloned plan should have updated OwnerId');
    }

    @isTest
    private static void updateRelatedGroupsWithParentGroupsNullObjListTest() {
        TestMockData md = new TestMockData();
        Relationship_Group__c clonedOuterGroup = new Relationship_Group__c(
            Name = 'Fake outer group clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Relationship_Group__c clonedInnerGroup = new Relationship_Group__c(
            Name = 'Fake inner group clone',
            OwnerId = UserInfo.getUserId(),
            Parent_Relationship_Group__c = clonedOuterGroup.Id,
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Map<Id, Relationship_Group__c> cloneGroupMap = new Map<Id, Relationship_Group__c>{
            md.mockRelationshipGroupId => clonedOuterGroup,
            md.mockRelationshipGroupParentId => clonedInnerGroup
        };
        String parentGroupRelationshipName = Relationship_Group__c.Parent_Relationship_Group__c.getDescribe().getName();
        List<Relationship_Group__c> result = CloneSharedService.updateRelatedGroupsWithParentGroups(
            null,
            cloneGroupMap,
            parentGroupRelationshipName
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for null object list passed');
    }

    @isTest
    private static void updateRelatedGroupsWithParentGroupsEmptyObjListTest() {
        TestMockData md = new TestMockData();
        Relationship_Group__c clonedOuterGroup = new Relationship_Group__c(
            Name = 'Fake outer group clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Relationship_Group__c clonedInnerGroup = new Relationship_Group__c(
            Name = 'Fake inner group clone',
            OwnerId = UserInfo.getUserId(),
            Parent_Relationship_Group__c = clonedOuterGroup.Id,
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Map<Id, Relationship_Group__c> cloneGroupMap = new Map<Id, Relationship_Group__c>{
            md.mockRelationshipGroupId => clonedOuterGroup,
            md.mockRelationshipGroupParentId => clonedInnerGroup
        };
        String parentGroupRelationshipName = Relationship_Group__c.Parent_Relationship_Group__c.getDescribe().getName();
        List<Relationship_Group__c> result = CloneSharedService.updateRelatedGroupsWithParentGroups(
            new List<Relationship_Group__c>(),
            cloneGroupMap,
            parentGroupRelationshipName
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for empty object list passed');
    }

    @isTest
    private static void updateRelatedGroupsWithParentGroupsNullParentMapTest() {
        TestMockData md = new TestMockData();
        String parentGroupRelationshipName = Relationship_Group__c.Parent_Relationship_Group__c.getDescribe().getName();
        List<Relationship_Group__c> result = CloneSharedService.updateRelatedGroupsWithParentGroups(
            new List<Relationship_Group__c>{ md.mockRelationshipGroup },
            null,
            parentGroupRelationshipName
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for null parent map passed');
    }

    @isTest
    private static void updateRelatedGroupsWithParentGroupsEmptyParentMapTest() {
        TestMockData md = new TestMockData();
        String parentGroupRelationshipName = Relationship_Group__c.Parent_Relationship_Group__c.getDescribe().getName();
        List<Relationship_Group__c> result = CloneSharedService.updateRelatedGroupsWithParentGroups(
            new List<Relationship_Group__c>{ md.mockRelationshipGroup },
            new Map<Id, Relationship_Group__c>(),
            parentGroupRelationshipName
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for empty parent map passed');
    }

    @isTest
    private static void updateRelatedGroupsWithParentGroupsNullRelationshipsTest() {
        TestMockData md = new TestMockData();
        Relationship_Group__c originalOuterGroup = new Relationship_Group__c(
            Name = 'Fake outer group clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Relationship_Group__c originalInnerGroup = new Relationship_Group__c(
            Name = 'Fake inner group clone',
            OwnerId = UserInfo.getUserId(),
            Parent_Relationship_Group__c = originalOuterGroup.Id,
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Relationship_Group__c clonedOuterGroup = new Relationship_Group__c(
            Name = 'Fake outer group clone',
            OwnerId = UserInfo.getUserId(),
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Relationship_Group__c clonedInnerGroup = new Relationship_Group__c(
            Name = 'Fake inner group clone',
            OwnerId = UserInfo.getUserId(),
            Parent_Relationship_Group__c = clonedOuterGroup.Id,
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        List<Relationship_Group__c> originalGroupList = new List<Relationship_Group__c>();
        originalGroupList.add(originalOuterGroup);
        originalGroupList.add(originalInnerGroup);
        Map<Id, Relationship_Group__c> cloneGroupMap = new Map<Id, Relationship_Group__c>{
            md.mockRelationshipGroupId => clonedOuterGroup,
            md.mockRelationshipGroupParentId => clonedInnerGroup
        };
        List<Relationship_Group__c> result = CloneSharedService.updateRelatedGroupsWithParentGroups(
            originalGroupList,
            cloneGroupMap,
            null
        );
        System.assertEquals(0, result.size(), 'Empty map should be returned for null relationships passed');
    }

    /*** updateRelatedGroupsWithParentGroups() happy  path tests ***/

    @isTest
    private static void updateRelatedGroupsWithParentGroupsTest() {
        Relationship_Group__c originalOuterGroup = new Relationship_Group__c(
            Name = 'Fake outer group',
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Relationship_Group__c originalInnerGroup = new Relationship_Group__c(
            Name = 'Fake inner group',
            Parent_Relationship_Group__c = originalOuterGroup.Id,
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Relationship_Group__c clonedOuterGroup = new Relationship_Group__c(
            Name = 'Fake outer group',
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Relationship_Group__c clonedInnerGroup = new Relationship_Group__c(
            Name = 'Fake inner group',
            Parent_Relationship_Group__c = originalOuterGroup.Id,
            Id = fflib_IDGenerator.generate(Relationship_Group__c.SObjectType)
        );
        Map<Id, Relationship_Group__c> cloneGroupMap = new Map<Id, Relationship_Group__c>{
            originalOuterGroup.Id => clonedOuterGroup,
            originalInnerGroup.Id => clonedInnerGroup
        };
        List<Relationship_Group__c> originalGroupList = new List<Relationship_Group__c>();
        originalGroupList.add(originalOuterGroup);
        originalGroupList.add(originalInnerGroup);
        String parentGroupRelationshipName = Relationship_Group__c.Parent_Relationship_Group__c.getDescribe().getName();
        List<Relationship_Group__c> result = CloneSharedService.updateRelatedGroupsWithParentGroups(
            originalGroupList,
            cloneGroupMap,
            parentGroupRelationshipName
        );
        Relationship_Group__c clonedGroup = result[0];
        System.assertNotEquals(null, clonedGroup, 'Should return a cloned group for the original group\'s Id');
        System.assertNotEquals(
            originalInnerGroup.Id,
            clonedGroup.Id,
            'Cloned group should have different Id than original'
        );
        System.assertNotEquals(
            originalOuterGroup.Id,
            clonedGroup.Parent_Relationship_Group__c,
            'Cloned inner group should have different Parent Relationship Group than original'
        );
        System.assertEquals(
            originalInnerGroup.Name,
            clonedGroup.Name,
            'Cloned group should have same name as original'
        );
    }

    /*** fetchObjectsMatchingAnyQueryIdsInCloneFieldSet() edge case tests ***/

    @IsTest
    private static void fetchObjectsMatchingAnyQueryIdsInCloneFieldSetNullObjTypeTest() {
        try {
            CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
                null,
                new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType) },
                new Set<String>{ 'Id', 'Name' }
            );
            System.assert(false, 'An error should be thrown for null object name passed');
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'An error should be thrown for null object name passed');
        }
    }

    @IsTest
    private static void fetchObjectsMatchingAnyQueryIdsInCloneFieldSetNullMatchIdsTest() {
        List<SObject> result = CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            User.SObjectType,
            null,
            new Set<String>{ 'Name' }
        );
        System.assertEquals(0, result.size(), 'null match Ids should result in no matches being returned');
    }

    @IsTest
    private static void fetchObjectsMatchingAnyQueryIdsInCloneFieldSetEmptyMatchIdsTest() {
        List<SObject> result = CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            User.SObjectType,
            new Set<Id>(),
            new Set<String>{ 'Name' }
        );
        System.assertEquals(0, result.size(), 'Empty match Ids should result in no matches being returned');
    }

    @IsTest
    private static void fetchObjectsMatchingAnyQueryIdsInCloneFieldSetNullQueryKeysNoCloneFieldsetTest() {
        Account testAccountMatch = new Account(Name = 'FOMAQIICFS Test Account 1');
        Account testAccountNoMatch = new Account(Name = 'FOMAQIICFS Test Account 2');
        insert new List<Account>{ testAccountMatch, testAccountNoMatch };
        List<SObject> result = CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Account.SObjectType,
            new Set<Id>{ testAccountMatch.Id },
            null
        );
        System.assertEquals(1, result.size(), 'Should query on Id and match one  account');
        System.assertEquals(testAccountMatch.Id, result[0].Id, 'Expected account should be returned');
    }

    @IsTest
    private static void fetchObjectsMatchingAnyQueryIdsInCloneFieldSetNullQueryKeysWithCloneFieldsetTest() {
        Account testAccount = new Account(Name = 'FOMAQIICFS Test Account');
        insert testAccount;
        Account_Plan__c testPlan = new Account_Plan__c(
            Name = 'FOMAQIICFS Test Account Plan',
            Account__c = testAccount.Id,
            Status__c = 'Open'
        );
        insert testPlan;
        List<SObject> result = CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Account_Plan__c.SObjectType,
            new Set<Id>{ testPlan.Id },
            null
        );
        System.assertEquals(1, result.size(), 'Should query on Id and match one plan');
        System.assertEquals(testPlan.Id, result[0].Id, 'Expected plan should be returned');
    }

    /*** fetchObjectsMatchingAnyQueryIdsInCloneFieldSet() happy path tests ***/

    @isTest
    private static void fetchObjectsMatchingAnyQueryIdsInCloneFieldSetTest() {
        Account testAccountMatch = new Account(Name = 'FOMAQIICFS Test Account 1');
        Account testAccountNoMatch = new Account(Name = 'FOMAQIICFS Test Account 2');
        insert new List<Account>{ testAccountMatch, testAccountNoMatch };
        Account_Plan__c testPlanMatch = new Account_Plan__c(
            Name = 'FOMAQIICFS Test Account Plan',
            Account__c = testAccountMatch.Id,
            Status__c = 'Open'
        );
        Account_Plan__c testPlanNoMatch = new Account_Plan__c(
            Name = 'FOMAQIICFS Test Account Plan',
            Account__c = testAccountNoMatch.Id,
            Status__c = 'Open'
        );
        insert new List<Account_Plan__c>{ testPlanMatch, testPlanNoMatch };
        List<SObject> result = CloneSharedService.fetchObjectsMatchingAnyQueryIdsInCloneFieldSet(
            Account_Plan__c.SObjectType,
            new Set<Id>{ testAccountMatch.Id },
            new Set<String>{ Account_Plan__c.Account__c.getDescribe().getName() }
        );
        System.assertEquals(1, result.size(), 'Should query on Id and match one plan');
        System.assertEquals(testPlanMatch.Id, result[0].Id, 'Expected plan should be returned');
    }
}