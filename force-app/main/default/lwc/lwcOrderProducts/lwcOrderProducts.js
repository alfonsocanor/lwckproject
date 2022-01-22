import { LightningElement, api, track, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import getXLineItems from '@salesforce/apex/LWCOrderProductsController.getXLineItems';
import handleXLineItemUpdate from '@salesforce/apex/LWCOrderProductsController.handleXLineItemUpdate';

import {
    APPLICATION_SCOPE,
    MessageContext,
    subscribe,
    unsubscribe,
    publish
} from 'lightning/messageService';

import updateXLineItems from '@salesforce/messageChannel/UpdateXLineItems__c';
import updatePricebookOptions from '@salesforce/messageChannel/UpdatePricebookOptions__c';

const columns = [
    { label: 'Product', type: 'String', fieldName: 'productName', sortable:true},
    { label: 'Unit Price', type: 'currency', fieldName: 'unitPrice', sortable:true,
        cellAttributes: { class: 'slds-text-align_right'}
    },
    { label: 'Quantity', type: 'number', fieldName: 'quantity',
        cellAttributes: { alignment: 'center'}
    },
    { label: 'Total Price', type: 'currency', fieldName: 'totalPrice', sortable:true,
        cellAttributes: { class: 'slds-text-align_right'}
    },
    { label: '', name: 'delete', type: 'button', 
        typeAttributes: { label: 'Delete'},
        cellAttributes: { class: 'slds-align_absolute-center'}
    }
];

export default class LwcOrderProducts extends LightningElement {
    @api recordId;
    @api parentName;
    @track data = [];
    columns = columns;
    isLoading = false;

    updateFromXliDelete = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.subscribeToMessageChannel();
        this.getXLineItemsFromApex();
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    getXLineItemsFromApex(){
        getXLineItems({
            parentName : this.parentName,
            parentId: this.recordId
        })
        .then(data => {
            this.isLoading = false;
            this.data = data;

            if(this.updateFromXliDelete && this.data.length === 0){
                publish(this.messageContext, updatePricebookOptions, { message: 'update pricebook options...' });
            }

            this.updateFromXliDelete = false;
        })
        .catch(error => {
            console.log('error:', error);
        })

    }

    handleRowAction(event){
        this.isLoading = true;
        this.handleXLineItemUpdateFromApex(event.detail.row.xliId);
    }

    handleXLineItemUpdateFromApex(xliId){
        handleXLineItemUpdate({
            parentName: this.parentName,
            xliId
        })
        .then(() => {
            this.updateFromXliDelete = true;
            this.getXLineItemsFromApex();
        })
    }

    refreshTableAndPage(){
        this.getXLineItemsFromApex(); 
        updateRecord({ fields: { Id: this.recordId } });       
    }

    subscribeToMessageChannel(){
        if(!this.subscription){
            this.subscription = subscribe(
                this.messageContext,
                updateXLineItems,
                (message) => this.handleMessageFromLightningMessageService(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
    handleMessageFromLightningMessageService(message){
        this.isLoading = true;
        this.updateCauseByLightningMessageService = true;
        this.refreshTableAndPage();
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