public with sharing class LWCAvailableProductsController {

    @AuraEnabled
    public static PricebookResponseWrapper prepareComponentBasedOnPricebook(String parentName, String parentId){
        String subQueryObject = Constants.PARENT_XLINEITEMCHILD.get(parentName) + 's';

        String selectQuery = 'SELECT Status, Pricebook2Id, Pricebook2.Name ';
        String selectSubQuery = ', (SELECT Id FROM ' + subQueryObject + ') ';
        String fromQuery = 'FROM ' + parentName;
        String whereQuery = ' WHERE Id=\'' + parentId + '\'';
        SObject parentAndLineItems = Database.query(selectQuery + selectSubQuery + fromQuery + whereQuery);
        
        if(parentAndLineItems.get('Status') == 'Activated'){
            return new PricebookResponseWrapper(true, null, null);
        }

        if(parentAndLineItems.getSObjects(subQueryObject) == null){
            return new PricebookResponseWrapper(false, true, getAllPricebooks());
        } 

        return new PricebookResponseWrapper(
            false, false, 
            new List<LWCComboBoxPricebookWrapper>{
                new LWCComboBoxPricebookWrapper(
                    (String)parentAndLineItems.getSObject('Pricebook2').get('Name'), 
                    (String)parentAndLineItems.get('Pricebook2Id'))
            });
    }

    @AuraEnabled
    public static List<LWCComboBoxPricebookWrapper> getAllPricebooks(){
        List<LWCComboBoxPricebookWrapper> allPricebooks = new List<LWCComboBoxPricebookWrapper>();

        for(Pricebook2 pricebook: [
            SELECT Name, Id
            FROM Pricebook2
        ]){
            allPricebooks.add(new LWCComboBoxPricebookWrapper(pricebook.Name, pricebook.Id));
        }

        return allPricebooks;
    }

    @AuraEnabled
    public static void setPricebookOnParent(String recordId,String parentName, String pricebookId){
        SObject xliParent = Schema.getGlobalDescribe().get(parentName).newSObject();
        xliParent.put('Id', recordId);
        xliParent.put('Pricebook2Id', pricebookId);

        update xliParent;
    }

    @AuraEnabled
    public static List<LWCDatatableDataWrapper> getAvailableProducts(String pricebookId){
        List<LWCDatatableDataWrapper> productAvailableList = new List<LWCDatatableDataWrapper>();

        for(PricebookEntry pbe:[
            SELECT Id, Product2.Name, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId AND IsActive = true
        ]){
            productAvailableList.add(new LWCDatatableDataWrapper(
                pbe.Id, pbe.Product2.Name, pbe.UnitPrice
            ));
        }

        return productAvailableList;
    }

    @AuraEnabled
    public static void addProductLineItems(String parentName, String parentId, String pricebookEntryId){
        List<OrderItem> orderItem2Insert = new List<OrderItem>();
        List<OrderItem> orderItem2Update = new List<OrderItem>();
        Map<String, SObject> pricebookEntryPerXLineItemMap = new Map<String, SObject>();

        String selectQuery = 'SELECT Id, PricebookEntryId, Quantity ';
        String fromQuery = 'FROM ' + Constants.PARENT_XLINEITEMCHILD.get(parentName);
        String whereQuery = ' WHERE ' + parentName + 'Id=\'' + parentId + '\'';

        for(SObject xli: Database.query(selectQuery + fromQuery + whereQuery)){
            pricebookEntryPerXLineItemMap.put((String)xli.get('PricebookEntryId'), (SObject)xli);
        }

        SObject cuXLineItem = Schema.getGlobalDescribe().get(Constants.PARENT_XLINEITEMCHILD.get(parentName)).newSObject();
        if(pricebookEntryPerXLineItemMap.containsKey(pricebookEntryId)){
            cuXLineItem = pricebookEntryPerXLineItemMap.get(pricebookEntryId);
            updateXLineItem('increaseQuantity', cuXLineItem);
        } else {
            createXLineItem(cuXLineItem, pricebookEntryId, parentName, parentId);
        }

        KProjectDebugging.printDebug('upsertXLineItem', cuXLineItem);

        upsert cuXLineItem;
    }

    public static void updateXLineItem(String action, SObject xLineItem){
        if(action == 'increaseQuantity'){
            increaseXLineItemQuantity(xLineItem);
        }
    }

    public static void createXLineItem(SObject xLineItem, String pricebookEntryId, String parentName, String parentId){
        PricebookEntry pbeInfo = [
            SELECT Id, Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Id = :pricebookEntryId
        ];
        xLineItem.put('PricebookEntryId', pbeInfo.Id);
        xLineItem.put('Product2Id', pbeInfo.Product2Id);
        xLineItem.put('UnitPrice', pbeInfo.UnitPrice);
        xLineItem.put(parentName + 'Id', parentId); //Ex: Order + Id = OrderId
        xLineItem.put('Quantity', 1);
    }

    public static void increaseXLineItemQuantity(SObject xLineItem){
        Decimal currentQuantity = (Decimal)xLineItem.get('Quantity');
        currentQuantity++;
        xLineItem.put('Quantity', currentQuantity);
    }

    public class LWCDatatableDataWrapper{
        @AuraEnabled public String pricebookEntryId;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal unitPrice;
        public LWCDatatableDataWrapper(String pricebookEntryId, String productName, Decimal unitPrice){
            this.pricebookEntryId = pricebookEntryId;
            this.productName = productName;
            this.unitPrice = unitPrice;
        }
    }

    public class PricebookResponseWrapper{
        @AuraEnabled public Boolean xIsActive;
        @AuraEnabled public Boolean canChange;
        @AuraEnabled public List<LWCComboBoxPricebookWrapper> pricebooks;
        public PricebookResponseWrapper(Boolean xIsActive, Boolean canChange,List<LWCComboBoxPricebookWrapper> pricebooks){
            this.xIsActive = xIsActive;
            this.canChange = canChange;
            this.pricebooks = pricebooks;
        }
    }

    public class LWCComboBoxPricebookWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public LWCComboBoxPricebookWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}
