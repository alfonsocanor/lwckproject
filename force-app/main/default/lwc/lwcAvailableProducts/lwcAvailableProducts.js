import { LightningElement, api, track, wire } from 'lwc';
import prepareComponentBasedOnPricebook from '@salesforce/apex/LWCAvailableProductsController.prepareComponentBasedOnPricebook';
import getAvailableProducts from '@salesforce/apex/LWCAvailableProductsController.getAvailableProducts';
import addProductLineItems from '@salesforce/apex/LWCAvailableProductsController.addProductLineItems';
import setPricebookOnParent from '@salesforce/apex/LWCAvailableProductsController.setPricebookOnParent';
import getAllPricebooks from '@salesforce/apex/LWCAvailableProductsController.getAllPricebooks';

import {
    APPLICATION_SCOPE,
    MessageContext,
    subscribe,
    unsubscribe,
    publish,
} from 'lightning/messageService';
import updateXLineItems from '@salesforce/messageChannel/UpdateXLineItems__c';
import updatePricebookOptions from '@salesforce/messageChannel/UpdatePricebookOptions__c';


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
    isLoading = true;

    sortDirection = 'asc';
    sortedBy;

    xIsActive = false;

    @track options;
    value = '';
    readOnlyPricebook = false;
    
    xIsActive = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.subscribeToMessageChannel();
        this.prepareComponentBasedOnPricebookFromApex();
    }

    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    prepareComponentBasedOnPricebookFromApex(){
        prepareComponentBasedOnPricebook({
                parentName: this.parentName,
                parentId: this.recordId})
        .then(response => {
            if(response.xIsActive){
                this.xIsActive = true;
                return;
            }

            if(response.canChange){
                this.options = response.pricebooks;
                this.isLoading = false;
            } else {
                this.readOnlyPricebook = true;
                this.options = response.pricebooks;
                this.value = response.pricebooks[0].value;
                this.getAvailableProductsFromApex(response.pricebooks[0].value);
            }
            
        })
        .catch(error => {
            console.log('error', error);
        })
    }

    handleComboboxPricebook(event){
        this.isLoading = true;
        let pricebookId = event.target.value;
        this.getAvailableProductsFromApex(pricebookId);
        this.setPricebookOnParentFromApex(pricebookId);
    }

    getAvailableProductsFromApex(pricebookId){
        getAvailableProducts({pricebookId})
        .then(data => {
            this.data = data;
            this.isLoading = false;
            this.renderDatatable = true;
        })
        .catch(error => {
            console.log('error', error);
        })
    }

    handleRowAction(event){
        this.isLoading = true;
        this.addProductLineItemsFromApex(event.detail.row.pricebookEntryId);
    }

    setPricebookOnParentFromApex(pricebookId){
        setPricebookOnParent({
            recordId: this.recordId,
            parentName: this.parentName,
            pricebookId
        })
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
            this.isLoading = false;
            this.readOnlyPricebook = true;
            publish(this.messageContext, updateXLineItems, { message: 'update table...' });
        })
        .catch(error => {
            console.log('error', error);
        })
    }

    subscribeToMessageChannel(){
        if(!this.subscription){
            this.subscription = subscribe(
                this.messageContext,
                updatePricebookOptions,
                (message) => this.handleMessageFromLightningMessageService(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    getAllPricebooksFromApex(){
        getAllPricebooks({})
        .then(pricebooks => {
            this.options = pricebooks;
        })
    }
    
    handleMessageFromLightningMessageService(message){
        if(message.message.xIsActive){
            this.xIsActive = true;
        }

        if(message.message.updatePricebook){
            this.isLoading = true;
            this.readOnlyPricebook = false;
            this.getAllPricebooksFromApex();
            setTimeout(function(){
                this.isLoading = false;
            }.bind(this),1000);
        }
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