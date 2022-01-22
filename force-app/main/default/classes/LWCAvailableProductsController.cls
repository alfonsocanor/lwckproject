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

        String selectQuery = 'SELECT Id, PricebookEntryId, Quantity ';
        String fromQuery = 'FROM ' + Constants.PARENT_XLINEITEMCHILD.get(parentObject);
        String whereQuery = ' WHERE ' + parentObject + 'Id=\'' + parentId + '\'';

        for(SObject xli: Database.query(selectQuery + fromQuery + whereQuery)){
            pricebookEntryPerXLineItemMap.put((String)xli.get('PricebookEntryId'), (SObject)xli);
        }

        SObject cuXLineItem = Schema.getGlobalDescribe().get(Constants.PARENT_XLINEITEMCHILD.get(parentObject)).newSObject();
        if(pricebookEntryPerXLineItemMap.containsKey(pricebookEntryId)){
            cuXLineItem = pricebookEntryPerXLineItemMap.get(pricebookEntryId);
            updateXLineItem('increaseQuantity', cuXLineItem);
        } else {
            createXLineItem(cuXLineItem, pricebookEntryId, parentObject, parentId);
        }

        KProjectDebugging.printDebug('upsertXLineItem', cuXLineItem);

        upsert cuXLineItem;
    }

    public static void updateXLineItem(String action, SObject xLineItem){
        if(action == 'increaseQuantity'){
            increaseXLineItemQuantity(xLineItem);
        }
    }

    public static void createXLineItem(SObject xLineItem, String pricebookEntryId, String parentObject, String parentId){
        PricebookEntry pbeInfo = [
            SELECT Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Id = :pricebookEntryId
        ];
        xLineItem.put('PricebookEntryId', pbeInfo.Id);
        xLineItem.put('Product2Id', pbeInfo.Product2Id);
        xLineItem.put('UnitPrice', pbeInfo.UnitPrice);
        xLineItem.put(parentObject + 'Id', parentId); //Ex: Order + Id = OrderId
        xLineItem.put('Quantity', 1);
    }

    public static void increaseXLineItemQuantity(SObject xLineItem){
        Decimal currentQuantity = (Decimal)xLineItem.get('Quantity');
        currentQuantity++;
        xLineItem.put('Quantity', currentQuantity);
    }
}
