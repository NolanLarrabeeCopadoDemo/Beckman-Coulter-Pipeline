@IsTest
private class AccountAutomationsTest {

    @isTest 
    static void testDefaultDescription(){
        // Test case 1: Null description
        Account acc1 = new Account(Name = 'My Test Account');
        acc1 = AccountAutomations.setDefaultDescription(acc1);
        System.assertEquals('Default description', acc1.Description, 'When description is null, it should be updated to Default description');

        // Test case 2: Non-null description
        Account acc2 = new Account(Name = 'My Test Account', Description = 'New Description Manual');
        acc2 = AccountAutomations.setDefaultDescription(acc2);
        System.assertEquals('New Description Manual', acc2.Description, 'When description is NOT null, it should NOT be updated');
    }

    @isTest 
    static void testDefaultSite(){
        Account acc = new Account(Name = 'My Test Account');
        acc = AccountAutomations.setDefaultSite(acc);
        System.assertEquals('Single location', acc.Site, 'Default Site should be Single location');
    }

    @isTest 
    static void testDefaultShippingAddress(){
        Account acc = new Account(Name = 'My Test Account');
        acc = AccountAutomations.setDefaultShippingAddress(acc);
        System.assertEquals('111 W Illinois St', acc.ShippingStreet, 'Default ShippingStreet should be 111 W Illinois St');
        System.assertEquals('Chicago', acc.ShippingState, 'Default ShippingState should be Chicago');
        System.assertEquals('60654', acc.ShippingPostalCode, 'Default ShippingPostalCode should be 60654');
    }

    @isTest 
    static void testDefaultPhone(){
        Account acc = new Account(Name = 'My Test Account');
        acc = AccountAutomations.setDefaultPhone(acc);
        System.assertEquals('9999999', acc.Phone, 'Default phone number should be 9999999');
    }

    @isTest 
    static void testDefaultURL(){
        Account acc = new Account(Name = 'My Test Account');
        acc = AccountAutomations.setDefaultURL(acc);
        System.assertEquals('www.copado.com', acc.Website, 'Default website should be www.copado.com');
    }

}