public with sharing class Constants {
    public static final Map<String, String> STATUS_ON_X_ADD_PRODUCT_VALIDATION = new Map<String, String>{
        'Order' => 'Activated',
        'Quote' => 'Activated',
        'Opportunity' => 'Activated'
    };

    public static final Map<String, String> PARENT_XLINEITEMCHILD = new Map<String, String>{
        'Order' => 'OrderItem',
        'Opportunity' => 'OpportunityLineItem',
        'Quote' => 'QuoteLineItem'
    };
}