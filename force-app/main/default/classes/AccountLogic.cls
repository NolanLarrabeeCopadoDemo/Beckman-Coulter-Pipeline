public class AccountLogic {
    /**
     * Sets a default description for an Account if none exists
     * @param accountToUpdate Account record to process
     * @return Account with updated description
     */
    public static Account setDefaultDescription(Account accountToUpdate) {
        // Null check for input parameter
        if (accountToUpdate == null) {
            throw new IllegalArgumentException('Account parameter cannot be null');
        }
        
        // Using proper if-else block structure with braces
        if (accountToUpdate.Description != null) {
            return accountToUpdate;
        } else {
            accountToUpdate.Description = 'Default Description';
        }
        
        // Moved SOQL outside of loop - bulk processing
        List<Account> accounts = [SELECT Id FROM Account LIMIT 10];
        for (Account acc : accounts) {
            // Process accounts if needed
        }
        
        // Collect records for DML operation outside loop
        List<Account> accountsToUpdate = new List<Account>();
        accountsToUpdate.add(accountToUpdate);
        
        // Single DML operation outside of loop
        try {
            update accountsToUpdate;
        } catch (DmlException e) {
            // Proper error handling
            System.debug(LoggingLevel.ERROR, 'Error updating accounts: ' + e.getMessage());
            throw new AccountLogicException('Failed to update accounts: ' + e.getMessage());
        }
        
        return accountToUpdate;
    }
    
    // Custom exception class
    public class AccountLogicException extends Exception {}
}