//
//  Address.h
//  ApplePayManger
//
//  Created by Ali Pourhadi on 2016-02-12.
//  Copyright © 2016 Ali Pourhadi. All rights reserved.
//

@import Foundation;
@import AddressBook;
@import PassKit;

@interface Address : NSObject

/**
 *  Address information like name,stree,city...
 */

@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * street;
@property (nonatomic,strong) NSString * city;
@property (nonatomic,strong) NSString * province;
@property (nonatomic,strong) NSString * country;
@property (nonatomic,strong) NSString * countryCode;
@property (nonatomic,strong) NSString * phoneNumber;
@property (nonatomic,strong) NSString * postalCode;

/**
 *  making address from contact
 *
 *  @param contact contact object from applay
 *
 *  @return address object
 */
+ (Address *)addressFromContact:(PKContact *)contact;

/**
 *  making contact from address
 *
 *  @param address it should contatin address information
 *
 *  @return PKContact object
 */
+ (PKContact *)contactForAddress:(Address *)address;


/**
 *  making ABRecordRef From address
 *
 *  @param address it should contatin address information
 *  @param label   you should set a label for address like : shipping address/pickup address ...
 *
 *  @return ABRecordRef object
 */
+ (ABRecordRef)recordFromAddress:(Address *)address withLabel:(NSString *)label;

/**
 *  check if address is complete
 *  while validation you dont have complete address. its just for re-calculating shipping amounts
 *
 *  @param contact PKContact object from apple pay
 *
 *  @return YES if Address is complate otherwise NO
 */
+ (BOOL)isContactCompeletForValidate:(PKContact *)contact;

/**
 *  check if address is complete
 *  this validation is required after fingerprint authentication
 *
 *  @param contact PKContact object from apple pay
 *
 *  @return YES if Address is complate otherwise NO
 */
+ (BOOL)isContactCompelet:(PKContact *)contact;

/**
 *  checking phoneNumber
 *
 *  @param contact PKContact object from apple pay
 *
 *  @return YES if PhoneNumber is valid otherwise NO
 */
+ (BOOL)isPhoneNumberCompeletInContact:(PKContact *)contact;

@end
