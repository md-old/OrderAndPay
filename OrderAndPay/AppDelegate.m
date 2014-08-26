//
//  AppDelegate.m
//  OrderAndPay
//
//  Created by Marco Denisi on 23/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import "AppDelegate.h"
#import "Product.h"
@import CoreLocation;

@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSession *beaconSession;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *beaconContent;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *regions;


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Set the Multipeer Handler
    self.mpHandler = [[MultipeerHandler alloc] init];
    
    // Set the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Initialization for downloading products
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration: config
                                                 delegate:nil
                                            delegateQueue:nil];
    self.beaconSession = [NSURLSession sessionWithConfiguration: config
                                                       delegate:nil
                                                  delegateQueue:nil];
    [self getProductsFromWS];
    [self getBeaconFromWS];
    
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Retrieve Products

/**
 *  Get the list of products from the Web Service
 */
- (void) getProductsFromWS
{
    NSMutableString *endpoint = [[NSMutableString alloc] initWithString:@"http://beaconservice.herokuapp.com/RetrieveAppProducts?appId="];
    [endpoint appendString:@"41"];
    
    NSURL *url =[NSURL URLWithString:endpoint];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionTask *dataTask = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     self.content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                     [self saveDataAsJsonFile:data];
                                                 }];
    [dataTask resume];
}

/**
 *  Given the products, this method saves them in a file
 *
 *  @param data the json containing the products list
 */
- (void) saveDataAsJsonFile: (NSData *) data
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"data.json"];
    [data writeToFile:filePath atomically:YES];
    self.products = [self fetchProducts];
    NSLog(@"Prodotti presi");
}

/**
 *  Read the file in which products are saved.
 *
 *  @return an array containing all the products saved
 */
-(NSArray *) fetchProducts
{
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.json"];
    NSString *json = [NSString stringWithContentsOfFile:docPath encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *productsDictionary = [NSJSONSerialization JSONObjectWithData: data
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: NULL];
    NSMutableArray *local = [[NSMutableArray alloc] init];
    
    for (NSDictionary *product in productsDictionary) {
        Product *element = [[Product alloc] initWithJSONDictionary:product];
        [local addObject:element];
    }
    
    return local;
}

#pragma mark - Retrieve Beacon
/**
 *  A method which read from a web service all the beacons needed in the application. After reading, it calls a method to begin the monitoring
 */
- (void) getBeaconFromWS
{
    NSMutableString *endpoint = [[NSMutableString alloc] initWithString:@"http://beaconservice.herokuapp.com/RetrieveBeacons?appId="];
    [endpoint appendString:@"41"];
    
    NSURL *url =[NSURL URLWithString:endpoint];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionTask *dataTask = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     self.beaconContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                     [self startMonitoringForBeacon: data];
                                                 }];
    [dataTask resume];

}

/**
 *  Given the list of beacons, it begins monitoring for them.
 *
 *  @param jsonData a json file containing a representation of beacons
 */
- (void) startMonitoringForBeacon: (NSData*) jsonData
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    self.regions = [[NSMutableArray alloc] init];
    for (NSDictionary *beacon in json) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString: beacon[@"uuid"]];
        NSString *identifier = beacon[@"name"];
        NSNumber *mj = beacon [@"major"];
        NSNumber *mi = beacon [@"minor"];
        
        CLBeaconMajorValue majorValue = [mj intValue];
        CLBeaconMinorValue minorValue = [mi intValue];
        
        CLBeaconRegion *tmpregion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:majorValue minor:minorValue identifier:identifier];
        
        tmpregion.notifyOnEntry = YES;
        tmpregion.notifyOnExit = YES;
        
        if (tmpregion) {
            [self.regions addObject:tmpregion];
            [self.locationManager startMonitoringForRegion:tmpregion];
        }
    }

}

#pragma mark - Location Manager Delegate Methods

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Hey, did you smell something interesting? Come in and see!";
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

@end
