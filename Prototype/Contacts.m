//
//  Contacts.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/17/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "Contacts.h"
#import <AddressBook/AddressBook.h>
#import "AwesomeAPICLient.h"

@implementation Contacts

/*
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, &error);
    if (addressBook == nil){
        NSLog(@"error: %@",error);
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted){
            // show alert to tell user how to give access somewhere else
            // from settings --> privacy --> contacts
            
            NSLog(@"error: %@",error);
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"contactsPermission"];
            return;
        }
        
        else if (granted){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"contactsPermission"];
            return;
        }
    });

    
}
*/


- (void)fetchContactsWithBlock:(ContactsBlock)block;
{
  

    
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, &error);
    if (addressBook == nil){
        NSLog(@"error: %@",error);
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted){
            // show alert to tell user how to give access somewhere else
            // from settings --> privacy --> contacts

            NSLog(@"error: %@",error);
            return ;
        }
    });
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSMutableArray *numbersList = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < nPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++){
            NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            //NSLog(@"phone is %@",phoneNumber);
            [numbersList addObject:phoneNumber];
        }
    }
    
    if (block){
        block(YES,numbersList);
    }
}

+ (NSURLSessionDataTask *)requestFriendsFromContactsList:(NSDictionary *)params
                                                   block:(ContactsRequestBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    return [client POST:AwesomeAPIFriendsString
             parameters:params
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    [client stopNetworkActivity];
                    if (block){
                        int code = [[responseObject valueForKey:@"code"] intValue];
                        if (code == 1){
                            block(YES);
                        }
                        else{
                            block(NO);
                        }
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [client stopNetworkActivity];
                    if (block){
                        block(NO);
                    }
                }];
}


@end
