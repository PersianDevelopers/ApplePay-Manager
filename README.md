# ApplePay Manager

Easy and simple usage of applePay

# How to Use

- Address Class : You will find all address releaterd methods in there. working with PKContact or making AddressRef
- ShippingMethod : You will required information about shipping
- ReceiptMItem : all information about items in receipt
- ApplePayManager : Your applePay handler

Just create an object of ApplePayManager :

```objc
ApplePayManager *manager = [[ApplePayManager alloc]init]
```
now you should set all properties :

```objc
manager.shippingAddress = yourshippingAddress;
manager.billingAddress = yourBillingAddress;
manager.shippingMethods = yourshippingMethods;
manager.receiptInformation = allYourRecepeitInforamtion;
manager.currency = yourCurrency;

manager.merchantIdentifier = app.merchantId;
```
also you have three usfull methods to check if applePay state
isApplePayAvailable;
isApplePaySetup
setupApplePay;

All files well docoumented

# Author
Ali Pourhadi, ali.pourhadi@gmail.com

# License
ApplePay Manager is available under the MIT license. See the LICENSE file for more info.
