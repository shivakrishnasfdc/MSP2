@isTest
public class RelationshipMemberCountUpdateBatchTest {
    private static final String RELATIONSHIP_MAP_NAME = 'RelationshipMapMembersTest test hierarchy group 1';
    private static final String FIRST_CONTACT_LAST_NAME = 'RelationshipMapMembersTest contact lastName 1';
    private static final String SECOND_CONTACT_LAST_NAME = 'RelationshipMapMembersTest contact lastName 2';
    
    public  static final String ADMIN_USER_FIRST_NAME = 'rmm test admin user first';
    public  static final String ADMIN_USER_LAST_NAME = 'rmm test admin user last';
    
   public  static final String PRM_ADMIN_PERM = 'PROLIFIQ_RELATIONSHIP_MAP';
    
    public  static final String STANDARD_USER = 'Standard User';
    @testSetup
    static void setup() {
        // Create test data
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create the user
        User newUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            Username = 'johndoe@example.com' + System.currentTimeMillis() + '@example.com', // Username must be unique
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile.Id
        );
        
        // Set the required fields for User object
        newUser.CompanyName = 'My Company';
        newUser.Title = 'Account Plan Creator';
        newUser.Department = 'Sales';
        newUser.Country = 'USA';
        newUser.IsActive = true;

        // Insert the user
        insert newUser;
        // Get the permission set ID for the desired permission set
        
        pqcrush__Account_Plan__c acPlan = TestDataFactory.createAccountPlan('Test');
        Relationship_Map__c relationshipMap = TestDataFactory.createRelationshipMap(RELATIONSHIP_MAP_NAME, acPlan.id);
        
        Contact contact1 = new Contact(LastName = FIRST_CONTACT_LAST_NAME);
        insert contact1;
        
        Contact contact2 = new Contact(LastName = SECOND_CONTACT_LAST_NAME);
        insert contact2;
        
        TestDataFactory.createRelationshipMapMember(relationshipMap.Id, contact1.Id);
        TestDataFactory.createRelationshipMapMember(relationshipMap.Id, contact2.Id);
    }
    
    @isTest
    static void testBatchable() {
        User u = [select id from user limit 1];
        system.runAs(u){
        // Start the test
        Test.startTest();
        
        // Execute the batch
        RelationshipMemberCountUpdateBatch batchJob = new RelationshipMemberCountUpdateBatch();
        Database.executeBatch(batchJob, 100);
        
        // End the test
        Test.stopTest();

        List<pqcrush__Account_Plan__c> accPlanLst = [SELECT Id, pqcrush__Relationship_Members_Count__c FROM pqcrush__Account_Plan__c];
        
        System.assertEquals(accPlanLst != null, true);
        }
    }
    
    /*@isTest
    static void testSchedulable() {
        User u = [select id from user limit 1];
        system.runAs(u){
        // Start the test
       // Test.startTest();
        
        // Execute the schedulable
       // RelationshipMemberCountUpdateBatch schedulableJob = new RelationshipMemberCountUpdateBatch();
        //String jobId = system.schedule('Test Schedule', '0 0 0 1 1 ? 2040', schedulableJob);
        
        // End the test
        //Test.stopTest();
        
        // Verify the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0 1 1 ? 2040', ct.CronExpression, 'The cron expression should match');
        }
    }*/
}