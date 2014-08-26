//
//  MultipeerHandler.h
//  OrderAndPay
//
//  Created by Marco Denisi on 26/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

extern NSString *const kServiceType;

@interface MultipeerHandler : NSObject <MCSessionDelegate>

@property (strong, nonatomic) MCPeerID *peerId;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCBrowserViewController *browser;

- (void) setupPeerWithDisplayName: (NSString*) name;
- (void) setupSession;
- (void) setupBrowser;

@end
