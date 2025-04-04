/*
AnotherOpportunityTrigger Overview

This trigger was initially created for handling various events on the Opportunity object. It was developed by a prior developer and has since been noted to cause some issues in our org.

IMPORTANT:
- This trigger does not adhere to Salesforce best practices.
- It is essential to review, understand, and refactor this trigger to ensure maintainability, performance, and prevent any inadvertent issues.

ISSUES:
Avoid nested for loop - 1 instance
Avoid DML inside for loop - 1 instance
Bulkify Your Code - 1 instance
Avoid SOQL Query inside for loop - 2 instances
Stop recursion - 1 instance

RESOURCES: 
https://www.salesforceben.com/12-salesforce-apex-best-practices/
https://developer.salesforce.com/blogs/developer-relations/2015/01/apex-best-practices-15-apex-commandments
*/
trigger AnotherOpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
   /*if (Trigger.isBefore){
        if (Trigger.isInsert){
            // Set default Type for new Opportunities
            Opportunity opp = Trigger.new[0];
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }        
        } else if (Trigger.isDelete){
            // Prevent deletion of closed Opportunities
            for (Opportunity oldOpp : Trigger.old){
                if (oldOpp.IsClosed){
                    oldOpp.addError('Cannot delete closed opportunity');
                }
            }
        }
    }

    if (Trigger.isAfter){
        if (Trigger.isInsert){
            List<Task> taskList = new List<Task>();
            // Create a new Task for newly inserted Opportunities
            for (Opportunity opp : Trigger.new){
                Task tsk = new Task();
                tsk.Subject = 'Call Primary Contact';
                tsk.WhatId = opp.Id;
                tsk.WhoId = opp.Primary_Contact__c;
                tsk.OwnerId = opp.OwnerId;
                tsk.ActivityDate = Date.today().addDays(3);
                taskList.add(tsk);
            }
            insert taskList;
        } else if (Trigger.isUpdate){
            // Append Stage changes in Opportunity Description
           List<Opportunity> opportunities = new List<Opportunity>();
           Map<Id, Opportunity> oldOpp =new Map<Id, Opportunity>(Trigger.old);
            for (Opportunity opp : Trigger.new){
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
        // Send email notifications when an Opportunity is deleted 
        else if (Trigger.isDelete){
            notifyOwnersOpportunityDeleted(Trigger.old);
        } 
        // Assign the primary contact to undeleted Opportunities
        else if (Trigger.isUndelete){
            assignPrimaryContact(Trigger.newMap);
        }
    }*/

   
}