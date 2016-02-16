//
//  ShippingMethod.h
//  ApplePayManger
//
//  Created by Ali Pourhadi on 2016-02-12.
//  Copyright © 2016 Ali Pourhadi. All rights reserved.
//

///

#import <Foundation/Foundation.h>

/**
 *  Shipping Method Information
 */

@interface ShippingMethod : NSObject

// title of shipping : Shipping | Pickup | Digital download ....
@property (nonatomic, strong) NSString *label;
// description
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *identifier;
// shipping price
@property (nonatomic, strong) NSDecimalNumber *amount;

@end
