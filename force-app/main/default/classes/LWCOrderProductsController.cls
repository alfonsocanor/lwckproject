public with sharing class LWCOrderProductsController {

    @AuraEnabled
    public List<SObject> retrieveAllTheCurrentLineItems(String parentId){
        String selectQuery = 'SELECT Id, PricebookEntryId, Quantity' ;
        String fromQuery = 'FROM ' + parentObject;
        String whereQuery = ' WHERE parentObject' + '=\'' + parentId + '\'';
            
    }
}
