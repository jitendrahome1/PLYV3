//
//  SSLCommerz_ViewController.m
//  SSLCOMMERZ_SDKTest
//
//  Created by SSL Wireless on 7/18/16.
//  Copyright © 2016 SSL Wireless. All rights reserved.
//

#import "SSLCommerz_ViewController.h"
#import "GatewayTableViewCell.h"
#import "Gateway.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "PYLCollectionViewCell.h"
#import "Peyala-Swift.h"

#define TRANSACTION_END_URL_SANDBOX     @"https://sandbox.sslcommerz.com/gwprocess/v3/api.php"
#define TRANSACTION_END_URL             @"https://securepay.sslcommerz.com/gw/apps/result.php"

@interface SSLCommerz_ViewController (){
    NSArray * _gatewayList;
    UIWindow * _mainWindow;
    NSArray *tempArray;
    int barButtonHeightInSSLCommerzView;
}

@end

@implementation SSLCommerz_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        barButtonHeightInSSLCommerzView = 31.0;
    } else {
        barButtonHeightInSSLCommerzView = 22.0;
    }
    [self setNavigationBarItem];
    
    [_collectionViewCards registerNib:[UINib nibWithNibName:@"PYLCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cellIdentifier"];
    tempArray = [NSArray arrayWithArray:self.gatewayDetails];
    _labelCardMessage.backgroundColor = [UIColor clearColor];
    [self CardSelectionAction:_buttonDebitCreditCard];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSDKViewController) name:@"PaymentCompleted" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSDKViewController) name:@"PaymentFailed" object:nil];
    
}
-(void)viewDidDisappear:(BOOL)animated{
     [super viewDidDisappear:animated];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PaymentCompleted" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
   _mainWindow = [[UIApplication sharedApplication].delegate window];
    CGRect WebViewContainerFrame = self.SSLCOMMERZ_WebViewContainer.frame;
    WebViewContainerFrame.origin.y+= _mainWindow.frame.size.height;
    self.SSLCOMMERZ_WebViewContainer.frame = WebViewContainerFrame;
    self.webviewContainerTopSpaceConstratint.constant = _mainWindow.frame.size.height+200;
    [self.view layoutIfNeeded];
}



#pragma Mark - CollectionView Delegates/DataSources
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.gatewayDetails count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PYLCollectionViewCell *cell = [_collectionViewCards dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.cornerRadius = 4.0;
    cell.layer.borderWidth = 0.5;
    Gateway *gatewayDetailsToDisplay = [self.gatewayDetails objectAtIndex:indexPath.row];
    [cell.icon setImageWithURL:[NSURL URLWithString:gatewayDetailsToDisplay.gatewayLogoURL]];
    cell.Title.text = gatewayDetailsToDisplay.gatewayTitle;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(90, 90);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Gateway *gatewayDetailsToDisplay = [self.gatewayDetails objectAtIndex:indexPath.row];
    
    [self.SSLCOMMERZWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self toggleWebview:YES];
    gatewayDetailsToDisplay.gatewayRedirectURL = [gatewayDetailsToDisplay.gatewayRedirectURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL *url = [NSURL URLWithString:gatewayDetailsToDisplay.gatewayRedirectURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.SSLCOMMERZWebview loadRequest:request];
}

#pragma mark - webview Delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView{
    dispatch_after(0, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.SSLCOMMERZWebview animated:YES];
    });
    [MBProgressHUD showHUDAddedTo:self.SSLCOMMERZWebview animated:YES];
    NSURL * myRequestedUrl= [webView.request mainDocumentURL];
    NSLog(@"Requested url: %@", myRequestedUrl);
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    dispatch_after(0, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.SSLCOMMERZWebview animated:YES];
    });
    NSURL* endPointURL = [self.SSLCOMMERZWebview.request mainDocumentURL];
    NSLog(@"before didfinshed - %@", endPointURL.absoluteString);
    if ([endPointURL.absoluteString isEqualToString:@"https://securepay.sslcommerz.com/gw/apps/result.php"]) {
        NSLog(@"endPointURL condition satisfied - ");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TransactionResultAvailableNotification" object:nil userInfo:nil];
        //[self closeSDKViewController];
    }
    
}

#pragma mark - webview Toggle

