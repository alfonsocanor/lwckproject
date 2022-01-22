import { LightningElement, track, wire } from 'lwc';

import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/UpdateXLineItems__c';

export default class LwcAvailableProducts extends LightningElement {}