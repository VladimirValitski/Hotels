/**
 * Created by vvalitsky on 12/4/2019.
 */

@IsTest
private class SwitcherControllerTest {

    @testSetup
    static void setup() {
        Date dateIn = Date.today();
        Date dateOut = dateIn.addDays(2);
        Id preReservationRecordTypeId =
            Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Pre-reservation').getRecordTypeId();
        Id reservationRecordTypeId =
            Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Reservation').getRecordTypeId();
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

        Reservation__c reservation1 = new Reservation__c(Check_in_Date__c = dateIn,
            Check_out_Date__c = dateOut,
            Contact__c = contact.Id,
            Room__c = room.Id,
            TotalPrice__c = 1500,
            RecordTypeId = preReservationRecordTypeId
        );
        insert reservation1;

        Reservation__c reservation2 = new Reservation__c(Check_in_Date__c = dateIn.addDays(5),
            Check_out_Date__c = dateIn.addDays(7),
            Contact__c = contact.Id,
            Room__c = room.Id,
            TotalPrice__c = 2500,
            RecordTypeId = reservationRecordTypeId
        );
        insert reservation2;

        Additional_service__c additionalService = new Additional_service__c(Name = 'WiFi');
        insert additionalService;

        Room_Service__c roomService = new Room_Service__c(Price__c = 5,
            Additional_service__c = additionalService.Id,
            Room__c = room.Id
        );
        insert roomService;
    }

    @IsTest
    static void switchToPreReservationStatusTest() {
        Id preReservationRecordTypeId =
            Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Pre-reservation').getRecordTypeId();
        Reservation__c reservation = [
            SELECT Id
            FROM Reservation__c
            WHERE RecordTypeId = :preReservationRecordTypeId
            LIMIT 1
        ];

        Test.startTest();
        String status = SwitcherController.switchToReservationStatus(reservation.Id);
        Test.stopTest();

        System.assertEquals('success', status);
    }

    @IsTest
    static void switchToReservationStatusTest() {
        Id reservationRecordTypeId =
            Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Reservation').getRecordTypeId();
        Reservation__c reservation = [
            SELECT Id
            FROM Reservation__c
            WHERE RecordTypeId = :reservationRecordTypeId
            LIMIT 1
        ];

        Test.startTest();
        String status = SwitcherController.switchToReservationStatus(reservation.Id);
        Test.stopTest();

        System.assertEquals('success', status);
    }

}