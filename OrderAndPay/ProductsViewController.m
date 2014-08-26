//
//  ProductsViewController.m
//  OrderAndPay
//
//  Created by Marco Denisi on 23/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import "ProductsViewController.h"
#import "ProductDetailViewController.h"
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

/**
 *  Look for the POS
 *
 *  @param sender the id of the button
 */
- (IBAction)searchForPOS:(id)sender {
    if (self.delegate.mpHandler.session != nil) {
        [self.delegate.mpHandler setupBrowser];
        [self.delegate.mpHandler.browser setDelegate:self];
        
        [self presentViewController:self.delegate.mpHandler.browser
                           animated:YES
                         completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [self.delegate.mpHandler setupPeerWithDisplayName:[UIDevice currentDevice].name];
    [self.delegate.mpHandler setupSession];
    
    if ([self.delegate.products count] == 0) {
        [self.tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.delegate.mpHandler.browser dismissViewControllerAnimated:YES completion:nil];
}

@end
