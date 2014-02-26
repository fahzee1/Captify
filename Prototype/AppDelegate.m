//
//  AppDelegate.m
//  core data
//
//  Created by CJ Ogbuehi on 1/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "HomeViewController.h"
#import "User+Utils.h"
#import "MenuViewController.h"
#import "TWTSideMenuViewController.h"
#import "GoHomeTransition.h"
#import "FacebookFriends.h"
#import "TMCache.h"

@interface AppDelegate()
@property(strong,nonatomic)UIViewController *menuVC;
@property(strong,nonatomic)UIViewController *mainVC;
@property(strong,nonatomic)TWTSideMenuViewController *sideVC;
@end
@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [self setupViewControllers];
    
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    
    // both local and remote notifcations are called from here when app is
    // is not in the foreground
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif){
        // grab something from [localNotif.userInfo objectForKey:@"item to get"];
        // and give it to what ever view controller needs
        application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber -1;
    }
    
    UILocalNotification *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotif){
        // grab something from [remoteNotif.userInfo objectForKey:@"item to get"];
        // and give it to what ever view controller needs
        // then start downloading data from server
        application.applicationIconBadgeNumber = 0;

    }
    
  
   
    if ([[defaults valueForKey:@"facebook_user"]boolValue]){
        NSLog(@"facebook user");
        //Whenever a person opens the app, check for cached sesssion
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded){
            //if theres one just open silently without showing login
            [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                               allowLoginUI:NO
                                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                              //Handler for session state changes
                                              // This method will be called EACH time the session state changes
                                              [self sessionStateChanged:session state:status error:error];
                                          }];
        }
        else{
            [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                               allowLoginUI:YES
                                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                              [self sessionStateChanged:session
                                                                  state:status error:error];
                
                                          }];
        }
        
        if (![defaults boolForKey:@"facebookFriendsFetch"]){
            // fetch friends in the background if we dont have any
            dispatch_queue_t fbookQue = dispatch_queue_create("facebookFetcherQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
            dispatch_async(fbookQue, ^{
                [self fetchFacebookFriends];
            });
            
        }


    }
    
    if (![[defaults valueForKey:@"facebook_user"]boolValue] && ![[defaults valueForKey:@"logged"]boolValue]){
         NSLog(@" not facebook user and not logged in");
            // if not logged in show login screen
         [self showLoginOrHomeScreen];
        }
    if (![[defaults valueForKey:@"facebook_user"]boolValue] && [[defaults valueForKey:@"logged"]boolValue]){
        NSLog(@" not facebook user logged in");
         // open up to home screen and pass user
         [self showLoginOrHomeScreen];
        }
    
    
    

   
        return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyUserModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"core_data.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //const void *devTokenBytes = [deviceToken bytes];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[self stringWithDeviceToken:deviceToken] forKey:@"deviceToken"];
    
    if ([defaults valueForKey:@"firstToken"]){
        if (![[deviceToken valueForKey:@"deviceToken"] isEqualToString:[self stringWithDeviceToken:deviceToken]]){
            NSLog(@"token changed.. sending to server");
            [self sendServerDeviceToken:[self stringWithDeviceToken:deviceToken]];
        }

    }
    else{
        NSLog(@"first time getting token so send it to server");
        [defaults setBool:YES forKey:@"firstToken"];
        [self sendServerDeviceToken:[self stringWithDeviceToken:deviceToken]];
    }
}


- (void)sendServerDeviceToken:(NSString *)token
{
    NSLog(@"sending token");
    NSDictionary *parms = @{@"username": [[NSUserDefaults standardUserDefaults]valueForKey:@"username"],
                            @"action":@"updateDeviceToken",
                            @"content":token};
    
    [User updateDeviceTokenWithParams:parms
                             callback:^(BOOL wasSuccessful) {
                                 if (wasSuccessful){
                                     NSLog(@"Updated device token");
                                 }
                             }];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"deviceToken"];
    NSLog(@"%@ error in getting push notifications",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // get data from  [userInfo objectForKey:@"key of data"];
    // give it to controller that needs it
    UILocalNotification *localNotif = [userInfo objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    // download data then remove badge 
    application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber -1;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
}

- (NSString*)stringWithDeviceToken:(NSData*)deviceToken {
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return token;
}


#pragma mark - Facebook SDk
-(void)sessionStateChanged:(FBSession *)session
                     state:(FBSessionState)status
                     error:(NSError *)error
{
    __block NSString *alertText;
    __block NSString *alertTitle;
    
    //session opened successully
    if (!error && status == FBSessionStateOpen){
        NSLog(@"Session opened");
        //show user logged in UI
        [self showLoginOrHomeScreen];
        // handled in callback by vc
        return;
        
    }
    if (status == FBSessionStateClosed || status == FBSessionStateClosedLoginFailed){
        //if the session is closed
        NSLog(@"Session closed");
        //show user logged out view
        [self showLoginScreenFromFacebook];
        return;
        
    }
    //Handle errors
    if (error) {
        NSLog(@"Error");
        //if the error requires people do something outside the app to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        }else{
            //if the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled){
                NSLog(@"User cancelled login");
                
                //handle session closures that happen outside of the app
            }else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again";
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        //show user logged out UI
        //[self userLoggedOut];
    }
}





