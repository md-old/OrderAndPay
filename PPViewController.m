//
//  PPViewController.m
//  OrderAndPay
//
//  Created by Marco Denisi on 29/08/14.
//  Copyright (c) 2014 Marco Denisi. All rights reserved.
//

#import "PPViewController.h"
#import "AppDelegate.h"

@interface PPViewController ()

@property (strong, nonatomic, readwrite) PayPalConfiguration *payPalConfiguration;
@property (strong, nonatomic) AppDelegate *delegate;

@end

@implementation PPViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.payPalConfiguration = [[PayPalConfiguration alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
}

- (IBAction)pay:(id)sender {
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    
    NSString *amount = [[NSString alloc] initWithFormat:@"%@", self.amount];
    payment.amount = [[NSDecimalNumber alloc] initWithString: amount];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Thanks for buying.";
    
    payment.intent = PayPalPaymentIntentSale;
    
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paymentOK)
                                                 name:@"PaymentOK"
                                               object:nil];
    
    PayPalPaymentViewController *paymentViewController;
    paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                   configuration:self.payPalConfiguration
                                                                        delegate:self];
    
    // Present the PayPalPaymentViewController.
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

- (void) paymentOK
{
    NSLog(@"PAYMENT OK");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PaymentFinished"
                                                        object:nil
                                                      userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PaymentOK" object:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


//- (IBAction)closeViewController:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PaymentOK"
                                                            object:nil
                                                          userInfo:nil];

    }];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) verifyCompletedPayment: (PayPalPayment*) completedPayment
{
    NSDictionary *response = [completedPayment.confirmation objectForKey:@"response"];
    NSString *identifier = [response valueForKey:@"id"];
    
    // Set the payment ID in the delegate for the following check from the server
    self.delegate.confirmation.paymentId = [identifier copy];
    
    NSURL *url = [NSURL URLWithString:@"http://beaconservice.herokuapp.com/SavePayment"];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *messageBody = [NSString stringWithFormat:@"data=%@", identifier];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[messageBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
}

- (void) payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {}
- (void) payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {}

#pragma mark - Connection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
   
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
