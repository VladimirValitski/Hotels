/**
 * Created by vvalitsky on 12/24/2019.
 */
({
    getRooms: function (component, roomDataParam) {
            component.set('v.columns', [
                { label: $A.get("$Label.c.Rooms"), fieldName: 'roomName', type: 'text' },
                { label: $A.get("$Label.c.MaxGuests"), fieldName: 'countOfGuest', type: 'number' },
                { label: $A.get("$Label.c.Services"), fieldName: 'isHaveAddService', type: 'boolean' },
                { label: $A.get("$Label.c.Price"), fieldName: 'roomPrice', type: 'number' }
            ]);
            let action = component.get('c.getAvailableRooms');
            action.setParams({
                'roomData': JSON.stringify(roomDataParam)
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue().length > 0){
                        component.set('v.filteredRooms', response.getReturnValue());
                    } else {
                        let toastComponent = component.find('toast');
                        toastComponent.showToast(true, $A.get("$Label.c.SLDS_Error"), $A.get("$Label.c.Error"),
                        $A.get("$Label.c.EmptyRoomMessage"));
                    }
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    console.error(errors);
                }
            });
            $A.enqueueAction(action);
    },

    getAdditionalServices: function (component, selectedRoomIdParam) {
        let action = component.get('c.getAdditionalServicesOptions');
        action.setParams({ 'selectedRoomId': selectedRoomIdParam });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let allOptions = response.getReturnValue();
                let anOption;
                let newValues = [];
                for (var i in allOptions) {
                    anOption = allOptions[i];
                    let obj = JSON.parse(anOption);
                    newValues.push(obj);
                }
                const generateUID = () => Math.random().toString(16);
                const mappedOptions = newValues.map(v => {
                    v.label = `${v.label} (${v.value} $)`;
                    v.value = `${v.value}-(${generateUID()})`;
                    return v;
                });
                component.set('v.options', mappedOptions);
            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    bookRoom: function (component, event) {
        const action = component.get('c.registerRoom');
        const reservationData = component.get('v.inputData');
        action.setParams({ 'reservationData': JSON.stringify({
            checkInDate: reservationData.checkInDate,
            checkOutDate: reservationData.checkOutDate,
            firstName: event.getParam('fistName'),
            lastName: event.getParam('lastName'),
            contactEmail: event.getParam('email'),
            phone: event.getParam('phone'),
            roomId: component.get('v.selectedRoom').roomId,
            totalPrice:  component.get('v.totalPriceWithServices') + component.get('v.selectedRoom').roomPrice
            })
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let toastComponent = component.find('toast');
                toastComponent.showToast(true, $A.get("$Label.c.SLDS_Success"), $A.get("$Label.c.Success"),
                $A.get("$Label.c.SuccessMessage"));
                component.set('v.isVisibleResultStatus', true);
                component.set('v.resultRegisterStatus', response.getReturnValue());
            } else if (state === "ERROR") {
                let toastComponentForMessage = component.find('toast');
                toastComponentForMessage.showToast(true, $A.get("$Label.c.SLDS_Error"), $A.get("$Label.c.Error"),
                $A.get("$Label.c.UnSuccessMessage"));
                component.set('v.isVisibleResultStatus', true);
                component.set('v.resultRegisterStatus', $A.get("$Label.c.UnSuccessMessage"));
                let errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },

})