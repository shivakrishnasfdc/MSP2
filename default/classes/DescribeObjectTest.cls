@isTest
private class DescribeObjectTest {
    @isTest
    static void testProperties() {
        DescribeObject obj = new DescribeObject();
        obj.name = 'john';
        obj.isAccessible = true;
        obj.isUpdateable = true;
        System.assertEquals('john', obj.name);
        System.assert(obj.isAccessible);
        System.assert(obj.isUpdateable);
    }
}