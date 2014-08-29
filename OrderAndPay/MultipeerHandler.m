//
//  MultipeerHandler.m
//  OrderAndPay
//
//  Created by Marco Denisi on 26/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import "MultipeerHandler.h"

NSString *const kServiceType = @"pb-posemitter";

@implementation MultipeerHandler

- (void) setupPeerWithDisplayName:(NSString *)name
{
    self.peerId = [[MCPeerID alloc] initWithDisplayName:name];
}

- (void) setupSession
{
    self.session = [[MCSession alloc] initWithPeer:self.peerId];
    self.session.delegate = self;
}

- (void) setupBrowser
{
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:kServiceType session:self.session];
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"HERE");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderComplete" object:self];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

@end
