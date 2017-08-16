///Users/sslwireless/Documents/Notifcation UI/noti_Close2.png
//  SSLCommerz_ViewController.h
//  SSLCOMMERZ_SDKTest
//
//  Created by SSL Wireless on 7/18/16.
//  Copyright © 2016 SSL Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSLCommerz_ViewController : UIViewController <UIWebViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *gatewayDetails;
@property (nonatomic, strong) NSString *sessionKey;
@property (weak, nonatomic) IBOutlet UIWebView *SSLCOMMERZWebview;
@property (weak, nonatomic) IBOutlet UIView *SSLCOMMERZ_WebViewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webviewContainerTopSpaceConstratint;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewCards;
- (IBAction)CardSelectionAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *labelCardMessage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintCardMessageHeigh;
@property (strong, nonatomic) IBOutlet UIButton *buttonDebitCreditCard;

@end
