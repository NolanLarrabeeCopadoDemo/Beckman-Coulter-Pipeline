@IsTest
private class AccountLogicTest {
    @TestSetup
    static void setupTestData() {
        // Create test user with appropriate permissions
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser@testorg.com' + System.currentTimeMillis()
        );
        insert testUser;
    }

    // ... other test methods remain the same ...

    @IsTest
    static void testSecurityException() {
        // Create a user with read-only permissions
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only'];
        User restrictedUser = new User(
            Alias = 'ruser',
            Email = 'restricteduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Restricted',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'restricteduser@testorg.com' + System.currentTimeMillis()
        );
        insert restrictedUser;

        // First create the Account as admin user
        Account testAccount = new Account(
            Name = 'Test Account',
            Description = null
        );
        insert testAccount;

        System.runAs(restrictedUser) {
            testAccount = [SELECT Id, Name, Description FROM Account WHERE Id = :testAccount.Id];
            
            Test.startTest();
            try {
                AccountLogic.setDefaultDescription(testAccount);
                System.assert(false, 'Should have thrown a security exception');
            } catch (SecurityException e) {
                // Verify the security exception message
                System.assert(e.getMessage().contains('Insufficient permissions'), 
                    'Expected insufficient permissions message, got: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }
}