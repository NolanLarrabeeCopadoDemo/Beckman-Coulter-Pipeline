public with sharing class AccountLogic {
    /**
     * Sets a default description for an Account if none exists
     * @param accountToUpdate Account record to process
     * @return Account with updated description
     * @throws SecurityException if user lacks necessary permissions
     * @throws IllegalArgumentException if account parameter is null
     */
    public static Account setDefaultDescription(Account accountToUpdate) {
        // Null check for input parameter
        if (accountToUpdate == null) {
            throw new IllegalArgumentException('Account parameter cannot be null');
        }

        // Check CRUD/FLS permissions first
        if (!Schema.sObjectType.Account.isUpdateable()) {
            throw new SecurityException('Insufficient permissions to update Account');
        }
        
        if (!Schema.sObjectType.Account.fields.Description.isUpdateable()) {
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

        try {
            // Secure SOQL query with sharing rules enforced
            List<Account> accounts = [
                SELECT Id, Description 
                FROM Account 
                WHERE Id = :accountToUpdate.Id 
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            // Perform secure update
            update as user accountToUpdate;
            
        } catch (System.QueryException e) {
            throw new SecurityException('Insufficient field-level permissions: ' + e.getMessage());
        } catch (DmlException e) {
            throw new SecurityException('Insufficient permissions to update record: ' + e.getMessage());
        }
        
        return accountToUpdate;
    }
}