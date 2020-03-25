/**
 * Created by vvalitsky on 12/24/2019.
 */
({
    doInit: function (component, event, helper) {
        helper.getCities(component);
    },

    checkDate: function (component, event, helper) {
        let selectedCheckInDate = component.get('v.dateCheckIn');
        let selectedCheckOutDate = component.get('v.dateCheckOut');
        let today = new Date();
        let parseToday = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        const toastEvent = component.getEvent('toasterEvent');
        let visibility;
        if (!!selectedCheckOutDate) {
            if ((Date.parse(selectedCheckOutDate) <= Date.parse(selectedCheckInDate)) ||
                (Date.parse(selectedCheckInDate) < Date.parse(parseToday))) {
                component.set('v.isValidDate', false);
                visibility = true;
            } else {
                component.set('v.isValidDate', true);
                visibility = false;
            }
        } else {
            if (Date.parse(selectedCheckInDate) < Date.parse(parseToday)) {
                component.set('v.isValidDate', false);
                visibility = true;
            } else {
                component.set('v.isValidDate', true);
                visibility = false;
            }
        }
        toastEvent.setParams({
            'isVisibleToast': visibility,
            'sldsThemeType': $A.get("$Label.c.SLDS_Error"),
            'textStyle': $A.get("$Label.c.Error"),
            'message': $A.get("$Label.c.CheckDateMessage")
        });
        toastEvent.fire();
    },

    getFilteredRooms: function (component, event, helper) {
        let checkInField = component.get('v.dateCheckIn');
        let checkOutField = component.get('v.dateCheckOut');
        let countOfGuest = component.get('v.countOfGuest');
        let cityNameField = component.get('v.selectedCity');
        let hotelNameField = component.get('v.selectedHotel');

        if (!!checkInField & !!checkOutField & !!cityNameField & !!hotelNameField & !!countOfGuest &
            component.get('v.isValidDate') ) {
            let inputDataEvents = component.getEvent('inputDataEvent');
            inputDataEvents.setParams({
                'isVisibleTable': true,
                'dateIn': checkInField,
                'dateOut': checkOutField,
                'countGuests': countOfGuest,
                'selectedCity': cityNameField,
                'selectedHotel': hotelNameField
            });
            inputDataEvents.fire();
        } else {
            let toastEvent = component.getEvent('toasterEvent');
            toastEvent.setParams({
                'isVisibleToast': true,
                'sldsThemeType': $A.get("$Label.c.SLDS_Error"),
                'textStyle': $A.get("$Label.c.Error"),
                'message': $A.get("$Label.c.Warning_Message")
            });
            toastEvent.fire();
        }
    },

    getFilteredHotels: function (component, event, helper) {
        let selectedCity = event.getParam('value');
        component.set('v.selectedCity', selectedCity);
        helper.getHotels(component, selectedCity);
    },

    setFilteredHotels: function (component, event, helper) {
        let selectedHotel = event.getParam('value');
        component.set('v.selectedHotel', selectedHotel);
    },

})