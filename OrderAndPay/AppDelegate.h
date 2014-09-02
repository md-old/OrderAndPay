//
//  AppDelegate.h
//  OrderAndPay
//
//  Created by Marco Denisi on 23/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipeerHandler.h"
#import "Order.h"
#import "Confirmation.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) MultipeerHandler *mpHandler;
@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) Confirmation *confirmation;

/**
 *  Send the order to the POS.
 *
 *  @return YES if it goes fine, NO otherwise
 */
- (BOOL) sendOrder;

/**
 *  Start the ranging of the beacon
 */
- (void) startRanging;

/**
 *  Reset the current order
 */
- (void) resetOrder;

/**
 *  Send the confirmation of the payment to the POS
 *
 *  @return YES if it goes fine, NO otherwise
 */
- (BOOL) sendCheckPayment;
@end
