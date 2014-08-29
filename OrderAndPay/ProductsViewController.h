//
//  ProductsViewController.h
//  OrderAndPay
//
//  Created by Marco Denisi on 23/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ProductsViewController : UITableViewController <MCBrowserViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *orderButton;
@property (strong, nonatomic) IBOutlet UILabel *totalPrice;
@property (strong, nonatomic) IBOutlet UILabel *finalLabel;

@end
