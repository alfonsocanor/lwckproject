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
}