-(void)toggleWebview:(BOOL) isON {
    //__block   CGRect webviewContainerFrame = self.SSLCOMMERZ_WebViewContainer.frame;
    if (isON) {
        [UIView animateWithDuration:0.3 animations:^{
            self.webviewContainerTopSpaceConstratint.constant = 0;//_mainWindow.frame.size.height;
            [self.view layoutIfNeeded];
        }];
    }
    
    else{
        [UIView animateWithDuration:0.3 animations:^{
            
            self.webviewContainerTopSpaceConstratint.constant = _mainWindow.frame.size.height+200;
            [self.view layoutIfNeeded];
            
        }];
    }
}

#pragma mark - Button Actions

- (IBAction)closeButtonTapped:(id)sender {
     //[self toggleWebview:NO];
}

- (IBAction)sdkCloseTapped:(id)sender {
    [self closeSDKViewController];
}

-(void)closeSDKViewController{
    dispatch_after(0, dispatch_get_main_queue(), ^(void){
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
    });
}

- (IBAction)CardSelectionAction:(UIButton*)sender {
    self.gatewayDetails = tempArray;
    for (UIView *view in sender.superview.superview.subviews ) {
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = (UILabel *)[view viewWithTag:2];
        label.textColor = [UIColor lightGrayColor];
        UIImageView *icon = (UIImageView *)[view viewWithTag:1];
        switch (view.tag) {
            case 11:
                icon.image = [UIImage imageNamed:@"DebitOrCreditCardsDeselected"];
                break;
            case 22:
                icon.image = [UIImage imageNamed:@"InternetBankingDeselected"];
                break;
            case 33:
                icon.image = [UIImage imageNamed:@"MobileBankingDeselected"];
                break;
                
            default:
                break;
        }
    }
    //sender.superview.backgroundColor = [UIColor orangeColor];
    UILabel *label = (UILabel *)[ sender.superview viewWithTag:2];
    UIImageView *icon = (UIImageView *)[sender.superview viewWithTag:1];
    icon.image = [UIImage imageNamed:@""];
    label.textColor = [UIColor whiteColor];
    
    NSMutableArray *filtredArray = [[NSMutableArray alloc]init];
    NSString *filterKey;
    switch (sender.tag) {
        case 1:{
            filterKey = @"";
            icon.image = [UIImage imageNamed:@"DebitOrCreditCardsSelected"];
            _constraintCardMessageHeigh.constant = 40;
            for (Gateway *gateway in self.gatewayDetails) {
                if (!([gateway.gatewayType isEqualToString:@"internetbanking"] || [gateway.gatewayType isEqualToString:@"mobilebanking"])) {
                    [filtredArray addObject:gateway];
                }
            }
        }
            break;
        case 2:{
            filterKey = @"internetbanking";
            _constraintCardMessageHeigh.constant = 0;
            icon.image = [UIImage imageNamed:@"InternetBankingSelected"];
            for (Gateway *gateway in self.gatewayDetails) {
                if ([gateway.gatewayType isEqualToString:filterKey]) {
                    [filtredArray addObject:gateway];
                }
            }
            
        }
            break;
        case 3:{
            filterKey = @"mobilebanking";
            _constraintCardMessageHeigh.constant = 0;
            icon.image = [UIImage imageNamed:@"MobileBankingSelected"];
            for (Gateway *gateway in self.gatewayDetails) {
                if ([gateway.gatewayType isEqualToString:filterKey]) {
                    [filtredArray addObject:gateway];
                }
            }
        }
            break;
            
        default:
            break;
    }
  
    self.gatewayDetails = filtredArray;
    [_collectionViewCards reloadData];
}

//MARK: - *************** Navigation Bar Items Setup ***************
-(void)setNavigationBarItem {
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    UIButton *Button = [[UIButton alloc]init];
    Button.frame = CGRectMake(0, 0, barButtonHeightInSSLCommerzView, barButtonHeightInSSLCommerzView);
    Button.userInteractionEnabled = NO;
    [Button setBackgroundImage:PYLHelper.helper.selectedCountryFlagImage forState:UIControlStateNormal];
    barButton.customView = Button;
    self.navigationItem.rightBarButtonItem = barButton;
    //self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
}

-(void)dealloc{
    //remove observer upon dealloc

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PaymentCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PaymentFailed" object:nil];
}
@end
