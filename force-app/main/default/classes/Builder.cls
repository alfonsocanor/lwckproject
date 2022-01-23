@isTest
public with sharing class Builder {
    public class ProductBuilder {
        private Product2 product  = new Product2();

        public ProductBuilder setName(String name){
            product.Name = name;
            return this;
        }

        public Product2 build(){
            return product;
        }
    }

    public static ProductBuilder aProduct(){return new ProductBuilder();}

    public class OrderBuilder {
        private Order ord = new Order();

        public OrderBuilder setName(String name){
            ord.Name = name;
            return this;
        }

        public OrderBuilder setAccount(Account acc){
            ord.AccountId = acc.Id;
            return this;
        }

        public OrderBuilder setOrderStartDate(Date effectiveDate){
            ord.EffectiveDate = effectiveDate;
            return this;
        }

        public OrderBuilder setStatus(String status){
            ord.Status = status;
            return this;
        }

        public OrderBuilder setPricebook(Pricebook2 pricebook){
            ord.Pricebook2Id = pricebook.Id;
            return this;
        }

        public Order build(){
            return ord;
        }
    }

    public static OrderBuilder anOrder(){return new OrderBuilder();}

    public class OrderItemBuilder{
        private OrderItem oli = new OrderItem();

        public OrderItemBuilder setProduct(Product2 product){
            oli.Product2Id = product.Id;
            return this;
        }

        public OrderItemBuilder setOrder(Order order){
            oli.OrderId = order.Id;
            return this;
        }

        public OrderItemBuilder setPricebookEntry(PricebookEntry pbe){
            oli.pricebookEntryId = pbe.Id;
            return this;
        }

        public OrderItemBuilder setQuantity(Double quantity){
            oli.Quantity = quantity;
            return this;
        }

        public OrderItemBuilder setUnitPrice(Double unitPrice){
            oli.UnitPrice = unitPrice;
            return this;
        }

        public OrderItem build(){
            return oli;
        }
    }

    public static OrderItemBuilder anOrderItem(){return new OrderItemBuilder();}

    public class PricebookBuilder{
        private Pricebook2 pb = new Pricebook2();

        public PricebookBuilder setName(String name){
            pb.Name = name;
            return this;
        }

        public PricebookBuilder setIdIfStandard(Id standardPricebookId){
            pb.Id = standardPricebookId;
            return this;
        }

        public PricebookBuilder setIsActive(Boolean isActive){
            pb.IsActive = isActive;
            return this;
        }

        public Pricebook2 build(){
            return pb;
        }
    }

    public static PricebookBuilder aPricebook(){return new PricebookBuilder();}

    public class PricebookEntryBuilder{

        private PricebookEntry pbe = new PricebookEntry();

        public PricebookEntryBuilder setProduct(Product2 product){
            pbe.Product2Id = product.Id;
            return this;
        }

        public PricebookEntryBuilder setPricebook(Pricebook2 pricebook){
            pbe.Pricebook2Id = pricebook.Id;
            return this;
        }

        public PricebookEntryBuilder setUnitPrice(Decimal unitPrice){
            pbe.UnitPrice = unitPrice;
            return this;
        }

        public PricebookEntryBuilder setIsActive(Boolean isActive){
            pbe.IsActive = isActive;
            return this;
        }

        public PricebookEntry build(){
            return pbe;
        }
    }

    public static PricebookEntryBuilder aPricebookEntry(){return new PricebookEntryBuilder();}

    public class AccountBuilder{
        private Account acc = new Account();

        public AccountBuilder setName(String name){
            acc.Name = name;
            return this;
        }

        public Account build(){
            return acc;
        }
    }

    public static AccountBuilder anAccount(){return new AccountBuilder();}
}