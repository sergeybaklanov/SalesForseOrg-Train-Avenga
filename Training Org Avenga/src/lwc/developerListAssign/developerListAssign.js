/**
 * Created by User on 25.10.2022.
 */

import {LightningElement, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getProjectsAssignments from '@salesforce/apex/DeveloperListAssignController.getProjectsAssignments';
import makeSync from '@salesforce/apex/DeveloperListAssignController.makeSync'

const columns = [
    {label: 'Project Assignment Name', fieldName: 'Name'},
    {label: 'Project Name', fieldName: 'prName', type: 'text'},
    {label: 'CreatedDate', fieldName: 'CreatedDate', type: 'date'},
    {label: 'Billable?', fieldName: 'prBillable', type: 'text'},
    {label: 'Active?', fieldName: 'prActive', type: 'text'}
];


export default class DeveloperListAssign extends LightningElement {
    @api recordId;

    data = [];
    columns = columns;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getProjectsAssignments({recordId: this.recordId})
            .then(result => {
                result.forEach(el => {
                    el.prName = el.Project__r.Name;
                    el.prBillable = el.Project__r.Is_Billable__c;
                    el.prActive = el.Project__r.Active__c;
                });
                this.data = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleRefresh(event) {
        makeSync({recordId: this.recordId})
            .then(result => {
                console.log(result);
                this.showMessage('Refresh', 'Record successfully updated', 'Success');
                // eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(error => {
                this.showMessage('Refresh', 'Record is not updated: '+error.status+' '+error.statusText, 'Error');
                console.error(error);
                this.error = error;
            });
    }

    showMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}