/**
 * Created by vvalitsky on 12/18/2019.
 */
({
    registerRoomAndContact: function (component, event, helper) {
        const toastEvent = component.getEvent('toasterEvent');
        let firstName = component.get('v.firstName');
        let lastName = component.get('v.lastName');
        let email = component.get('v.contactEmail');
        let phone = component.get('v.phone');
        var isValidFields = component.find('first_name').get('v.validity').valid &&
            component.find('last_name').get('v.validity').valid &&
            component.find('contact_email').get('v.validity').valid &&
            component.find('contact_phone').get('v.validity').valid;
        if (isValidFields) {
            let contactFormEvent = component.getEvent('contactFormHandlerEvent');
            contactFormEvent.setParams({
                'fistName': firstName,
                'lastName': lastName,
                'email': email,
                'phone': phone
            });
            contactFormEvent.fire();
        } else {
            toastEvent.setParams({
                'isVisibleToast': true,
                'sldsThemeType': $A.get("$Label.c.SLDS_Error"),
                'textStyle': $A.get("$Label.c.Error"),
                'message': $A.get("$Label.c.Warning_Message")
            });
        }
        toastEvent.fire();
    },
})