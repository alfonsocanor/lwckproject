# lwckproject
lwckproject bring us 2 LWC components that can generically interact on Order/Opportunity/Quotes UI, performing DML on Line Items and allows you to activate and send order information to an external system using REST Api
 
# Installation

- Use the metadata in this git in your Org

# Configuration

- Drag and Drop the component from App Builder on Page Layouts of: Order, Opportunity or Quote

# Files Summary
- 2 LWC: [lwcAvailableProducts](https://github.com/alfonsocanor/lwckproject/tree/master/force-app/main/default/lwc/lwcAvailableProducts "lwcAvailableProducts") and [lwcXLineItems](https://github.com/alfonsocanor/lwckproject/tree/master/force-app/main/default/lwc/lwcXLineItems "lwcXLineItems")
- 2 Business logic classes: [LWCAvailableProductsController.cls](https://github.com/alfonsocanor/lwckproject/blob/master/force-app/main/default/classes/LWCAvailableProductsController.cls "LWCAvailableProductsController.cls") and [LWCXLineItemsController.cls](https://github.com/alfonsocanor/lwckproject/blob/master/force-app/main/default/classes/LWCXLineItemsController.cls "LWCXLineItemsController.cls")
- Debugging class: [KProjectDebugging.cls](https://github.com/alfonsocanor/lwckproject/blob/master/force-app/main/default/classes/KProjectDebugging.cls "KProjectDebugging.cls")
- Custom Settings [objects/Settings_K_Project__c](https://github.com/alfonsocanor/lwckproject/tree/master/force-app/main/default/objects/Settings_K_Project__c "This path skips through empty directories")

  

### Important - Custom Settings 'Settings_K_Project__c' Records
  
| Name     |Description                   |Example                |Value |
|----------------|-------------------------------|-----------------------|---------|
| Debugging   |`Allows you to debug Apex code` |true/false|Boolean
|ExternalEndPoint          |`URL for sending the X information when activated` |https://example.com/test            | String

### General Information about the project
- Working time:
	- Configuration: 1 hour
	- Business analysis: 2 hours
	- Backend: 4.5 hours
	- Frontend: 7 hours
	- Documentation: 1 hour
	- **Total**: Around 15.5 hours
- Testing: TDD methodology 