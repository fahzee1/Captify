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

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];

    if ([defaults valueForKey:@"facebook_user"]){
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

    }
    
    if (![defaults valueForKey:@"facebook_user"] && ![defaults valueForKey:@"logged"]){
         NSLog(@" not facebook user and not logged in");
            // if not logged in show login screen
         [self showLoginScreen];
        }
    if (![defaults valueForKey:@"facebook_user"] && [defaults valueForKey:@"logged"]){
        NSLog(@" not facebook user logged in");
         // open up to home screen and pass user
         [self showHomeScreen];
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
        [self showHomeScreenFromFacebook];
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
- (void)showLoginScreen
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    ViewController *homevc = (ViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"startScreen"];
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:homevc];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:navC animated:NO completion:nil];
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

- (void)showHomeScreenFromFacebook
{
    NSError *error;
    HomeViewController *vc = (HomeViewController *)self.window.rootViewController;
    NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
    if (uri){
        NSManagedObjectID *superuserID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        User *user = (id) [self.managedObjectContext existingObjectWithID:superuserID error:&error];
        vc.myUser = user;
    }
    
    return;
}


- (void)showHomeScreen
{
    NSError *error;
    HomeViewController *vc = (HomeViewController *)self.window.rootViewController;
    NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
    if (uri){
        NSManagedObjectID *superuserID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        User *user = (id) [self.managedObjectContext existingObjectWithID:superuserID error:&error];
        vc.myUser = user;
    }
    

    return;
}

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




@end
