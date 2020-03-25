/**
 * Created by vvalitsky on 12/24/2019.
 */
({
     hideSpinner: function (component, event, helper) {
         component.set("v.isBusy", false);
     },

     showSpinner: function (component, event, helper) {
         component.set("v.isBusy", true);
     },

    handleInputFormEvent: function (component, event, helper) {
        component.set('v.isVisibleTable', event.getParam('isVisibleTable'));
        component.set('v.inputData', {
            checkInDate: event.getParam('dateIn'),
            checkOutDate: event.getParam('dateOut'),
            countOfGuest: event.getParam('countGuests'),
            cityName: event.getParam('selectedCity'),
            hotelId: event.getParam('selectedHotel')
        });
        helper.getRooms(component, {
            checkInDate: event.getParam('dateIn'),
            checkOutDate: event.getParam('dateOut'),
            countOfGuest: event.getParam('countGuests'),
            cityName: event.getParam('selectedCity'),
            hotelId: event.getParam('selectedHotel')
        });
    },

    handleToastEvent: function (component, event, helper) {
        let toastComponent = component.find('toast');
        toastComponent.showToast( event.getParam('isVisibleToast'), event.getParam('sldsThemeType'),
        event.getParam('textStyle'), event.getParam('message')
        );
    },

    showPriceForm: function (component, event, helper) {
        const room = event.getParam('selectedRows')[0];
        if (room) {
            if (room.isHaveAddService) {
                helper.getAdditionalServices(component, room.roomId);
            }
            component.set('v.selectedRoom', room);
        }
    },

    handleTotalPriceEvent: function (component, event, helper) {
        component.set('v.totalPriceWithServices', event.getParam('totalPriceWithService'));
    },

    handleContactFormEvent: function (component, event, helper) {
        helper.bookRoom(component, event, helper);
    },

})