/**
 * Created by vvalitsky on 11/29/2019.
 */
({
    doInit: function (component, event, helper) {
        let recordId = component.get('v.recordId');
        helper.switchToReservation(component, recordId);
    },
})