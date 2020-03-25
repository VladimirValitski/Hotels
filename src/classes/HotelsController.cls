/**
 * Created by vvalitsky on 11/13/2019.
 */

global with sharing class HotelsController {

    public class HotelDataWrapper {
        @AuraEnabled public Date checkInDate;
        @AuraEnabled public Date checkOutDate;
        @AuraEnabled public Decimal countOfGuest;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String contactEmail;
        @AuraEnabled public String phone;
        @AuraEnabled public Id roomId;
        @AuraEnabled public Decimal totalPrice;
        @AuraEnabled public String cityName;
        @AuraEnabled public Id hotelId;

        public HotelDataWrapper(Date checkInDate, Date checkOutDate, Decimal countOfGuest, String cityName,
            String hotelId) {
            this.checkInDate = checkInDate;
            this.checkOutDate = checkOutDate;
            this.countOfGuest = countOfGuest;
            this.cityName = cityName;
            this.hotelId = hotelId;
        }

        public HotelDataWrapper(Date checkInDate, Date checkOutDate, String firstName, String lastName,
            String contactEmail, String phone, Id roomId, Decimal totalPrice) {
            this.checkInDate = checkInDate;
            this.checkOutDate = checkOutDate;
            this.firstName = firstName;
            this.lastName = lastName;
            this.contactEmail = contactEmail;
            this.phone = phone;
            this.roomId = roomId;
            this.totalPrice = totalPrice;
        }
    }

    public class RoomsWrapper {

        @AuraEnabled public Id roomId;
        @AuraEnabled public String roomName;
        @AuraEnabled public Decimal countOfGuest;
        @AuraEnabled public Boolean isHaveAddService;
        @AuraEnabled public Decimal roomPrice;

        public RoomsWrapper(Id roomId, String roomName, Decimal countOfGuest, Boolean isHaveAddService,
            Decimal roomPrice) {
            this.roomId = roomId;
            this.roomName = roomName;
            this.countOfGuest = countOfGuest;
            this.isHaveAddService = isHaveAddService;
            this.roomPrice = roomPrice;
        }
    }

    public class PicklistOption {

        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }

        public PicklistOption(Schema.PicklistEntry entry) {
            label = entry.getLabel();
            value = entry.getValue();
        }
    }

    @AuraEnabled
    public static List<PicklistOption> getAvailableCity() {
        System.debug([select Id, Name, IsActive FROM User Where IsActive = true AND Id =: userInfo.getUserId()]);
        List<PicklistOption> result = new List<PicklistOption>();
        Schema.DescribeFieldResult fieldResult = Hotel__c.City__c.getDescribe();
        if (fieldResult != null) {
            for (Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
                result.add(
                    new PicklistOption(f)
                );
            }
        }
        return result;
    }

    @AuraEnabled
    public static List<PicklistOption> getAvailableHotels(String selectedCity) {
        List<PicklistOption> hotelNames = new List<PicklistOption>();
        List<Hotel__c> selectedHotels = [
            SELECT Name
            FROM Hotel__c
            WHERE City__c = :selectedCity
        ];
        if (!selectedHotels.isEmpty()) {
            for (Hotel__c hotel : selectedHotels) {
                hotelNames.add(
                    new PicklistOption(hotel.Name, hotel.Id)
                );
            }
        }
        return hotelNames;
    }

    @AuraEnabled
    public static List<RoomsWrapper> getAvailableRooms(String roomData) {
        HotelDataWrapper roomsData = (HotelDataWrapper) JSON.deserializeStrict(roomData, HotelDataWrapper.class);
        List<Id> unAvailableRoomIds = new List<Id>();
        Integer reservedDays = roomsData.checkInDate.daysBetween(roomsData.checkOutDate);
        List<RoomsWrapper> availableRooms = new List<RoomsWrapper>();

        AggregateResult[] aggregateResults = [
            SELECT COUNT(Id) quantity, Room__c
            FROM Reservation__c
            WHERE (
                (
                    (
                        Check_in_Date__c >= :roomsData.checkInDate AND
                        Check_in_Date__c <= :roomsData.checkOutDate
                    ) OR (
                        Check_out_Date__c >= :roomsData.checkInDate AND
                        Check_out_Date__c <= :roomsData.checkOutDate
                    )
                ) AND
                Room__r.Hotel__r.City__c = :roomsData.cityName AND
                Room__r.Hotel__r.Id = :roomsData.hotelId
            )
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
            AND Hotel__r.Id = :roomsData.hotelId
            AND Hotel__r.City__c = :roomsData.cityName
            AND Max_number_of_guest__c >= :roomsData.countOfGuest
        ];
        if (!availableForReservationRooms.isEmpty()) {
            for (Room__c room : availableForReservationRooms) {
                availableRooms.add(new HotelsController.RoomsWrapper(room.Id, room.Name, room.Max_number_of_guest__c,
                    room.RecordType.Name == 'VIP Room', room.Price__c * reservedDays));
            }
        }
        return availableRooms;
    }

    @AuraEnabled
    public static List<Map<String, Decimal>> getAddServices(String selectedRoomId) {
        List<Map<String, Decimal>> result = new List<Map<String, Decimal>>();
        Map<String, Decimal> priceByServiceName = new Map<String, Decimal>();
        List<Room_Service__c> roomServices = [
            SELECT Price__c, Additional_service__r.Name
            FROM Room_Service__c
            WHERE Room__r.Id = :selectedRoomId
        ];
        if (!roomServices.isEmpty()) {
            for (Room_Service__c roomService : roomServices) {
                priceByServiceName.put(roomService.Additional_service__r.Name, roomService.Price__c);
            }
            result.add(priceByServiceName);
        }
        return result;
    }

    @AuraEnabled
    public static List<String> getAdditionalServicesOptions(String selectedRoomId) {
        List<String> options = new List<String>();
        String roomServicesPair;
        List<Room_Service__c> roomServices = [
            SELECT Price__c, Additional_service__r.Name
            FROM Room_Service__c
            WHERE Room__r.Id = :selectedRoomId
        ];
        if (!roomServices.isEmpty()) {
            for (Room_Service__c roomService : roomServices) {
                roomServicesPair = '{\"label\": \"' + roomService.Additional_service__r.Name + '", \"value\": \"'
                    + roomService.Price__c + '\"}';
                options.add(roomServicesPair);
            }
        }
        return options;
    }

    @AuraEnabled
    public static String registerRoom(String reservationData) {
        String result;
        Contact checkedContact;
        Id preReservationRecordTypeId =
            Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Pre-reservation').getRecordTypeId();
        HotelDataWrapper registerData = (HotelDataWrapper)
            JSON.deserializeStrict(reservationData, HotelDataWrapper.class);
        Contact contact = new Contact(FirstName = registerData.firstName,
            LastName = registerData.lastName,
            Email = registerData.contactEmail,
            Phone = registerData.phone
        );
        try {
            checkedContact = checkForUniqueContact(contact);
            upsert checkedContact;
        } catch (DmlException de) {}
        if (checkedContact.Id != null) {
            Reservation__c reservation = new Reservation__c(
                Check_in_Date__c = Date.valueOf(registerData.checkInDate),
                Check_out_Date__c = Date.valueOf(registerData.checkOutDate),
                Contact__c = checkedContact.Id,
                Room__c = registerData.roomId,
                TotalPrice__c = registerData.totalPrice,
                RecordTypeId = preReservationRecordTypeId
            );
            try {
                insert reservation;
                result = System.Label.SuccessfulReservationMessage;
                NotificationMailer.sendReport(new List<String>{
                    String.valueOf(reservation.Contact__c),
                    String.valueOf(reservation.Check_in_Date__c), String.valueOf(reservation.Check_out_Date__c),
                    String.valueOf(reservation.Room__c), String.valueOf(reservation.TotalPrice__c)
                });
            } catch (DmlException de) {
                result = System.Label.BadReservationMessage;
            }
        } else {
            result = System.Label.BadReservationTryAgainMessage;
        }
        return result;
    }

    private static Contact checkForUniqueContact(Contact contact) {
        Contact checkedContact;
        List<Contact> checkedContacts = [
            SELECT FirstName, LastName, Email, Phone
            FROM Contact
            WHERE Email = :contact.Email
            LIMIT 1
        ];
        if (!checkedContacts.isEmpty()) {
            checkedContact = checkedContacts[0];
        } else {
            checkedContact = contact;
        }
        return checkedContact;
    }

}