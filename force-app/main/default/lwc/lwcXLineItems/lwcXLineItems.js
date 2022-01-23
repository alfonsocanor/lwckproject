import { LightningElement, api, track, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import getXLineItems from '@salesforce/apex/LWCXLineItemsController.getXLineItems';
import handleXLineItemUpdate from '@salesforce/apex/LWCXLineItemsController.handleXLineItemUpdate';
import isStatusActivated from '@salesforce/apex/LWCXLineItemsController.isStatusActivated';
import activateParentObject from '@salesforce/apex/LWCXLineItemsController.activateParentObject';

import {
    APPLICATION_SCOPE,
    MessageContext,
    subscribe,
    unsubscribe,
    publish
} from 'lightning/messageService';

import updateXLineItems from '@salesforce/messageChannel/updateXLineItems__c';
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

export default class LwcXLineItems extends LightningElement {
    @api recordId;
    @api parentName;
    @track data = [];
    columns = columns;
    isLoading = false;

    updateFromXliDelete = false;
    disableActivationButton = true;
    xIsActive = true;

    renderDatatable = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.isStatusActivatedFromApex();
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
            this.renderDatatable = true;
            this.data = data;
            this.disableActivationButton = this.data.length === 0 ? true : false;
            if(this.updateFromXliDelete && this.data.length === 0){
                this.publishLightningMessageService({updatePricebook: true});
            }

            this.updateFromXliDelete = false;
        })
        .catch(error => {
            console.log('error:', error);
        })

    }

    publishLightningMessageService(message){
        publish(this.messageContext, updatePricebookOptions, { message });
    }

    isStatusActivatedFromApex(){
        isStatusActivated({
            parentName: this.parentName,
            parentId: this.recordId
        })
        .then(isActive => {
            this.xIsActive = isActive;
            if(!isActive){
                this.subscribeToMessageChannel();
            } else {
                this.columns.pop();
            }
            
            this.getXLineItemsFromApex();
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

    handleXActivation(){
        this.isLoading = true;
        this.activateParentObjectFromApex();
    }

    activateParentObjectFromApex(){
        activateParentObject({
            parentId: this.recordId,
            parentName: this.parentName
        })
        .then(() => {
            this.xIsActive = true;
            this.isLoading = true;
            this.renderDatatable = false;
            this.columns.pop();
            this.refreshTableAndPage();
            this.publishLightningMessageService({ xIsActive: true })
        })
        .catch(error => {
            console.log('error',error);
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