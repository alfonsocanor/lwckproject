import { LightningElement, api, track, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import getXLineItems from '@salesforce/apex/LWCOrderProductsController.getXLineItems';
import handleXLineItemUpdate from '@salesforce/apex/LWCOrderProductsController.handleXLineItemUpdate';

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

    connectedCallback(){
        this.getXLineItemsFromApex();
    }

    getXLineItemsFromApex(){
        getXLineItems(
            {
                parentName : this.parentName,
                parentId: this.recordId
            }
        )
        .then(data => {
            this.data = data;
        })
        .catch(error => {
            console.log('error:', error);
        })

    }

    handleRowAction(event){
        this.handleXLineItemUpdateFromApex(event.detail.row.xliId);
    }

    handleXLineItemUpdateFromApex(xliId){
        handleXLineItemUpdate(
            {
                parentName: this.parentName,
                xliId
            }
        )
        .then(() => {
            console.log('xliId deleted REFRESH!');
            this. data = [];
            this.getXLineItemsFromApex();
        })
    }

    refreshTableAndPage(){
        this.getXLineItemsFromApex(); 
        updateRecord({ fields: { Id: this.recordId } });       
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