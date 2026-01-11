@isTest
private class OrgChartFieldWrapperTest {
    @isTest
    static void newInstanceTest() {
        // Given
        Org_Chart_Field__c ocf = new Org_Chart_Field__c(
            Id = fflib_IDGenerator.generate(Org_Chart_Field__c.SObjectType),
            Name = 'name',
            ObjectName__c = 'Contact',
            FieldName__c = 'Title',
            FieldLabel__c = 'P Title',
            isRequired__c = true,
            isVisible__c = true,
            Map_Type__c = 'Relationship Map',
            IsMain__c = false
        );

        OrgChartFieldWrapper wrapper = new OrgChartFieldWrapper(ocf);

        // Then
        system.assertEquals(ocf.Id, wrapper.id);
        system.assertEquals(ocf.Name, wrapper.name);
        system.assertEquals(ocf.ObjectName__c, wrapper.objectName);
        system.assertEquals(ocf.FieldName__c, wrapper.fieldName);
        system.assertEquals(ocf.FieldLabel__c, wrapper.fieldLabel);
        system.assertEquals(ocf.isRequired__c, wrapper.isRequired);
        system.assertEquals(ocf.isVisible__c, wrapper.isVisible);
        system.assertEquals(ocf.Map_Type__c, wrapper.mapType);
        system.assertEquals(true, wrapper.isMain);
        system.assertEquals(false, wrapper.isEditable);
    }

    @isTest
    static void newInstanceTest2() {
        // Given
        Org_Chart_Field__c ocf = new Org_Chart_Field__c(
            Id = fflib_IDGenerator.generate(Org_Chart_Field__c.SObjectType),
            Name = 'name',
            ObjectName__c = 'Key_Stakeholder__c',
            FieldName__c = 'pqcrush__Influence__c',
            FieldLabel__c = 'Influence',
            isRequired__c = true,
            isVisible__c = true,
            Map_Type__c = 'Relationship Map',
            IsMain__c = false
        );

        OrgChartFieldWrapper wrapper = new OrgChartFieldWrapper(ocf);

        // Then
        system.assertEquals(ocf.Id, wrapper.id);
        system.assertEquals(ocf.Name, wrapper.name);
        system.assertEquals(ocf.ObjectName__c, wrapper.objectName);
        system.assertEquals(ocf.FieldName__c, wrapper.fieldName);
        system.assertEquals(ocf.FieldLabel__c, wrapper.fieldLabel);
        system.assertEquals(ocf.isRequired__c, wrapper.isRequired);
        system.assertEquals(ocf.isVisible__c, wrapper.isVisible);
        system.assertEquals(ocf.Map_Type__c, wrapper.mapType);
        system.assertEquals(true, wrapper.isMain);
        system.assertEquals(false, wrapper.isEditable);
    }

    @isTest
    static void toSObjectTest() {
        // Given
        Org_Chart_Field__c ocf = new Org_Chart_Field__c(
            Id = fflib_IDGenerator.generate(Org_Chart_Field__c.SObjectType),
            Name = 'name',
            ObjectName__c = 'Key_Stakeholder__c',
            FieldName__c = 'pqcrush__Influence__c',
            FieldLabel__c = 'Influence',
            isRequired__c = true,
            isVisible__c = true,
            Map_Type__c = 'Relationship Map',
            IsMain__c = false
        );

        OrgChartFieldWrapper wrapper = new OrgChartFieldWrapper(ocf);
        Org_Chart_Field__c result = wrapper.toSObject();

        // Then
        system.assertEquals(ocf.Id, result.Id);
        system.assertEquals(ocf.Name, result.Name);
        system.assertEquals(ocf.ObjectName__c, result.ObjectName__c);
        system.assertEquals(ocf.FieldName__c, result.FieldName__c);
        system.assertEquals(ocf.FieldLabel__c, result.FieldLabel__c);
        system.assertEquals(ocf.isRequired__c, result.isRequired__c);
        system.assertEquals(ocf.isVisible__c, result.isVisible__c);
        system.assertEquals(ocf.Map_Type__c, result.Map_Type__c);
    }

    @isTest
    static void toSObjectListTest() {
        // Given
        List<OrgChartFieldWrapper> wrapperList = new List<OrgChartFieldWrapper>();
        List<Org_Chart_Field__c> result = OrgChartFieldWrapper.toSObjectList(wrapperList);

        // Then
        system.assertEquals(0, result.size());
    }

    @isTest
    static void toSObjectListTest2() {
        // Given
        Org_Chart_Field__c ocf = new Org_Chart_Field__c(
            Id = fflib_IDGenerator.generate(Org_Chart_Field__c.SObjectType),
            Name = 'name',
            ObjectName__c = 'Key_Stakeholder__c',
            FieldName__c = 'pqcrush__Influence__c',
            FieldLabel__c = 'Influence',
            isRequired__c = true,
            isVisible__c = true,
            Map_Type__c = 'Relationship Map',
            IsMain__c = false
        );

        OrgChartFieldWrapper wrapper = new OrgChartFieldWrapper(ocf);
        List<OrgChartFieldWrapper> wrapperList = new List<OrgChartFieldWrapper>{ wrapper };
        List<Org_Chart_Field__c> result = OrgChartFieldWrapper.toSObjectList(wrapperList);

        // Then
        system.assertEquals(1, result.size());
    }
}