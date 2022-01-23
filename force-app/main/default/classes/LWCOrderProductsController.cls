public with sharing class LWCOrderProductsController {

    @AuraEnabled
    public static Boolean isStatusActivated(String parentName, String parentId){
        String selectQuery = 'SELECT Status ';
        String fromQuery = 'FROM ' + parentName;
        String whereQuery = ' WHERE Id=\'' + parentId + '\'';
        SObject parentObject = Database.query(selectQuery + fromQuery + whereQuery);

        return parentObject.get('Status') == 'Activated' ? true : false;
    }

    @AuraEnabled
    public static void activateParentObject(String parentName, String parentId){
        SObject parentObject = Schema.getGlobalDescribe().get(parentName).newSObject();

        parentObject.put('Id', parentId);
        parentObject.put('Status', 'Activated');

        KProjectDebugging.printDebug('parentObject', parentObject);
        update parentObject;
    }

    @AuraEnabled
    public static List<LWCDatatableDataWrapper> getXLineItems(String parentName, String parentId){
        List<LWCDatatableDataWrapper> currentXLineItems = new List<LWCDatatableDataWrapper>();

        String selectQuery = 'SELECT Id, Product2.Name, Product2Id,PricebookEntry.Pricebook2Id, PricebookEntry.Pricebook2.Name ,UnitPrice, Quantity, TotalPrice ';
        String fromQuery = 'FROM ' + Constants.PARENT_XLINEITEMCHILD.get(parentName);
        String whereQuery = ' WHERE ' + parentName + 'Id=\'' + parentId + '\'';   

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

        KProjectDebugging.printDebug('currentXLineItems', currentXLineItems);

        return currentXLineItems;
    }

    @AuraEnabled
    public static void handleXLineItemUpdate(String parentName, String xliId){
        String selectQuery = 'SELECT Id, Quantity ';
        String fromQuery = 'FROM ' + Constants.PARENT_XLINEITEMCHILD.get(parentName);
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
        public LWCDatatableDataWrapper(String xliId, String productId, String productName, Decimal UnitPrice, Decimal Quantity, Decimal TotalPrice){
            this.xliId = xliId;
            this.productId = productId;
            this.productName = productName;
            this.unitPrice = UnitPrice;
            this.quantity = Quantity;
            this.totalPrice = TotalPrice;
        }
    }
}