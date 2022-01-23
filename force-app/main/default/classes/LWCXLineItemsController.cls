public with sharing class LWCXLineItemsController {

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

        if(!Test.isRunningTest()) callExternalAfterActivation(parentName, parentId);
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
    
    @future(callout=true)
    public static void callExternalAfterActivation(String parentName, String parentId){
        ExternalServiceActivationWrapper body = prepareBody(parentName, parentId);
        postCalloutMethod(Settings_K_Project__c.getValues('ExternalEndPoint').Value__c.toLowerCase(), JSON.serialize(body));
    }

    public static void postCalloutMethod(String endpoint, String body){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setBody(body);
        request.setMethod('POST');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {} else {} //If you want to handle response implement logic here
    }

    public static ExternalServiceActivationWrapper prepareBody(String parentName, String parentId){
        List<OrderProductWrapper> orderProducts = new List<OrderProductWrapper>();
        
        String subQueryObject = Constants.PARENT_XLINEITEMCHILD.get(parentName) + 's';

        String selectQuery = 'SELECT AccountId, OrderNumber, Type, Status ';
        String selectSubQuery = ', (SELECT Product2.Name, Product2.ProductCode, UnitPrice, Quantity FROM ' + subQueryObject + ') ';
        String fromQuery = 'FROM ' + parentName;
        String whereQuery = ' WHERE Id=\'' + parentId + '\'';
        SObject parentAndLineItems = Database.query(selectQuery + selectSubQuery + fromQuery + whereQuery);

        for(SObject xli: parentAndLineItems.getSObjects(subQueryObject)){
            orderProducts.add(
                new OrderProductWrapper(
                    (String)xli.getSObject('Product2').get('Name'),
                    (String)xli.getSObject('Product2').get('ProductCode'),
                    (Decimal)xli.get('UnitPrice'),
                    (Decimal)xli.get('Quantity')
                )
            );
        }

        return new ExternalServiceActivationWrapper(
            (String)parentAndLineItems.get('AccountId'),
            (String)parentAndLineItems.get('OrderNumber'),
            (String)parentAndLineItems.get('Type'),
            (String)parentAndLineItems.get('Status'),
            orderProducts
        );
    }

    public class ExternalServiceActivationWrapper{
        public String accountNumber;
        public String orderNumber;
        public String type;
        public String status;
        public List<OrderProductWrapper> orderProducts;
        public ExternalServiceActivationWrapper(String accountNumber, string orderNumber, String type, String status, List<OrderProductWrapper> orderProducts){
            this.accountNumber = accountNumber;
            this.orderNumber = orderNumber;
            this.type = type;
            this.status = status;
            this.orderProducts = orderProducts;
        }
    }

    public class OrderProductWrapper{
        public String name;
        public String code;
        public Decimal unitPrice;
        public Integer quantity;
        public OrderProductWrapper(String name, String code, Decimal unitPrice, Decimal quantity){
            this.name = name;
            this.code = code;
            this.unitPrice = unitPrice;
            this.quantity = (Integer)quantity;
        }
    }
}
