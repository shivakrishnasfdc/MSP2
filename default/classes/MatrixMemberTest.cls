@isTest
private class MatrixMemberTest {
    @isTest
    static void initializeKSTest() {
        Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('my plan');
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Contact c1 = new Contact(LastName = 'Test', FirstName = 'First', Title = 'Engineer');
        insert c1;

        Key_Stakeholder__c ks = new Key_Stakeholder__c(
            Contact__c = c1.Id,
            Account_Plan__c = accountPlan.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert ks;

        Key_Stakeholder__c selectedKs = [
            SELECT
                InfluenceId__r.Name,
                SupportId__r.Name,
                SupportId__r.Color__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Title,
                Account_Plan__c,
                Account_Plan__r.Name,
                Account_Plan__r.Status__c
            FROM Key_Stakeholder__c
            WHERE Id = :ks.Id
        ];

        MatrixMember result = new MatrixMember(selectedKs);
        System.assertEquals(ks.Id, result.id);
        System.assertEquals(c1.Id, result.personId);
        System.assertEquals(c1.FirstName, result.firstName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(i1.Name, result.influence);
        System.assertEquals(s1.Name, result.support);
        System.assertEquals(s1.Color__c, result.supportColor);
        System.assertEquals(c1.Title, result.title);
        System.assertEquals(accountPlan.Name, result.containerName);
    }

    @isTest
    static void initializeKSTest2() {
        Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('my plan');
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Contact c1 = new Contact(LastName = 'Test', FirstName = 'First', Title = 'Engineer');
        insert c1;

        Key_Stakeholder__c ks = new Key_Stakeholder__c(
            Contact__c = c1.Id,
            Account_Plan__c = accountPlan.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert ks;

        Key_Stakeholder__c selectedKs = [
            SELECT
                InfluenceId__r.Name,
                SupportId__r.Name,
                SupportId__r.Color__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Title,
                Account_Plan__c,
                Account_Plan__r.Name,
                Account_Plan__r.Status__c
            FROM Key_Stakeholder__c
            WHERE Id = :ks.Id
        ];

        MatrixMember result = new MatrixMember(selectedKs, 'infl', 'supp');
        System.assertEquals(ks.Id, result.id);
        System.assertEquals(c1.Id, result.personId);
        System.assertEquals(c1.FirstName, result.firstName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals('infl', result.influence);
        System.assertEquals('supp', result.support);
        System.assertEquals(s1.Color__c, result.supportColor);
        System.assertEquals(c1.Title, result.title);
        System.assertEquals(accountPlan.Name, result.containerName);
    }

    @isTest
    static void initializeKSTest3() {
        Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('my plan');
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Contact c1 = new Contact(LastName = 'Test', FirstName = 'First', Title = 'Engineer');
        insert c1;

        Key_Stakeholder__c ks = new Key_Stakeholder__c(
            Contact__c = c1.Id,
            Account_Plan__c = accountPlan.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert ks;

        Key_Stakeholder__c selectedKs = [
            SELECT
                InfluenceId__r.Name,
                SupportId__r.Name,
                SupportId__r.Color__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Title,
                Account_Plan__c,
                Account_Plan__r.Name,
                Account_Plan__r.Status__c
            FROM Key_Stakeholder__c
            WHERE Id = :ks.Id
        ];

        List<MatrixMemberAdditionalField> additionalFields = new List<MatrixMemberAdditionalField>{
            new MatrixMemberAdditionalField('name1', 'label1', 'type1', 'value1')
        };

        MatrixMember result = new MatrixMember(selectedKs, additionalFields);
        System.assertEquals(ks.Id, result.id);
        System.assertEquals(c1.Id, result.personId);
        System.assertEquals(c1.FirstName, result.firstName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(i1.Name, result.influence);
        System.assertEquals(s1.Name, result.support);
        System.assertEquals(s1.Color__c, result.supportColor);
        System.assertEquals(c1.Title, result.title);
        System.assertEquals(accountPlan.Name, result.containerName);
        System.assertEquals(additionalFields[0].name, result.additionalFields[0].name);
        System.assertEquals(additionalFields[0].label, result.additionalFields[0].label);
        System.assertEquals(additionalFields[0].type, result.additionalFields[0].type);
        System.assertEquals(additionalFields[0].value, result.additionalFields[0].value);
    }

    @isTest
    static void initializeKSTest4() {
        Account_Plan__c accountPlan = TestDataFactory.createAccountPlan('my plan');
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Contact c1 = new Contact(LastName = 'Test', FirstName = 'First', Title = 'Engineer');
        insert c1;

        Key_Stakeholder__c ks = new Key_Stakeholder__c(
            Contact__c = c1.Id,
            Account_Plan__c = accountPlan.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert ks;

        Key_Stakeholder__c selectedKs = [
            SELECT
                InfluenceId__r.Name,
                SupportId__r.Name,
                SupportId__r.Color__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Title,
                Account_Plan__c,
                Account_Plan__r.Name,
                Account_Plan__r.Status__c
            FROM Key_Stakeholder__c
            WHERE Id = :ks.Id
        ];

        List<MatrixMemberAdditionalField> additionalFields = new List<MatrixMemberAdditionalField>{
            new MatrixMemberAdditionalField('name1', 'label1', 'type1', 'value1')
        };

        MatrixMember result = new MatrixMember(selectedKs, 'infl', 'supp', additionalFields);
        System.assertEquals(ks.Id, result.id);
        System.assertEquals(c1.Id, result.personId);
        System.assertEquals(c1.FirstName, result.firstName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals('infl', result.influence);
        System.assertEquals('supp', result.support);
        System.assertEquals(s1.Color__c, result.supportColor);
        System.assertEquals(c1.Title, result.title);
        System.assertEquals(accountPlan.Name, result.containerName);
        System.assertEquals(additionalFields[0].name, result.additionalFields[0].name);
        System.assertEquals(additionalFields[0].label, result.additionalFields[0].label);
        System.assertEquals(additionalFields[0].type, result.additionalFields[0].type);
        System.assertEquals(additionalFields[0].value, result.additionalFields[0].value);
    }

    @isTest
    static void initializeMapMemberTest() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Contact c1 = new Contact(LastName = 'Test', FirstName = 'First', Title = 'Engineer');
        insert c1;

        Relationship_Map_Member__c rmm = new Relationship_Map_Member__c(
            Contact__c = c1.Id,
            Relationship_Map__c = rm.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert rmm;

        Relationship_Map_Member__c selectedRMM = [
            SELECT
                InfluenceId__r.Name,
                SupportId__r.Name,
                InfluenceId__r.Label__c,
                SupportId__r.Label__c,
                SupportId__r.Color__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Title,
                Relationship_Map__c,
                Relationship_Map__r.Name
            FROM Relationship_Map_Member__c
            WHERE Id = :rmm.Id
        ];

        MatrixMember result = new MatrixMember(selectedRMM);
        System.assertEquals(rmm.Id, result.id);
        System.assertEquals(c1.Id, result.personId);
        System.assertEquals(c1.FirstName, result.firstName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(i1.Name, result.influence);
        System.assertEquals(s1.Name, result.support);
        System.assertEquals(s1.Color__c, result.supportColor);
        System.assertEquals(c1.Title, result.title);
        System.assertEquals(rm.Name, result.containerName);
    }

    @isTest
    static void initializeMapMemberTest2() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Contact c1 = new Contact(LastName = 'Test', FirstName = 'First', Title = 'Engineer');
        insert c1;

        Relationship_Map_Member__c rmm = new Relationship_Map_Member__c(
            Contact__c = c1.Id,
            Relationship_Map__c = rm.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert rmm;

        Relationship_Map_Member__c selectedRMM = [
            SELECT
                InfluenceId__r.Name,
                SupportId__r.Name,
                InfluenceId__r.Label__c,
                SupportId__r.Label__c,
                SupportId__r.Color__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Title,
                Relationship_Map__c,
                Relationship_Map__r.Name
            FROM Relationship_Map_Member__c
            WHERE Id = :rmm.Id
        ];

        MatrixMember result = new MatrixMember(selectedRMM, 'infl', 'supp');
        System.assertEquals(rmm.Id, result.id);
        System.assertEquals(c1.Id, result.personId);
        System.assertEquals(c1.FirstName, result.firstName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals('infl', result.influence);
        System.assertEquals('supp', result.support);
        System.assertEquals(s1.Color__c, result.supportColor);
        System.assertEquals(c1.Title, result.title);
        System.assertEquals(rm.Name, result.containerName);
    }

    @isTest
    static void initializeMapMemberTest3() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Contact c1 = new Contact(LastName = 'Test', FirstName = 'First', Title = 'Engineer');
        insert c1;

        Relationship_Map_Member__c rmm = new Relationship_Map_Member__c(
            Contact__c = c1.Id,
            Relationship_Map__c = rm.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert rmm;

        Relationship_Map_Member__c selectedRMM = [
            SELECT
                InfluenceId__r.Name,
                SupportId__r.Name,
                InfluenceId__r.Label__c,
                SupportId__r.Label__c,
                SupportId__r.Color__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Title,
                Relationship_Map__c,
                Relationship_Map__r.Name
            FROM Relationship_Map_Member__c
            WHERE Id = :rmm.Id
        ];

        List<MatrixMemberAdditionalField> additionalFields = new List<MatrixMemberAdditionalField>{
            new MatrixMemberAdditionalField('name1', 'label1', 'type1', 'value1')
        };

        MatrixMember result = new MatrixMember(selectedRMM, additionalFields);
        System.assertEquals(rmm.Id, result.id);
        System.assertEquals(c1.Id, result.personId);
        System.assertEquals(c1.FirstName, result.firstName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(i1.Name, result.influence);
        System.assertEquals(s1.Name, result.support);
        System.assertEquals(s1.Color__c, result.supportColor);
        System.assertEquals(c1.Title, result.title);
        System.assertEquals(rm.Name, result.containerName);
        System.assertEquals(additionalFields[0].name, result.additionalFields[0].name);
        System.assertEquals(additionalFields[0].label, result.additionalFields[0].label);
        System.assertEquals(additionalFields[0].type, result.additionalFields[0].type);
        System.assertEquals(additionalFields[0].value, result.additionalFields[0].value);
    }

    @isTest
    static void initializeMapMemberTest4() {
        Relationship_Map__c rm = TestDataFactory.createRelationshipMap('my map');
        pq_Influence__c i1 = new pq_Influence__c(Name = 'Low', Label__c = 'lowlabel');
        insert i1;
        pq_Support__c s1 = new pq_Support__c(Name = 'Champion', Label__c = 'champlabel', Color__c = '#ff0011');
        insert s1;

        Contact c1 = new Contact(LastName = 'Test', FirstName = 'First', Title = 'Engineer');
        insert c1;

        Relationship_Map_Member__c rmm = new Relationship_Map_Member__c(
            Contact__c = c1.Id,
            Relationship_Map__c = rm.Id,
            InfluenceId__c = i1.Id,
            SupportId__c = s1.Id
        );
        insert rmm;

        Relationship_Map_Member__c selectedRMM = [
            SELECT
                InfluenceId__r.Name,
                SupportId__r.Name,
                InfluenceId__r.Label__c,
                SupportId__r.Label__c,
                SupportId__r.Color__c,
                Contact__r.FirstName,
                Contact__r.LastName,
                Contact__r.Name,
                Contact__r.Title,
                Relationship_Map__c,
                Relationship_Map__r.Name
            FROM Relationship_Map_Member__c
            WHERE Id = :rmm.Id
        ];

        List<MatrixMemberAdditionalField> additionalFields = new List<MatrixMemberAdditionalField>{
            new MatrixMemberAdditionalField('name1', 'label1', 'type1', 'value1')
        };

        MatrixMember result = new MatrixMember(selectedRMM, 'infl', 'supp', additionalFields);
        System.assertEquals(rmm.Id, result.id);
        System.assertEquals(c1.Id, result.personId);
        System.assertEquals(c1.FirstName, result.firstName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals(c1.LastName, result.lastName);
        System.assertEquals('infl', result.influence);
        System.assertEquals('supp', result.support);
        System.assertEquals(s1.Color__c, result.supportColor);
        System.assertEquals(c1.Title, result.title);
        System.assertEquals(rm.Name, result.containerName);
        System.assertEquals(additionalFields[0].name, result.additionalFields[0].name);
        System.assertEquals(additionalFields[0].label, result.additionalFields[0].label);
        System.assertEquals(additionalFields[0].type, result.additionalFields[0].type);
        System.assertEquals(additionalFields[0].value, result.additionalFields[0].value);
    }
}