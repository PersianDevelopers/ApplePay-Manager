//
//  ApplePayManager.h
//  ApplePayManger
//
//  Created by Ali Pourhadi on 2016-02-12.
//  Copyright © 2016 Ali Pourhadi. All rights reserved.
//

@import PassKit;
@import Foundation;

#import "Address.h"

@interface ApplePayManager : NSObject <PKPaymentAuthorizationViewControllerDelegate>

#pragma makr Properties

/**
 *  Check your account to find SANDBOX and PROD identifier
 */
@property NSString * merchantIdentifier;

/**
 *  shipping Address
 */
@property Address * shippingAddress;

/**
 *  billing Address
 */
@property Address * billingAddress;

/**
 *  array of shipping methods
 */
@property NSArray * shippingMethods;


/**
 *  curreny to show in receipt
 */
@property NSString * currency;


/**
 *  array of receiptItem obejects
 */
@property NSArray * receiptInformation;


#pragma mark Class Methods

/**
 *  check if device support applePay
 *
 *  @return YES if the device support apple pay otherwise NO.
 */
+ (BOOL)isApplePayAvailable;

/**
 *  check if ApplePay is already setup
 *
 *  @return YES if ApplePay is already setup otherwise NO.
 */
+ (BOOL)isApplePaySetup;

/**
 *  if device support applepay but user did not set it up. you can call this method.
 */
+ (void)setupApplePay;


#pragma mark Object Methods

/**
 *  showing applepay window
 *
 *  @param viewController your checkout viewController should pass
 */
- (void)showPaymentViewFromViewController:(UIViewController *)viewController;

@end
