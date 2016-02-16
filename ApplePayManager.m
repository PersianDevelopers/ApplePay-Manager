//
//  ApplePayManager.m
//  ApplePayManger
//
//  Created by Ali Pourhadi on 2016-02-12.
//  Copyright © 2016 Ali Pourhadi. All rights reserved.
//

#import "ApplePayManager.h"
#import "ReceiptItem.h"
#import "ShippingMethod.h"

@interface ApplePayManager()

@property (nonatomic, strong) PKPaymentAuthorizationViewController *applePayVc;

@end


@implementation ApplePayManager

+ (BOOL)isApplePayAvailable {
    if ([PKPaymentAuthorizationViewController canMakePayments])
        return YES;
    return NO;
}

+ (BOOL)isApplePaySetup {
    NSArray *acceptedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];
    BOOL canPay = [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:acceptedNetworks];
    return canPay;
}

+ (void)setupApplePay {
    PKPassLibrary* passbookLibrary = [[PKPassLibrary alloc] init];
    [passbookLibrary openPaymentSetup];
}

/**
 *  making receipt information
 *  it contains of prices that you want to show in receipt
 *  
 *  @return array of receipt information
 */
- (NSArray *)summaryItems {
    NSMutableArray *summaryItems = [[NSMutableArray alloc]init];
    for (int i = 0; i < [self.receiptInformation count]; i++) {
        ReceiptItem *currentItem = [self.receiptInformation objectAtIndex:i];
        if (i == [self.receiptInformation count] - 1 && currentItem.amount == 0) {
            /**
             *  last item should be zero. its summery of your recepit
             */
            NSLog(@"----- LAST ITEM IS ZERO -----");
            return summaryItems;
        }
        [summaryItems addObject:[PKPaymentSummaryItem summaryItemWithLabel:currentItem.label amount:currentItem.amount]];
    }
    return summaryItems;
}

/**
 *  making shipping methods
 *
 *  @return array of shipping methods with your information
 */
- (NSArray *)shippingMethod {
    NSMutableArray *shippingMethods = [[NSMutableArray alloc]init];
    for (ShippingMethod *method in self.shippingMethods) {
        PKShippingMethod *newMethod = [[PKShippingMethod alloc]init];
        [newMethod setLabel:method.label];
        [newMethod setIdentifier:method.identifier];
        [newMethod setDetail:method.detail];
        /**
         *  if your amount is 0. it shows as free in shipping
         */
        [newMethod setAmount:method.amount];
        [shippingMethods addObject:newMethod];

    }
    return shippingMethods;
}

/**
 *  making payment request
 *  some methods are depricated.
 *
 *  @return PKPayment request object
 */
- (PKPaymentRequest *)paymentRequest {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = self.merchantIdentifier;
    paymentRequest.requiredShippingAddressFields = (PKAddressFieldPostalAddress|PKAddressFieldPhone|PKAddressFieldName);
    paymentRequest.requiredBillingAddressFields = (PKAddressFieldPostalAddress|PKAddressFieldPhone|PKAddressFieldName);
    paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    
    /**
     *  if you do not send shipping address to applepay it automaticly select an address ( last time used for buy )
     */
    
    if (self.shippingAddress) {
        paymentRequest.shippingContact = [Address contactForAddress:self.shippingAddress];
        paymentRequest.shippingAddress = [Address recordFromAddress:self.shippingAddress withLabel:@"Shipping"];
    }
    if (self.billingAddress) {
        paymentRequest.billingAddress = [Address recordFromAddress:self.billingAddress withLabel:@"Billing"];
        paymentRequest.billingContact = [Address contactForAddress:self.billingAddress];
    }
    
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.countryCode = [self.billingAddress.countryCode uppercaseString];
    paymentRequest.currencyCode = [self.currency uppercaseString];
    paymentRequest.paymentSummaryItems = [self summaryItems];
    paymentRequest.shippingMethods = [self shippingMethod];
    return paymentRequest;
}


- (void)showPaymentViewFromViewController:(UIViewController *)viewController {
    PKPaymentRequest *paymentRequest = [self paymentRequest];
    self.applePayVc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    self.applePayVc.delegate = self;
    [viewController presentViewController:self.applePayVc animated:YES completion:^{

    // apple pay is presenting
    
    }];
}

#pragma mark ApplePay Delegates

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingContact:(PKContact *)contact completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion {

    /**
     *  it calls when user select another address to ship or pickup
     *  if you did not pass an addrsss to it. it calls right after applepay windows appear
     */
    
    if (![Address isContactCompeletForValidate:contact]) {
        completion(PKPaymentAuthorizationStatusInvalidShippingPostalAddress,[self shippingMethod],[self summaryItems]);
        return;
    }
    // VALIDATE YOUR ADDRESS
    // YOU SHOULD MAKE YOUR OWN ADDRESS VALIDATOR
    completion(PKPaymentAuthorizationStatusSuccess,[self shippingMethod],[self summaryItems]);

}


- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingMethod:(PKShippingMethod *)shippingMethod completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion {
    // VALIDATE YOUR PRICES
    // YOU SHOULD MAKE YOUR OWN VALIDATOR
    completion(PKPaymentAuthorizationStatusSuccess,[self summaryItems]);
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion{
    
    if (![Address isContactCompelet:payment.shippingContact]) {
        completion(PKPaymentAuthorizationStatusInvalidShippingPostalAddress);
        return;
    }
    if (![Address isPhoneNumberCompeletInContact:payment.shippingContact]) {
        completion(PKPaymentAuthorizationStatusInvalidShippingContact);
        return;
    }
    if (![Address isContactCompelet:payment.billingContact]) {
        completion(PKPaymentAuthorizationStatusInvalidBillingPostalAddress);
        return;
    }
    /**
     *  TOKENIZING Nonce
     *  You should pass it to your server or your service provider to make token for you
    if (token) {
        completion(PKPaymentAuthorizationStatusSuccess);
    } else {
        completion(PKPaymentAuthorizationStatusFailure);
    }
    */
    
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:^{
        // Closing applePay Window
    }];
}

@end
