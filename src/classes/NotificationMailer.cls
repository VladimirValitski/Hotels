/**
 * Created by vvalitsky on 11/26/2019.
 */

public with sharing class NotificationMailer {

    public static void sendReport(List<String> contactData) {
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Datetime currentDate = System.now();
        Contact contact = [
            SELECT FirstName, LastName, Email
            From Contact
            WHERE Id = :contactData[0]
            Limit 1
        ];
        Room__c room = [
            SELECT Name, Hotel__r.Name, Hotel__r.City__c
            FROM Room__c
            WHERE Id = :contactData[3]
            Limit 1
        ];
        mail.setSubject('Reservation hotel');
        EmailTemplate template = [
            SELECT Id, Name, Subject, Body
            FROM EmailTemplate
            WHERE Name = 'Reservation'
            LIMIT 1
        ];
        List<String> parameters = new List<String>();
        parameters.addAll(contactData);
        parameters.add(contact.FirstName);
        parameters.add(contact.LastName);
        parameters.add(room.Hotel__r.City__c);
        parameters.add(room.Hotel__r.Name);
        parameters.add(String.valueOf(currentDate));
        String plainBody = String.format(template.Body, parameters);
        mail.setTargetObjectId(contactData[0]);
        mail.setTemplateId(template.Id);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(plainBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
            mail
        });
    }

}