public with sharing class LWCAvailableProductsController {

    @AuraEnabled
    public static List<PricebookEntry> getAvailableProducts(String pricebookId){
        return [
            SELECT Id, Product2.Name, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId AND IsActive = true
        ];
    }

    @AuraEnabled
    public static void addProductLineItems(String parentObject, String parentId, String pricebookEntryId){
        List<OrderItem> orderItem2Insert = new List<OrderItem>();
        List<OrderItem> orderItem2Update = new List<OrderItem>();
        Map<String, SObject> pricebookEntryPerXLineItemMap = new Map<String, SObject>();

        String selectQuery = 'SELECT Id, PricebookEntryId, Quantity' ;
        String fromQuery = 'FROM ' + parentObject;
        String whereQuery = ' WHERE parentObject' + '=\'' + parentId + '\'';

        for(SObject xli: Database.query(selectQuery + fromQuery + whereQuery)){
            pricebookEntryPerXLineItemMap.put((String)xli.get('PricebookEntryId'), (SObject)xli);
        }

        SObject upsertXLineItem = Schema.getGlobalDescribe().get(parentId).newSObject();
        if(pricebookEntryPerXLineItemMap.containsKey(pricebookEntryId)){
            upsertXLineItem = pricebookEntryPerXLineItemMap.get(pricebookEntryId);
            Decimal currentQuantity = (Decimal)upsertXLineItem.get('Quantity');
            upsertXLineItem.put('Quantity', currentQuantity++);
        } else {
            PricebookEntry pbeInfo = [
                SELECT Id, Product2Id, UnitPrice
                FROM PricebookEntry
                WHERE Id = :pricebookEntryId
            ];
            upsertXLineItem.put('PricebookEntryId', pbeInfo.Id);
            upsertXLineItem.put('Product2Id', pbeInfo.Product2Id);
            upsertXLineItem.put('UnitPrice', pbeInfo.UnitPrice);
            upsertXLineItem.put('Quantity', 1);
        }

        upsert upsertXLineItem;
    }
}
