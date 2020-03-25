/**
 * Created by vvalitsky on 12/4/2019.
 */

@IsTest
private class HotelsControllerTest {

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

        Additional_service__c additionalService = new Additional_service__c(Name = 'WiFi');
        insert additionalService;

        Room_Service__c roomService = new Room_Service__c(Price__c = 5,
            Additional_service__c = additionalService.Id,
            Room__c = room.Id
        );
        insert roomService;
    }

    @IsTest
    static void getAvailableCityTest() {
        Schema.DescribeFieldResult fieldResult = Hotel__c.City__c.getDescribe();
        String city = fieldResult.getPicklistValues()[0].value;
        Integer pickListSize = fieldResult.getPicklistValues().size();

        Test.startTest();
        List<HotelsController.PicklistOption> cityNames = HotelsController.getAvailableCity();
        Test.stopTest();

        System.assertEquals(pickListSize, cityNames.size());
        System.assertEquals(city, cityNames[0].value);
    }

    @IsTest
    static void getAvailableHotelsTest() {
        List<Hotel__c> hotels = [
            SELECT Name
            FROM Hotel__c
            WHERE City__c = 'LA'
        ];

        Test.startTest();
        List<HotelsController.PicklistOption> hotelNames = HotelsController.getAvailableHotels('LA');
        Test.stopTest();

        System.assertEquals(hotels.size(), hotelNames.size());
        System.assertEquals(hotels[0].Name, hotelNames[0].label);
    }

    @IsTest
    static void getAvailableRoomsTest() {
        List<Hotel__c> hotels = [
            SELECT Id, Name
            FROM Hotel__c
            WHERE City__c = 'LA'
        ];
        Date today = Date.today();
        Date checkInDate = today.addDays(10);
        Date checkOutDate = checkInDate.addDays(12);
        Decimal countOfGuest = 2;
        String cityName = 'LA';
        List<Id> unAvailableRoomIds = new List<Id>();
        AggregateResult[] aggregateResults = [
            SELECT COUNT(Id) quantity, Room__c
            FROM Reservation__c
            WHERE (
                ((Check_in_Date__c >= :checkInDate AND
                Check_in_Date__c <= :checkOutDate) OR
                (Check_out_Date__c >= :checkInDate AND
                Check_out_Date__c <= :checkOutDate)) AND
                Room__r.Hotel__r.City__c = :cityName AND
                Room__r.Hotel__r.Id = :hotels[0].Id)
            GROUP BY Room__c
        ];
        if (!aggregateResults.isEmpty()) {
            for (AggregateResult aggregateResult : aggregateResults) {
                unAvailableRoomIds.add((Id) aggregateResult.get('Room__c'));
            }
        }
        List<Room__c> availableForReservationRooms = [
            SELECT Id,RecordType.Name, Name, Price__c, Max_number_of_guest__c, Hotel__r.City__c, Hotel__r.Name
            FROM Room__c
            WHERE Id NOT IN :unAvailableRoomIds
            AND Hotel__r.Id = :hotels[0].Id AND Hotel__r.City__c = :cityName
        ];

        HotelsController.HotelDataWrapper dataWrapper =
            new HotelsController.HotelDataWrapper(checkInDate, checkOutDate, countOfGuest, cityName, hotels[0].Id);
        String roomData = JSON.serialize(dataWrapper);

        Test.startTest();
        List<HotelsController.RoomsWrapper> availableRooms = HotelsController.getAvailableRooms(roomData);
        Test.stopTest();

        System.assertEquals(availableForReservationRooms.size(), availableRooms.size());
        System.assertEquals(availableForReservationRooms[0].Name, availableRooms[0].roomName);
    }

    @IsTest
    static void getAddServicesTest() {
        List<Room__c> rooms = [
            SELECT Id
            FROM Room__c
            WHERE Name = '4room_001'
        ];
        List<Room_Service__c> roomServices = [
            SELECT Price__c, Additional_service__r.Name
            FROM Room_Service__c
            WHERE Room__r.Id = :rooms[0].Id
        ];

        Test.startTest();
        List<Map<String, Decimal>> addServices = HotelsController.getAddServices(String.valueOf(rooms[0].Id));
        Test.stopTest();
        Decimal addServicePrice = addServices[0].get('WiFi');

        System.assertEquals(rooms.size(), addServices.size());
        System.assertEquals(roomServices[0].Price__c, addServicePrice);
    }

    @IsTest
    static void getAdditionalServicesOptionsTest() {
        List<Room__c> rooms = [
            SELECT Id
            FROM Room__c
            WHERE Name = '4room_001'
        ];
        List<Room_Service__c> roomServices = [
            SELECT Price__c, Additional_service__r.Name
            FROM Room_Service__c
            WHERE Room__r.Id = :rooms[0].Id
        ];

        Test.startTest();
        List<String> options = HotelsController.getAdditionalServicesOptions(String.valueOf(rooms[0].Id));
        Test.stopTest();

        System.assertEquals(roomServices.size(), options.size());
        System.assert(options[0].contains(String.valueOf(roomServices[0].Price__c)));
    }

    @IsTest
    static void registerRoomTest() {
        List<Room__c> rooms = [
            SELECT Id
            FROM Room__c
            WHERE Name = '4room_001'
        ];
        Date checkInDate = Date.today();
        Date checkOutDate = checkInDate.addDays(2);
        String firstName = 'Adam';
        String lastName = 'Malysh';
        String contactEmail = 'malysh@gmail.com';
        String phone = '00075480032';
        Id roomId = rooms[0].Id;
        Decimal totalPrice = 405;

        HotelsController.HotelDataWrapper hotelDataWrapper =
            new HotelsController.HotelDataWrapper(checkInDate, checkOutDate, firstName, lastName, contactEmail, phone,
                roomId, totalPrice);

        Test.startTest();
        String result = HotelsController.registerRoom(JSON.serialize(hotelDataWrapper));
        Test.stopTest();

        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Phone
            FROM Contact
            WHERE Email = :contactEmail
        ];
        List<Reservation__c> reservations = [
            SELECT Id, Contact__c, Room__c
            FROM Reservation__c
            WHERE Contact__c = :contacts[0].Id
        ];

        System.assertEquals('Reservation was Successful', result);
        System.assertEquals(phone, contacts[0].Phone);
        System.assertEquals(roomId, reservations[0].Room__c);
    }

}