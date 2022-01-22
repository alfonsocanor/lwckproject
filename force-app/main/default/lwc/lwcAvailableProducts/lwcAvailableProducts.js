import { LightningElement, api, track, wire } from 'lwc';
import getAllPricebooks from '@salesforce/apex/LWCAvailableProductsController.getAllPricebooks';
import getAvailableProducts from '@salesforce/apex/LWCAvailableProductsController.getAvailableProducts';

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
    { label: 'Price List', type: 'currency', fieldName: 'unitPrice', sortable:true},
    { label: '', type: 'button', typeAttributes: { label: 'Add',}}
];

export default class LwcAvailableProducts extends LightningElement {
    @api recordId;
    @api parentName;
    @track data = [];
    columns = columns;

    sortDirection = 'asc';
    sortedBy;

    @track options;
    value = '';

    connectedCallback(){
        console.log('cC ' + this.recordId);
        console.log('this.parentName  ' + this.parentName);
        this.getAllPricebooksFromApex();
    }

    getAllPricebooksFromApex(){
        getAllPricebooks()
        .then(pricebooks => {
            this.options = pricebooks;
        })
        .catch(error => {
            console.log('error', error);
        })
    }

    handleComboboxPricebook(event){
        this.getAvailableProductsFromApex(event.target.value);
    }

    getAvailableProductsFromApex(pricebookId){
        getAvailableProducts({pricebookId})
        .then(data => {
            this.data = data;
        })
        .catch(error => {
            console.log('error', error);
        })
    }

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