@IsTest
private class AccountOperationsTest {
    @IsTest static void setDefaultDescription(){
        // Create account without description
        Account acc = new Account(Name = 'My New Test Account');
        
        // Call the method
        acc = AccountOperations.setDefaultDescription(acc);
        
        // Assert the change
        System.assertEquals('Default Description', acc.Description);
    }
}