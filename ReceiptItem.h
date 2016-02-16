//
//  ReceiptItem.h
//  ApplePayManger
//
//  Created by Ali Pourhadi on 2016-02-16.
//  Copyright © 2016 Ali Pourhadi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiptItem : NSObject

/**
 *  title of item
 */
@property NSString * label;

/**
 *  price of item
 */
@property (nonatomic, strong) NSDecimalNumber *amount;


@end
