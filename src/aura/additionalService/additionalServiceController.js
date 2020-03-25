/**
 * Created by vvalitsky on 12/26/2019.
 */
({
    handleChange: function (component, event, helper) {
        const totalPriceEvent = component.getEvent('totalPriceEvent');
        const total = event.getParam('value')
            .map(value => {
                const price = parseFloat(value.split('-')[0]);
                return price;
            })
            .reduce((total, current) => total + current, 0);
        totalPriceEvent.setParams({ 'totalPriceWithService': total });
        totalPriceEvent.fire();
    },
})