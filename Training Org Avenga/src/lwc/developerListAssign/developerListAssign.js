/**
 * Created by User on 25.10.2022.
 */

import {LightningElement, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getProjectsAssignments from '@salesforce/apex/DeveloperListAssignController.getProjectsAssignments';

const columns = [
    {label: 'Project Assignment Name', fieldName: 'Name'},
    {label: 'CreatedDate', fieldName: 'CreatedDate', type: 'date'},
    {label: 'Project Name', fieldName: 'prName', type: 'text'}
];


export default class DeveloperListAssign extends LightningElement {
    @api recordId;

    data = [];
    columns = columns;

    handleRefresh(event) {
        this.showMessage('Refresh', 'Refresh is not yet configure', 'Success');
        this.loadData();

    }

    showMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getProjectsAssignments({recordId: this.recordId})
            .then(result => {
                console.log(result);
                result.forEach(el => {
                    el.prName = el.Project__r.Name
                });
                console.log(result);
                this.data = result;
            })
            .catch(error => {
                this.error = error;
            });
    }
}