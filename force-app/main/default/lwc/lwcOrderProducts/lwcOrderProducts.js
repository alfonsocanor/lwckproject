import { LightningElement, api, track, wire } from 'lwc';
import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import updateXLineItems from '@salesforce/messageChannel/UpdateXLineItems__c';

const columns = [
    { label: 'Product', type: 'String', fieldName: 'productName', sortable:true},
    { label: 'Unit Price', type: 'currency', fieldName: 'unitPrice', sortable:true},
    { label: 'Quantity', type: 'number', fieldName: 'quantity', sortable:true},
    { label: 'Total Price', type: 'currency', fieldName: 'TotalPrice', sortable:true}
];

export default class LwcOrderProducts extends LightningElement {
    @api recordId;
    @api parentName;
    @track data = [];
    columns = columns;


    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}