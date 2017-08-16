//
//  PYLSocialPagesViewController.swift
//  Peyala
//
//  Created by Pradip Paul on 04/10/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLSocialPagesViewController: PYLBaseViewController , UIWebViewDelegate {
    //MARK:- outlet Connection
    enum socialKeyType {
        case kFacebook
        case kTwitter
    }
    
    var socialKey:socialKeyType!
    @IBOutlet var webviewSocial: UIWebView!
    override func viewDidLoad()
    {
      
        self.menuButtonEnabled = true
        self.notificationButtonEnabled = true
        self.rightLogoEnabled = true
        super.viewDidLoad()
        self.title = "SOCIAL"
        webviewSocial.scalesPageToFit = true
        webviewSocial.delegate = self
        
        
        switch socialKey! {
        case socialKeyType.kFacebook:
            trackScreenForAnalyticsWithName(PEYALA_ON_FB_SCREEN, isGoogle: true, isFB: true)
             let openurl = peyalaFaceBookLink
             let url = URL(string: openurl)
              let request = URLRequest(url: url!)
             webviewSocial.loadRequest(request)
            
       
        case socialKeyType.kTwitter:
            trackScreenForAnalyticsWithName(PEYALA_ON_INSTA_SCREEN, isGoogle: true, isFB: true)
            let sourceurl = peyalaInstaLink
            let networkurl = URL(string: sourceurl)
             let networkrequest = URLRequest(url: networkurl!)
             webviewSocial.loadRequest(networkrequest)
            
           
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        PYLSpinner.show()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        PYLSpinner.hide()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        PYLSpinner.hide()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
