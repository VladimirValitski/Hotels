/**
 * Created by vvalitsky on 11/29/2019.
 */
({
    switchToReservation: function (component, recordIdParam) {
            let action = component.get('c.switchToReservationStatus');
            action.setParams({ 'recordId': recordIdParam });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.isVisible', true);
                    component.set('v.status', response.getReturnValue());
                    $A.get('e.force:refreshView').fire();
                } else if (state === "ERROR") {
                    component.set('v.isVisible', true);
                }
            });
            $A.enqueueAction(action);
    },
})