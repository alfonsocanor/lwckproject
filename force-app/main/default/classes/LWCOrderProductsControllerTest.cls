@isTest
private with sharing class LWCOrderProductsControllerTest {
    @isTest
    static void retrieveAllTheCurrentLineItems(){
        Test.startTest();
            List<LWCOrderProductsController.LWCDatatableDataWrapper> allCurrentLineItems = 
                LWCOrderProductsController.getXLineItems('Order', ord.Id);
        Test.stopTest();

        System.assertEquals(3, allCurrentLineItems.size());
    }
    
    @isTest
    static void deleteTheLineItemIfTheQuantityIsOnlyOne(){
        Test.startTest();
            LWCOrderProductsController.handleXLineItemUpdate('Order', oli1.Id);
        Test.stopTest();

        List<OrderItem> orderItemsAfterDelete = [
            SELECT Id
            FROM OrderItem
            WHERE OrderId = :ord.Id
        ];

        System.assertEquals(2, orderItemsAfterDelete.size());
    }

    @isTest
    static void decreaseTheQuantityIfTheQuantityIsGreatherThatOne(){
        Test.startTest();
            LWCOrderProductsController.handleXLineItemUpdate('Order', oli2.Id);
        Test.stopTest();

        OrderItem orderItemsAfterDelete = [
            SELECT Quantity
            FROM OrderItem
            WHERE Id = :oli2.Id
        ];

        System.assertEquals(2, orderItemsAfterDelete.Quantity);
    }

    @isTest
    static void changeTheStatusOfTheRecordToActivated(){
        Test.startTest();
            Order ordBeforeUpdate = [
                SELECT Status
                FROM Order
                WHERE Id = :ord.Id
            ];

            System.assertNotEquals('Activated', ord.Status);

            LWCOrderProductsController.activateParentObject('Order', ord.Id);
        Test.stopTest();

        Order ordAfterUpdate = [
            SELECT Status
            FROM Order
            WHERE Id = :ord.Id
        ];

        System.assertEquals('Activated', ordAfterUpdate.Status);
    }

    @isTest
    static void removeTheXliIfTheQuantityIsEqualsToOne(){
        Test.startTest();
            OrderItem oliBeforeUpdate = [
                SELECT Quantity
                FROM OrderItem
                WHERE Id = :oli1.Id
            ];

            System.assertEquals(1, oliBeforeUpdate.Quantity);

            LWCOrderProductsController.handleXLineItemUpdate('Order', oli1.Id);
        Test.stopTest();

        List<OrderItem> oliAfterUpdate = [
            SELECT Quantity
            FROM OrderItem
            WHERE Id = :oli1.Id
        ];

        System.assert(oliAfterUpdate.isEmpty());
    }

    @isTest
    static void decreaseTheQuantityOfTheXliBecauseCurrentQuantityIsGreaterThatOne(){
        Test.startTest();
            OrderItem oliBeforeUpdate = [
                SELECT Quantity
                FROM OrderItem
                WHERE Id = :oli2.Id
            ];

            System.assertEquals(3, oliBeforeUpdate.Quantity);

            LWCOrderProductsController.handleXLineItemUpdate('Order', oli2.Id);
        Test.stopTest();

        OrderItem oliAfterUpdate = [
            SELECT Quantity
            FROM OrderItem
            WHERE Id = :oli2.Id
        ];

        System.assertEquals(2, oliAfterUpdate.Quantity);
    }

    @isTest
    static void returnFalseIfTheStatusOfTheRecordIsNotActivated(){
        Test.startTest();
            Boolean isNotActivated = LWCOrderProductsController.isStatusActivated('Order',ord.Id);
        Test.stopTest();

        System.assert(!isNotActivated);
    }

    @isTest
    static void calloutExternalServerAndSendOrderInformation(){ //Test only for granting coverage
        Test.setMock(HttpCalloutMock.class, new XHttpCalloutMock());
        
        HttpResponse res = new HttpResponse();
        Test.startTest();
            LWCOrderProductsController.callExternalAfterActivation('Order', ord.Id);
        Test.stopTest();
    }

    static Account acc;
    static Order ord;
    static OrderItem oli1, oli2, oli3;
    static Product2 p1, p2, p3, p4;
    static Pricebook2 stdPricebook;
    static PricebookEntry pbeStd1, pbeStd2, pbeStd3, pbeStd4;
    static Settings_K_Project__c externalEndPoint;
    static{
        externalEndPoint =            
            new Settings_K_Project__c(
                Name = 'ExternalEndPoint',
                Value__c = 'https://kprojectapi.requestcatcher.com/test'
        );

        insert externalEndPoint;

        stdPricebook = Builder.aPricebook()
            .setIdIfStandard(Test.getStandardPricebookId())
            .setIsActive(true)
            .setName('Standard Price Book')
            .build();
        
        upsert stdPricebook;

        p1 = Builder.aProduct()
            .setName('Product1')
            .build();

        p2 = Builder.aProduct()
            .setName('Product2')
            .build();
        p3 = Builder.aProduct()
            .setName('Product3')
            .build();

        p4 = Builder.aProduct()
            .setName('Product4')
            .build();

        insert new List<Product2>{p1, p2, p3, p4};

        pbeStd1 = Builder.aPricebookEntry()
            .setIsActive(true)
            .setProduct(p1)
            .setPricebook(stdPricebook)
            .setUnitPrice(10)
            .build();
        
        pbeStd2 = Builder.aPricebookEntry()
            .setIsActive(true)
            .setProduct(p2)
            .setPricebook(stdPricebook)
            .setUnitPrice(10)
            .build();

        pbeStd3 = Builder.aPricebookEntry()
            .setIsActive(true)
            .setProduct(p3)
            .setPricebook(stdPricebook)
            .setUnitPrice(10)
            .build();

        insert new List<PricebookEntry>{pbeStd1, pbeStd2, pbeStd3};

        acc = Builder.anAccount()
            .setName('Test Account')
            .build();

        insert acc;

        ord = Builder.anOrder()
            .setName('Test Order')
            .setAccount(acc)
            .setOrderStartDate(Date.today())
            .setStatus('Draft')
            .setPricebook(stdPricebook)
            .build();
        
        insert ord;

        oli1 = Builder.anOrderItem()
            .setOrder(ord)
            .setProduct(p1)
            .setPricebookEntry(pbeStd1)
            .setQuantity(1)
            .setUnitPrice(10)
            .build();

        oli2 = Builder.anOrderItem()
            .setOrder(ord)
            .setProduct(p2)
            .setPricebookEntry(pbeStd2)
            .setQuantity(3)
            .setUnitPrice(10)
            .build();

        oli3 = Builder.anOrderItem()
            .setOrder(ord)
            .setProduct(p3)
            .setPricebookEntry(pbeStd1)
            .setQuantity(1)
            .setUnitPrice(10)
            .build();

        insert new List<OrderItem>{oli1, oli2, oli3};
    }
}