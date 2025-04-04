public with sharing class OpportunityTriggerHandler {
     // Set default Type for new Opportunities
     public static void setDefaultType(List<Opportunity> opportunities) {  
        for(Opportunity opp : opportunities){
            if (opp.Type == null){
                opp.Type = 'New Customer';
            } 
        }
    }
     // When an opportunity is updated validate that the amount is greater than 5000.
     public static void validateAmount(List<Opportunity> opportunities) {  
        for(Opportunity opp : opportunities){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }
    //Get contacts related to the opportunity account
    public static void setPrimaryContact(List<Opportunity> opportunities) {     
       Set<Id> accountIds = new Set<Id>();
       for(Opportunity opp : opportunities){
           accountIds.add(opp.AccountId);
       }
       
       Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
       Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

       for (Contact cont : contacts.values()) {
           if (!accountIdToContact.containsKey(cont.AccountId)) {
               accountIdToContact.put(cont.AccountId, cont);
           }
       }

       for(Opportunity opp : opportunities){
           if(opp.Primary_Contact__c == null){
               if (accountIdToContact.containsKey(opp.AccountId)){
                   opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
               }
           }
       }
    }
    public static void createTaskForOpportunity(List<Opportunity> opportunities){
        try {
            List<Task> taskList = new List<Task>();
            // Create a new Task for newly inserted Opportunities
            for (Opportunity opp : opportunities){
                Task tsk = new Task();
                tsk.Subject = 'Call Primary Contact';
                tsk.WhatId = opp.Id;
                tsk.WhoId = opp.Primary_Contact__c;
                tsk.OwnerId = opp.OwnerId;
                tsk.ActivityDate = Date.today().addDays(3);
                taskList.add(tsk);
            }
            insert taskList;
        }
        catch(DmlException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    //When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
    public static void preventDeletionOfClosedWon(List<Opportunity> opportunities) {  
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :Trigger.old)]);
        for(Opportunity opp : opportunities){
            if(opp.StageName == 'Closed Won'){
                if(accounts.get(opp.AccountId).Industry == 'Banking'){
                    opp.addError('Cannot delete a closed won opportunity for a banking account');
                }
            }
            //The above loops resolves the below code since if the stage is 'closed won' the isclosed will be true.
            //hence both deals the same condition
            // Prevent deletion of closed Opportunities
            /* else if (opp.IsClosed){
                opp.addError('Cannot delete closed opportunity');
            }*/
        }
    }
    public static void appendChangesInDescription(List<Opportunity> opport ,List<Opportunity> oldMap) {
        try {
            // Append Stage changes in Opportunity Description
            List<Opportunity> opportunities = new List<Opportunity>();
            Map<Id, Opportunity> oldOpp = new Map<Id, Opportunity>(oldMap);
            for (Opportunity opp : opport){
                //for (Opportunity oldOpp : Trigger.old){
                if (opp.StageName != null && opp.StageName != oldOpp.get(opp.Id).StageName)
                {
                    opportunity opps = new opportunity();
                    opps.id = opp.id;
                    opps.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
                    opportunities.add(opps);
                }
                //}     
            }
            update opportunities;
        }
        catch(DmlException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    /*
    notifyOwnersOpportunityDeleted:
    - Sends an email notification to the owner of the Opportunity when it gets deleted.
    - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
    public static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity opp : opps) {
            ownerIds.add(opp.OwnerId);
        }
        Map<Id, String> userEmails = new Map<Id, String>();
        for (User user : [SELECT Id, Email FROM User WHERE Id IN :ownerIds]) {
            userEmails.put(user.Id, user.Email);
        } 
        for (Opportunity opp : opps){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new String[] {[SELECT Id, Email FROM User WHERE Id = :opp.OwnerId].Email};
            mail.setToAddresses(new string[] {userEmails.get(opp.OwnerId)});
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    /*
    assignPrimaryContact:
    - Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
    - Only updates the Opportunities that don't already have a primary contact.
    */
    public static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> accountIDs = new Set<Id>();
        for(Opportunity opp : oppNewMap.values()) {
            accountIDs.add(opp.AccountId);
        }
        Map<Id,Contact> primaryContact = new Map<Id,Contact>();
        for(Contact con : [SELECT Id, AccountId 
                           FROM Contact 
                           WHERE Title = 'VP Sales' AND AccountId in :accountIDs])
        {
          primaryContact.put(con.AccountId,con);
        }
        for (Opportunity opp : oppNewMap.values()){            
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = primaryContact.get(opp.AccountId).Id;
                oppMap.put(opp.Id, oppToUpdate);
            }
        }
        update oppMap.values();
    }
   
}