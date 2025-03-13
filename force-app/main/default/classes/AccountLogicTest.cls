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

    @IsTest 
    static void testSetDefaultDescriptionWithExistingDescription() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        
        System.runAs(testUser) {
            // Test data setup
            Account testAccount = new Account(
                Name = 'My Test Account',
                Description = 'Existing description'
            );
            insert testAccount;
            
            Test.startTest();
            Account resultAccount = AccountLogic.setDefaultDescription(testAccount);
            Test.stopTest();
            
            // Assertions
            System.assertEquals('Existing description', resultAccount.Description, 
                'Description should remain unchanged when it already exists');
            
            // Verify database state
            Account verifyAccount = [SELECT Description FROM Account WHERE Id = :testAccount.Id];
            System.assertEquals('Existing description', verifyAccount.Description, 
                'Database record should maintain existing description');
        }
    }
    
    @IsTest 
    static void testSetDefaultDescriptionWithNullDescription() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        
        System.runAs(testUser) {
            // Test data setup
            Account testAccount = new Account(
                Name = 'My Test Account',
                Description = null
            );
            insert testAccount;
            
            Test.startTest();
            Account resultAccount = AccountLogic.setDefaultDescription(testAccount);
            Test.stopTest();
            
            // Assertions
            System.assertEquals('Default Description', resultAccount.Description, 
                'Description should be set to default when null');
            
            // Verify database state
            Account verifyAccount = [SELECT Description FROM Account WHERE Id = :testAccount.Id];
            System.assertEquals('Default Description', verifyAccount.Description, 
                'Database record should have default description');
        }
    }
    
    @IsTest 
    static void testSetDefaultDescriptionWithNullAccount() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        
        System.runAs(testUser) {
            try {
                Test.startTest();
                AccountLogic.setDefaultDescription(null);
                Test.stopTest();
                System.assert(false, 'Should have thrown an exception');
            } catch (IllegalArgumentException e) {
                System.assertEquals('Account parameter cannot be null', e.getMessage(), 
                    'Expected error message not found');
            }
        }
    }

    @IsTest
    static void testSecurityException() {
        // Create a user with minimal permissions
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard Platform User'];
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

        System.runAs(restrictedUser) {
            Account testAccount = new Account(
                Name = 'Test Account',
                Description = null
            );
            
            try {
                Test.startTest();
                AccountLogic.setDefaultDescription(testAccount);
                Test.stopTest();
                System.assert(false, 'Should have thrown a security exception');
            } catch (AccountLogic.AccountLogicException e) {
                System.assert(e.getMessage().contains('Security violation'), 
                    'Expected security violation message');
            }
        }
    }
}