/**
 * Created by vvalitsky on 11/28/2019.
 */
({
    getToast: function (component, event, helper) {
        var params = event.getParam('arguments');
        component.set('v.isVisible', params.isVisibleToast);
        component.set('v.sldsThemeType', params.sldsThemeTypeToast);
        component.set('v.textStyle', params.textStyleToast);
        component.set('v.message', params.messageToast);
        window.setTimeout(
            $A.getCallback(function() {
                component.set('v.isVisible', false);
            }), 5000
        );
    },
})