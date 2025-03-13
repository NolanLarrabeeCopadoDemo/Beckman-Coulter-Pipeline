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

        // Create Read Only User
        Profile readOnlyProfile = [SELECT Id FROM Profile WHERE Name='Read Only'];
        User restrictedUser = new User(
            Alias = 'ruser',
            Email = 'restricteduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Restricted',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = readOnlyProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'restricteduser@testorg.com' + System.currentTimeMillis()
        );
        insert restrictedUser;
    }

    @IsTest 
    static void testSetDefaultDescriptionWithExistingDescription() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        
        System.runAs(testUser) {
            // Test data setup
            Account testAccount = new Account(
                Name = 'Test Account 1',
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
                Name = 'Test Account 2',
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
    static void testSetDefaultDescriptionWithEmptyDescription() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        
        System.runAs(testUser) {
            // Test data setup
            Account testAccount = new Account(
                Name = 'Test Account 3',
                Description = ''
            );
            insert testAccount;
            
            Test.startTest();
            Account resultAccount = AccountLogic.setDefaultDescription(testAccount);
            Test.stopTest();
            
            // Assertions
            System.assertEquals('Default Description', resultAccount.Description, 
                'Description should be set to default when empty');
            
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
            Test.startTest();
            try {
                AccountLogic.setDefaultDescription(null);
                System.assert(false, 'Should have thrown an IllegalArgumentException');
            } catch (IllegalArgumentException e) {
                System.assertEquals('Account parameter cannot be null', e.getMessage(), 
                    'Expected error message not found');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void testSecurityExceptionOnUpdate() {
        User restrictedUser = [SELECT Id FROM User WHERE Email = 'restricteduser@testorg.com' LIMIT 1];
        
        // First create the Account as admin user
        Account testAccount = new Account(
            Name = 'Test Account 4',
            Description = null
        );
        insert testAccount;

        System.runAs(restrictedUser) {
            testAccount = [SELECT Id, Name, Description FROM Account WHERE Id = :testAccount.Id];
            
            Test.startTest();
            try {
                AccountLogic.setDefaultDescription(testAccount);
                System.assert(false, 'Should have thrown a SecurityException');
            } catch (SecurityException e) {
                System.assert(e.getMessage().contains('Insufficient permissions'), 
                    'Expected insufficient permissions message, got: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void testDMLException() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        
        System.runAs(testUser) {
            // Create an account that will cause a DML exception
            Account testAccount = new Account(
                Description = null
                // Deliberately omitting required Name field to cause DML exception
            );
            
            Test.startTest();
            try {
                AccountLogic.setDefaultDescription(testAccount);
                System.assert(false, 'Should have thrown a SecurityException');
            } catch (SecurityException e) {
                System.assert(e.getMessage().contains('Insufficient permissions'), 
                    'Expected security exception message');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void testQueryException() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        
        System.runAs(testUser) {
            // Create an account with an invalid ID to cause a query exception
            Account testAccount = new Account(
                Id = '001000000000000', // Invalid ID
                Name = 'Test Account 5',
                Description = null
            );
            
            Test.startTest();
            try {
                AccountLogic.setDefaultDescription(testAccount);
                System.assert(false, 'Should have thrown a SecurityException');
            } catch (SecurityException e) {
                System.assert(e.getMessage().contains('Insufficient'), 
                    'Expected security exception message');
            }
            Test.stopTest();
        }
    }
}