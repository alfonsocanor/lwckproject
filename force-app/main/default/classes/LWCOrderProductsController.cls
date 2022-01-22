public with sharing class LWCOrderProductsController {

    @AuraEnabled
    public static List<LWCDatatableDataWrapper> getXLineItems(String parentObject, String parentId){
        List<LWCDatatableDataWrapper> currentXLineItems = new List<LWCDatatableDataWrapper>();

        String selectQuery = 'SELECT PricebookEntryId, Product2.Name, Product2Id, UnitPrice, Quantity, TotalPrice ';
        String fromQuery = 'FROM ' + Constants.PARENT_XLINEITEMCHILD.get(parentObject);
        String whereQuery = ' WHERE ' + parentObject + 'Id=\'' + parentId + '\'';   

        for(SObject xli: Database.query(selectQuery + fromQuery + whereQuery)){
            currentXLineItems.add(new LWCDatatableDataWrapper(
                (String)xli.get('PricebookEntryId'),
                (String)xli.get('Product2Id'),
                (String)xli.get('Product2.Name'),
                (Decimal)xli.get('UnitPrice'),
                (Decimal)xli.get('Quantity'),
                (Decimal)xli.get('TotalPrice')   
            ));
        }

        return currentXLineItems;
    }

    @AuraEnabled
    public static void increaseXLineItemQuantity(){}

    @AuraEnabled
    public static void decreateXLineItemQuantity(){}

    public class LWCDatatableDataWrapper{
        @AuraEnabled public String pricebookEntryId;
        @AuraEnabled public String productId;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal unitPrice;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal totalPrice;
        public LWCDatatableDataWrapper( String pricebookEntryId, String productName, String productId, Decimal UnitPrice, Decimal Quantity, Decimal TotalPrice){
            this.pricebookEntryId = pricebookEntryId;
            this.productId = productId;
            this.productName = productName;
            this.unitPrice = UnitPrice;
            this.quantity = Quantity;
            this.totalPrice = TotalPrice;
            
        }
    }
}