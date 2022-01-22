@isTest
private with sharing class LWCAvailableProductsControllerTest {
    
    @isTest
    static void retrieveProductsBasedOnPricebookWithPricebookEntryActive(){
        Test.startTest();
            List<PricebookEntry> availableProductPerPricebookList = 
                LWCAvailableProductsController.getAvailableProducts(stdPricebook.Id);
        Test.stopTest();

        System.assertEquals(3, availableProductPerPricebookList.size());
    }

    @isTest
    static void addProductToTheLineItemsOfTheProductIfTheProductDoesNotExistInTheLineItemAndAssignQuantityEqualsToOne(){
        Test.startTest();
            LWCAvailableProductsController.addProductLineItems('Order', ord.Id, pbeStd2.Id);
        Test.stopTest();

        OrderItem oliAddedP2 = [
            SELECT Quantity
            FROM OrderItem
            WHERE orderId = :ord.Id 
                AND Product2Id = :p2.Id
        ]; 

        System.assertEquals(1, oliAddedP2.Quantity);
    }

    @isTest
    static void increaseInOneTheQuantityIfTheProductAlreadyExistInTheLineItems(){
        Test.startTest();
            LWCAvailableProductsController.addProductLineItems('Order', ord.Id, pbeStd1.Id);
        Test.stopTest();

        OrderItem oliUpdateQuantityP1 = [
            SELECT Quantity
            FROM OrderItem
            WHERE orderId = :ord.Id 
                AND Product2Id = :p1.Id
        ]; 

        System.assertEquals(2.00, oliUpdateQuantityP1.Quantity);
    }

    @isTest
    static void rejectAddProductIfStatusOfTheOrderIsActived(){}

    @isTest 
    static void sortProductsAtTheTopIfTheOrderContainsLineItems(){}

    static Account acc;
    static Order ord;
    static OrderItem oli1;
    static Product2 p1, p2, p3, p4;
    static Pricebook2 stdPricebook;
    static PricebookEntry pbeStd1, pbeStd2, pbeStd3, pbeStd4NotActive;
    static{
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

        pbeStd4NotActive =  Builder.aPricebookEntry()
            .setIsActive(false)
            .setProduct(p4)
            .setPricebook(stdPricebook)
            .setUnitPrice(10)
            .build();

        insert new List<PricebookEntry>{pbeStd1, pbeStd2, pbeStd3, pbeStd4NotActive};

        acc = Builder.anAccount()
            .setName('Test Account')
            .build();

        insert acc;

        ord = Builder.anOrder()
            .setName('Test Order')
            .setAccount(acc)
            .setOrderStartDate(Date.today())
            .setPricebook(stdPricebook)
            .setStatus('Draft')
            .build();
        
        insert ord;

        oli1 = Builder.anOrderItem()
            .setOrder(ord)
            .setProduct(p1)
            .setPricebookEntry(pbeStd1)
            .setQuantity(1)
            .setUnitPrice(10)
            .build();

        insert oli1;
    }
}