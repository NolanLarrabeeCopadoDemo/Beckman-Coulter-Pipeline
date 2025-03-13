@IsTest
private class AccountLogicTest {
    @IsTest 
    static void testSetDefaultDescriptionWithExistingDescription() {
        // Test data setup
        Account testAccount = new Account(
            Name = 'My Test Account',
            Description = 'Existing description'
        );
        
        Test.startTest();
        Account resultAccount = AccountLogic.setDefaultDescription(testAccount);
        Test.stopTest();
        
        // Assertions
        System.assertEquals('Existing description', resultAccount.Description, 
            'Description should remain unchanged when it already exists');
    }
    
    @IsTest 
    static void testSetDefaultDescriptionWithNullDescription() {
        // Test data setup
        Account testAccount = new Account(
            Name = 'My Test Account',
            Description = null
        );
        
        Test.startTest();
        Account resultAccount = AccountLogic.setDefaultDescription(testAccount);
        Test.stopTest();
        
        // Assertions
        System.assertEquals('Default Description', resultAccount.Description, 
            'Description should be set to default when null');
    }
    
    @IsTest 
    static void testSetDefaultDescriptionWithNullAccount() {
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