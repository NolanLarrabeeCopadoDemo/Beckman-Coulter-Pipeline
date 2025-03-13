public with sharing class AccountLogic {
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

        // Check CRUD/FLS permissions
        if (!Schema.sObjectType.Account.isUpdateable() || 
            !Schema.sObjectType.Account.fields.Description.isUpdateable()) {
            throw new SecurityException('Insufficient permissions to update Account Description');
        }
        
        // Using proper if-else block structure with braces
        if (String.isNotBlank(accountToUpdate.Description)) {
            return accountToUpdate;
        } else {
            accountToUpdate.Description = 'Default Description';
        }

        // Check if we have access to read Accounts
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new SecurityException('Insufficient permissions to access Accounts');
        }

        // Secure SOQL query with sharing rules enforced
        List<Account> accounts = [
            SELECT Id, Description 
            FROM Account 
            WHERE Id = :accountToUpdate.Id 
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        // Collect records for DML operation
        List<Account> accountsToUpdate = new List<Account>();
        accountsToUpdate.add(accountToUpdate);
        
        // Single DML operation with error handling
        try {
            // Perform secure update
            update as user accountsToUpdate;
        } catch (DmlException e) {
            // Proper error handling
            System.debug(LoggingLevel.ERROR, 'Error updating accounts: ' + e.getMessage());
            throw new AccountLogicException('Failed to update accounts: ' + e.getMessage());
        } catch (SecurityException e) {
            System.debug(LoggingLevel.ERROR, 'Security violation: ' + e.getMessage());
            throw new AccountLogicException('Security violation: ' + e.getMessage());
        }
        
        return accountToUpdate;
    }
    
    // Custom exception class
    public class AccountLogicException extends Exception {}
}