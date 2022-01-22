@isTest
private with sharing class LWCOrderProductsController {

    @isTest
    static void retrieveAllTheCurrentLineItems(){}
    
    @isTest
    static void deleteTheLineItemIfTheQuantityIsOnlyOne(){}

    @isTest
    static void decreaseTheQuantityIfTheQuantityIsGreatherThatOne(){}

    @isTest
    static void updateOrderTheStatusOfTheOrderToActivated(){}

    @isTest
    static void rejectUpdateOrderIfStatusOfTheOrderIsAlreadyActived(){}

    static Account acc;
    static Order ord;
    static OrderItem oli1, oli2, oli3;
    static Product2 p1, p2, p3, p4;
    static Pricebook2 stdPricebook;
    static PricebookEntry pbeStd1, pbeStd2, pbeStd3;
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
            .setQuantity(1)
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
