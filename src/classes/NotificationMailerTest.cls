/**
 * Created by vvalitsky on 12/4/2019.
 */

@IsTest
private class NotificationMailerTest {

    @testSetup
    static void setup() {
        Date dateIn = Date.today();
        Date dateOut = dateIn.addDays(2);
        Id preReservationRecordTypeId =
            Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Pre-reservation').getRecordTypeId();
        Id vipRoomRecordTypeId =
            Schema.SObjectType.Room__c.getRecordTypeInfosByName().get('VIP Room').getRecordTypeId();

        Contact contact = new Contact(FirstName = 'Aron',
            LastName = 'Serb',
            Email = 'aserb@mail.ru',
            Phone = '02135464645'
        );
        insert contact;

        Hotel__c hotel = new Hotel__c(Name = 'TestHotel',
            City__c = 'LA'
        );
        insert hotel;

        Room__c room = new Room__c(Name = '4room_001',
            Price__c = 400,
            Max_number_of_guest__c = 4,
            Hotel__c = hotel.Id,
            RecordTypeId = vipRoomRecordTypeId
        );
        insert room;

        Reservation__c reservation = new Reservation__c(Check_in_Date__c = dateIn,
            Check_out_Date__c = dateOut,
            Contact__c = contact.Id,
            Room__c = room.Id,
            TotalPrice__c = 1500,
            RecordTypeId = preReservationRecordTypeId
        );
        insert reservation;
    }

    @IsTest
    static void sendReportTest() {
        Date today = Date.today();
        Date checkInDate = today.addDays(10);
        Date checkOutDate = checkInDate.addDays(12);
        Contact contact = [
            SELECT Id
            FROM Contact
            WHERE LastName = 'Serb'
            LIMIT 1
        ];
        Room__c room = [
            SELECT Id, Price__c
            FROM Room__c
            WHERE Name = '4room_001'
            LIMIT 1
        ];
        List<String> contactsData = new List<String>{
            String.valueOf(contact.Id), String.valueOf(checkInDate),
            String.valueOf(checkOutDate), String.valueOf(room.Id), String.valueOf(room.Price__c)
        };

        Test.startTest();
        NotificationMailer.sendReport(contactsData);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'Email has not been send');
    }

}