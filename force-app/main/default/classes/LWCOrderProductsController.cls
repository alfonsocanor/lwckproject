public with sharing class LWCOrderProductsController {

    @AuraEnabled
    public static List<LWCDatatableDataWrapper> getXLineItems(String parentObject, String parentId){
        List<LWCDatatableDataWrapper> currentXLineItems = new List<LWCDatatableDataWrapper>();

        String selectQuery = 'SELECT Id, Product2.Name, Product2Id, UnitPrice, Quantity, TotalPrice ';
        String fromQuery = 'FROM ' + Constants.PARENT_XLINEITEMCHILD.get(parentObject);
        String whereQuery = ' WHERE ' + parentObject + 'Id=\'' + parentId + '\'';   

        for(SObject xli: Database.query(selectQuery + fromQuery + whereQuery)){
            currentXLineItems.add(new LWCDatatableDataWrapper(
                (String)xli.get('Id'),
                (String)xli.get('Product2Id'),
                (String)xli.getSObject('Product2').get('Name'),
                (Decimal)xli.get('UnitPrice'),
                (Decimal)xli.get('Quantity'),
                (Decimal)xli.get('TotalPrice')   
            ));
        }

        return currentXLineItems;
    }

    @AuraEnabled
    public static void handleXLineItemUpdate(String parentObject, String xliId){
        String selectQuery = 'SELECT Id, Quantity ';
        String fromQuery = 'FROM ' + Constants.PARENT_XLINEITEMCHILD.get(parentObject);
        String whereQuery = ' WHERE Id=\'' + xliId + '\'';  

        SObject xLineItem = Database.query(selectQuery + fromQuery + whereQuery);

        if((Decimal)xLineItem.get('Quantity') == 1){
            delete xLineItem;
            return;
        } 

        decreaseXLineItemQuantity(xLineItem);

        update xLineItem;
    }

    public static void decreaseXLineItemQuantity(SObject xLineItem){
        Decimal currentQuantity = (Decimal)xLineItem.get('Quantity');
        currentQuantity--;
        xLineItem.put('Quantity', currentQuantity);
    }
    

    public class LWCDatatableDataWrapper{
        @AuraEnabled public String xliId;
        @AuraEnabled public String productId;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal unitPrice;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal totalPrice;
        public LWCDatatableDataWrapper( String xliId, String productName, String productId, Decimal UnitPrice, Decimal Quantity, Decimal TotalPrice){
            this.xliId = xliId;
            this.productId = productId;
            this.productName = productName;
            this.unitPrice = UnitPrice;
            this.quantity = Quantity;
            this.totalPrice = TotalPrice;
            
        }
    }
}