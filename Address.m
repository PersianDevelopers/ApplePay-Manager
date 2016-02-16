//
//  Address.m
//  ApplePayManger
//
//  Created by Ali Pourhadi on 2016-02-12.
//  Copyright © 2016 Ali Pourhadi. All rights reserved.
//

#import "Address.h"

@implementation Address

+ (Address *)addressFromContact:(PKContact *)contact {
    Address *address = [[Address alloc]init];
    address.name = [NSString stringWithFormat:@"%@ %@",contact.name.givenName,contact.name.familyName];
    address.street = contact.postalAddress.street;
    address.city = contact.postalAddress.city;
    address.province = contact.postalAddress.state;
    address.country = contact.postalAddress.country;
    address.countryCode = contact.postalAddress.ISOCountryCode;
    return address;
}

+ (PKContact *)contactForAddress:(Address *)address {
    PKContact *contact = [[PKContact alloc]init];
    
    NSPersonNameComponents *nameComponent = [[NSPersonNameComponents alloc]init];
    address.name = [address.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    nameComponent.givenName = [[address.name componentsSeparatedByString:@" "]firstObject];
    if ([[address.name componentsSeparatedByString:@" "]count] > 1)
        nameComponent.familyName = [[address.name componentsSeparatedByString:@" "]objectAtIndex:1];
    contact.name = nameComponent;
    
    CNPhoneNumber *phone = [CNPhoneNumber phoneNumberWithStringValue:address.phoneNumber];
    contact.phoneNumber = phone;

    CNMutablePostalAddress *postalAddress = [[CNMutablePostalAddress alloc]init];
    postalAddress.postalCode = address.postalCode;
    postalAddress.street = address.street;
    postalAddress.ISOCountryCode = address.countryCode;
    postalAddress.country = address.country;
    postalAddress.city = address.city;
    postalAddress.state = address.province;
    
    contact.postalAddress = postalAddress;
    
    return contact;
}

+ (ABRecordRef)recordFromAddress:(Address *)address withLabel:(NSString *)label{
    NSString *fullname = [address.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [[fullname componentsSeparatedByString:@" "]firstObject];
    NSString *lastName = @" ";
    if ([[address.name componentsSeparatedByString:@" "]count] > 1)
        lastName = [[address.name componentsSeparatedByString:@" "]objectAtIndex:1];
    
    ABRecordRef person = ABPersonCreate();
    CFErrorRef error = NULL;
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), &error);
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), &error);
    
    ABMutableMultiValueRef addressRef = ABMultiValueCreateMutable(kABDictionaryPropertyType);
    CFStringRef keys[6];
    CFStringRef values[6];
    
    keys[0] = kABPersonAddressStreetKey;
    keys[1] = kABPersonAddressCityKey;
    keys[2] = kABPersonAddressStateKey;
    keys[3] = kABPersonAddressZIPKey;
    keys[4] = kABPersonAddressCountryKey;
    keys[5] = kABPersonAddressCountryCodeKey;
    
    CFStringRef ref1;
    CFStringRef ref2;
    CFStringRef ref3;
    CFStringRef ref4;
    CFStringRef ref5;
    CFStringRef ref6;
    
    if (address.street.length > 0)
        ref1 = (__bridge_retained CFStringRef)address.street;
    else
        ref1 = CFSTR("");
    if (address.city.length > 0)
        ref2 = (__bridge_retained CFStringRef)address.city;
    else
        ref2 = CFSTR("");
    if (address.province.length > 0)
        ref3 = (__bridge_retained CFStringRef)address.province;
    else
        ref3 = CFSTR("");
    if (address.postalCode.length > 0)
        ref4 = (__bridge_retained CFStringRef)address.postalCode;
    else
        ref4 = CFSTR("");
    if (address.country.length > 0)
        ref5 = (__bridge_retained CFStringRef)address.country;
    else
        ref5 = CFSTR("");
        
    if (address.countryCode.length > 0)
        ref6 = (__bridge_retained CFStringRef)address.countryCode;
    else
        ref6 = CFSTR("");
    
    values[0] = ref1;
    values[1] = ref2;
    values[2] = ref3;
    values[3] = ref4;
    values[4] = ref5;
    values[5] = ref6;
    
    CFDictionaryRef dicref = CFDictionaryCreate(kCFAllocatorDefault, (void *)keys, (void *)values, 6, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    ABMultiValueIdentifier identifier;
    ABMultiValueAddValueAndLabel(addressRef, dicref, (__bridge_retained CFStringRef)label, &identifier);
    ABRecordSetValue(person, kABPersonAddressProperty, addressRef,&error);
    ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(address.phoneNumber), kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
    
    return person;
}

+ (BOOL)isContactCompeletForValidate:(PKContact *)contact {
    if ([[[contact postalAddress]postalCode]length] == 0)
        return NO;
    if ([[[contact postalAddress]city]length] == 0)
        return NO;
    if ([[[contact postalAddress]state]length] == 0)
        return NO;
    if ([[[contact postalAddress]country]length] == 0)
        return NO;
    return YES;
}

+ (BOOL)isContactCompelet:(PKContact *)contact {
    if ([[[contact name]familyName]length] == 0 && [[[contact name]givenName]length] == 0)
        return NO;
    if ([[[contact postalAddress]street]length] == 0)
        return NO;
    if ([[[contact postalAddress]postalCode]length] == 0)
        return NO;
    if ([[[contact postalAddress]city]length] == 0)
        return NO;
    if ([[[contact postalAddress]state]length] == 0)
        return NO;
    if ([[[contact postalAddress]country]length] == 0)
        return NO;
    return YES;
}

+ (BOOL)isPhoneNumberCompeletInContact:(PKContact *)contact{
    if (contact.phoneNumber == nil)
        return NO;
    if ([self makePhoneNumberFromString:contact.phoneNumber.stringValue].length < 8 || [self makePhoneNumberFromString:contact.phoneNumber.stringValue].length > 15 )
        return NO;
    return YES;
}

+ (NSString *)makePhoneNumberFromString:(NSString *)phoneNumber {
    if (phoneNumber) {
        NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString *resultString = [[phoneNumber componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        resultString = [resultString stringByReplacingOccurrencesOfString:@" " withString:@""];
        return resultString;
    }
    return @"";
}

@end
