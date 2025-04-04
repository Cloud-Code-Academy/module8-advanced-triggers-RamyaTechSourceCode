/*
OpportunityTrigger Overview

This class defines the trigger logic for the Opportunity object in Salesforce. It focuses on three main functionalities:
1. Ensuring that the Opportunity amount is greater than $5000 on update.
2. Preventing the deletion of a 'Closed Won' Opportunity if the related Account's industry is 'Banking'.
3. Setting the primary contact on an Opportunity to the Contact with the title 'CEO' when updating.

Usage Instructions:
For this lesson, students have two options:
1. Use the provided `OpportunityTrigger` class as is.
2. Use the `OpportunityTrigger` from you created in previous lessons. If opting for this, students should:
    a. Copy over the code from the previous lesson's `OpportunityTrigger` into this file.
    b. Save and deploy the updated file into their Salesforce org.

Remember, whichever option you choose, ensure that the trigger is activated and tested to validate its functionality.
*/
trigger OpportunityTrigger on Opportunity (before insert, after insert,before update, after update, before delete, after delete,  after undelete) {

   
    switch on Trigger.OperationType{
        // Set default Type for new Opportunities
        when BEFORE_INSERT {
            OpportunityTriggerHandler.setDefaultType(Trigger.new);
        }
         /*
        * Opportunity Trigger
        * When an opportunity is updated validate that the amount is greater than 5000.
        * When an opportunity is updated set the primary contact on the opportunity to the contact with the title of 'CEO'.
        * Trigger should only fire on update.
        */
        when BEFORE_UPDATE {
        OpportunityTriggerHandler.validateAmount(Trigger.new);
        OpportunityTriggerHandler.setPrimaryContact(Trigger.new);
        }
        // Create a new Task for newly inserted Opportunities
        when AFTER_INSERT {
            OpportunityTriggerHandler.createTaskForOpportunity(Trigger.new);
        }
        // Append Stage changes in Opportunity Description
        when AFTER_UPDATE {
            OpportunityTriggerHandler.appendChangesInDescription(Trigger.new,Trigger.old);
        }
        /*When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
        * Trigger should only fire on delete.*/
        when BEFORE_DELETE {
            OpportunityTriggerHandler.preventDeletionOfClosedWon(Trigger.old);
        }
        // Send email notifications when an Opportunity is deleted 
        when AFTER_DELETE {
            OpportunityTriggerHandler.notifyOwnersOpportunityDeleted(Trigger.old);
        }
        // Assign the primary contact to undeleted Opportunities
        when AFTER_UNDELETE {
            OpportunityTriggerHandler.assignPrimaryContact(Trigger.newMap);
        }
    }
}