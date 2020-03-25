/**
 * Created by vvalitsky on 12/24/2019.
 */
({
    getCities: function (component) {
        var action = component.get('c.getAvailableCity');
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.cities', response.getReturnValue());
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    getHotels: function (component, selectedCityParam) {
        let action = component.get('c.getAvailableHotels');
        action.setParams({ "selectedCity": selectedCityParam });
        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.availableHotels', response.getReturnValue());
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
})