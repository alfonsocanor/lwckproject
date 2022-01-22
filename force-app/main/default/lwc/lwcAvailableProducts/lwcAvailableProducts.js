import { LightningElement, api, track, wire } from 'lwc';
import getAllPricebooks from '@salesforce/apex/LWCAvailableProductsController.getAllPricebooks';
import getAvailableProducts from '@salesforce/apex/LWCAvailableProductsController.getAvailableProducts';
import addProductLineItems from '@salesforce/apex/LWCAvailableProductsController.addProductLineItems';
import setPricebookOnParent from '@salesforce/apex/LWCAvailableProductsController.setPricebookOnParent';

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
    { label: 'Price List', type: 'currency', fieldName: 'unitPrice', sortable:true,
        cellAttributes: { class: 'slds-text-align_right'}
    },
    { label: '', name: 'add', type: 'button', 
        typeAttributes: { label: 'Add'},
        cellAttributes: { class: 'slds-align_absolute-center'}
    }
];

export default class LwcAvailableProducts extends LightningElement {
    @api recordId;
    @api parentName;
    @track data = [];
    columns = columns;
    renderDatatable = false;

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
        let pricebookId = event.target.value;
        this.getAvailableProductsFromApex(pricebookId);
        this.setPricebookOnParentFromApex(pricebookId);
    }

    getAvailableProductsFromApex(pricebookId){
        getAvailableProducts({pricebookId})
        .then(data => {
            this.data = data;
            this.renderDatatable = true;
        })
        .catch(error => {
            console.log('error', error);
        })
    }

    handleRowAction(event){
        this.addProductLineItemsFromApex(event.detail.row.pricebookEntryId);
    }

    setPricebookOnParentFromApex(pricebookId){
        setPricebookOnParent(
            {
                recordId: this.recordId,
                parentName: this.parentName,
                pricebookId
            }
        )
        .then(() => {
            //NoActions2Take - Pricebook saved
        })
    }

    addProductLineItemsFromApex(pricebookEntryId){
        addProductLineItems({
            parentName: this.parentName,
            parentId: this.recordId,
            pricebookEntryId
        })
        .then(() => {
            console.log('sendEventToTheOtherComponent');
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