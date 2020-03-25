/**
 * Created by vvalitsky on 11/29/2019.
 */

global with sharing class SwitcherController {

    @AuraEnabled
    public static String switchToReservationStatus(String recordId) {
        String status;
        Id preReservationRecordTypeId =
            Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get(System.Label.PreReservation).getRecordTypeId();
        Id reservationRecordTypeId =
            Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get(System.Label.Reservation).getRecordTypeId();
        List<Reservation__c> reservations = [
            SELECT Id, RecordType.Name, RecordTypeId
            FROM Reservation__c
            WHERE Id = :recordId
        ];
        if (!reservations.isEmpty()) {
            if (reservations[0].RecordTypeId == preReservationRecordTypeId) {
                reservations[0].RecordTypeId = reservationRecordTypeId;
                try {
                    update reservations;
                    status = System.Label.Success;
                } catch (DmlException de) {}
            } else if (reservations[0].RecordTypeId == reservationRecordTypeId) {
                reservations[0].RecordTypeId = preReservationRecordTypeId;
                update reservations;
                status = System.Label.Success;
            }
        }
        return status;
    }

}