//
//  AppDelegate.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "GPUImage.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain)User *myUser;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


-(void)sessionStateChanged:(FBSession *)session
                     state:(FBSessionState)status
                     error:(NSError *)error;

- (void)showLoginOrHomeScreen;



+ (BOOL)saveFileToDocuments:(NSString *)name
                   withFile:(NSData *)file;

+ (NSData *)retrieveFileAtPath:(NSString *)path;

+ (BOOL)deleteFileAtPath:(NSString *)path;

+ (void)clearImageCaches;




@end
