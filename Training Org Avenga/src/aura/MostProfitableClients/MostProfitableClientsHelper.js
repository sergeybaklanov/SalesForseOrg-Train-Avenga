({
    loadTopClients: function (component, event, helper) {
        let action = component.get("c.getMostProfitableClients");
        action.setParams({
            "limitClients": component.get("v.limitNumber")
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state == 'SUCCESS') {
                component.set('v.data',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    setColumns:function (component) {
        component.set('v.columns',[
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Email', fieldName: 'Email__c', type: 'text'},
            {label: 'Total Active Projects', fieldName: 'Total_Active_Projects__c', type: 'text'},
            {label: 'Budget', fieldName: 'Budget__c', type: 'currency'}
        ])
    }
});