#pragma mark - convience methods
- (void)showLoginOrHomeScreen
{
    NSError *error;
    UIViewController *rootVc = self.window.rootViewController;
    UIViewController *home;
    if ([rootVc isKindOfClass:[TWTSideMenuViewController class]]){
        home = ((TWTSideMenuViewController *)rootVc).mainViewController;
    }
    else{
        home = ((UINavigationController *)rootVc).topViewController;
    }
    NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
    if (uri){
        NSManagedObjectID *superuserID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        User *user = (id) [self.managedObjectContext existingObjectWithID:superuserID error:&error];
        
        if ([(HomeViewController *)home respondsToSelector:@selector(setMyUser:)]){
            ((HomeViewController *)home).myUser = user;
        }
    }
    

    return;
    
    
}

- (void)showLoginScreenFromFacebook
{
    UIViewController *topController = [self topMostController];
    if ([topController isKindOfClass:[UINavigationController class]]){
        if ([((UINavigationController *)topController).visibleViewController isMemberOfClass:[ViewController class]]){
            return;
        }else{
            
            [[self topMostController] dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }
    return;
}

/*
- (void)showHomeScreenFromFacebook
{
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]){
        NSError *error;
        UINavigationController *navVc = (UINavigationController *)self.window.rootViewController;
        NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
        if (uri){
            NSManagedObjectID *superuserID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
            User *user = (id) [self.managedObjectContext existingObjectWithID:superuserID error:&error];
            
            if ([(HomeViewController *)navVc.topViewController respondsToSelector:@selector(setMyUser:)]){
                ((HomeViewController *)navVc.topViewController).myUser = user;
            }
        }
    }
    
    return;
}
*/

/*
- (void)showHomeScreen
{
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]){
        NSError *error;
        UINavigationController *navVc = (UINavigationController *)self.window.rootViewController;
        NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
        if (uri){
            NSManagedObjectID *superuserID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
            User *user = (id) [self.managedObjectContext existingObjectWithID:superuserID error:&error];
            if ([(HomeViewController *)navVc.topViewController respondsToSelector:@selector(setMyUser:)]){
                ((HomeViewController *)navVc.topViewController).myUser = user;
            }

        }
    }
    

    return;
}
*/

-(UIViewController*) topMostController {
    UIViewController *topController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

-(void)showMessage:(NSString *)message
         withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"Ok!"
                      otherButtonTitles:nil] show];
}


- (void)setupViewControllers
{
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    MenuViewController *menuVc = (MenuViewController *)[mainBoard instantiateViewControllerWithIdentifier:@"menu"];
    self.mainVC = self.window.rootViewController;
    self.menuVC = menuVc;
    self.sideVC = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.menuVC mainViewController:self.mainVC];
    self.sideVC.shadowColor = [UIColor blackColor];
    self.sideVC.edgeOffset = UIOffsetMake(18.0f, 0.0f);
    self.sideVC.zoomScale = 0.6643f;//0.5643f;
    self.window.rootViewController = self.sideVC;

}

- (void)fetchFacebookFriends
{
 
    FacebookFriends *f = [[FacebookFriends alloc] init];
    [f allFriends:^(BOOL wasSuccessful, NSArray *data) {
        if (wasSuccessful){
            [[TMCache sharedCache] setObject:data forKey:@"facebookFriends"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"facebookFriendsFetch"];
        }
        else{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"facebookFriendsFetch"];
        }
    }];
}



@end
