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
        DLog(@"error: %@",error);
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted){
            // show alert to tell user how to give access somewhere else
            // from settings --> privacy --> contacts
            
            DLog(@"error: %@",error);
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
        DLog(@"error: %@",error);
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted){
            // show alert to tell user how to give access somewhere else
            // from settings --> privacy --> contacts

            DLog(@"error: %@",error);
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
            //DLog(@"phone is %@",phoneNumber);
            [numbersList addObject:phoneNumber];
        }
    }
    
    if ([numbersList count] == 0){
        // retry
        DLog(@"i did retry");
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            for (int i = 0; i < nPeople; i++){
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++){
                    NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                    //DLog(@"phone is %@",phoneNumber);
                    [numbersList addObject:phoneNumber];
                }
            }

        });
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block){
            block(YES,numbersList);
        }

    });
  }


- (NSURLSessionDataTask *)requestFriendsFromContactsList:(NSDictionary *)params
                                                   block:(ContactsRequestBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    return [client POST:AwesomeAPIFriendsString
             parameters:params
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    [client stopNetworkActivity];
                    DLog(@"%@",responseObject);
                    if (block){
                        int code = [[responseObject valueForKey:@"code"] intValue];
                        if (code == 1){
                            block(YES, responseObject);
                        }
                        else{
                            block(NO, NULL);
                        }
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [client stopNetworkActivity];
                    DLog(@"error was %@",error.localizedDescription);
                    if (block){
                        block(NO, NULL);
                    }
                }];
}


@end
