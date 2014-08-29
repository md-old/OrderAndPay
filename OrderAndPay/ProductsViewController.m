//
//  ProductsViewController.m
//  OrderAndPay
//
//  Created by Marco Denisi on 23/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import "ProductsViewController.h"
#import "ProductDetailViewController.h"
#import "PPViewController.h"
#import "AppDelegate.h"
#import "ProductCell.h"
#import "Product.h"

@interface ProductsViewController ()

@property (strong, nonatomic) AppDelegate *delegate;

@end

@implementation ProductsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [self.delegate.mpHandler setupPeerWithDisplayName:[UIDevice currentDevice].name];
    [self.delegate.mpHandler setupSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orderComplete:)
                                                 name:@"OrderComplete"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(beginPayment:)
                                                 name:@"BeginPayment"
                                               object:nil];
    
}

- (void) beginPayment: (NSNotification*) notification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetOrder)
                                                 name:@"PaymentFinished"
                                               object:nil];
    
    [self performSegueWithIdentifier:@"BeginPayment" sender:self];
}

- (void) orderComplete:(NSNotification *) notification {
    [self.delegate startRanging];
    [self.tableView setUserInteractionEnabled: NO];
    [self.orderButton setHidden:YES];
    [self.finalLabel setHidden:NO];
    }

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.delegate.products count] != 0) {
        [self.tableView reloadData];
    }
    
    if (!self.orderButton.enabled) {
        if (self.delegate.mpHandler.session != nil) {
            [self.delegate.mpHandler setupBrowser];
            [self.delegate.mpHandler.browser setDelegate:self];
            
            [self presentViewController:self.delegate.mpHandler.browser
                               animated:YES
                             completion:nil];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Update the order with the new item
 *
 *  @param sender the id of the textfield
 */
- (IBAction)updateOrder:(id)sender {
    ProductCell *cell = (ProductCell*) [[[sender superview] superview] superview];
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    
    // Get the new quantity
    int qta = [cell.qta.text intValue];
    // Retrieve the right product and see if it's already in the order
    Product *p = [self.delegate.products objectAtIndex:index.row];
    int result = [self.delegate.order verifyIfProductIsPresent:p.identifier];
    
    if (qta == 0) {
        // If the product is in the order, delete it
        if (result > -1) {
            [self.delegate.order deleteProductWithId: p.identifier andPosition:result];
        }
    } else {
        // If the product is in the order, update the quantity, else add a brand new product
        if (result > -1) {
            [self.delegate.order updateProductAtIndex: result withQuantity: qta];
        } else {
            [self.delegate.order.products addObject:p];
            NSNumber *quantity = [[NSNumber alloc] initWithInt:qta];
            [self.delegate.order.quantities addObject:quantity];
        }
    }
    
    self.totalPrice.text = [NSString stringWithFormat:@"%d", [self.delegate.order getTotalPrice]];
    
}

/**
 *  Send the current order to the POS
 *
 *  @param sender the id of the button
 */
- (IBAction)sendOrderToPOS:(id)sender {
    NSString *message = [[NSString alloc] init];
    NSString *alertType = [[NSString alloc] init];
    if (![self.delegate sendOrder]) {
        message = @"Something went wrong.";
        alertType = @"Error";
    } else {
        message = @"Order sent!";
        alertType = @"OK";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertType
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Got It", nil];
    [alertView show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.delegate.products count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCell *cell = (ProductCell*) [tableView dequeueReusableCellWithIdentifier:@"Product" forIndexPath:indexPath];
    
    Product *product = (Product*)[self.delegate.products objectAtIndex:indexPath.row];
    NSMutableString *price = [[NSMutableString alloc] initWithString:[product.price stringValue]];
    [price appendString:@" $"];
    
    cell.name.text = product.name;
    cell.price.text = price;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Helper Methods

- (void) resetOrder
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PaymentFinished" object:nil];
    [self.delegate resetOrder];
    self.totalPrice.text = @"0";
    [self.finalLabel setHidden:YES];
    [self.tableView setUserInteractionEnabled: YES];
    [self.orderButton setHidden:NO];
    [self.view reloadInputViews];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowDetails"])
    {
        ProductDetailViewController *detailViewController = [segue destinationViewController];
        
        NSIndexPath *myIndexPath = [self.tableView
                                    indexPathForSelectedRow];
        
        long row = [myIndexPath row];
        
        Product *prod = [self.delegate.products objectAtIndex:row];
        
        detailViewController.nameP = prod.name;
        detailViewController.descP = prod.description;
    }
}

#pragma mark - MCBrowserViewController Delegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self.delegate.mpHandler.browser dismissViewControllerAnimated:YES completion:nil];
    self.orderButton.enabled = YES;
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.delegate.mpHandler.browser dismissViewControllerAnimated:YES completion:nil];
}

@end
