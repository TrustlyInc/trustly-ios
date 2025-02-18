//
//  WebViewManager.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 18/02/25.
//

import Foundation
@preconcurrency import WebKit
import SafariServices

    
@available(iOS 12.0, *)
class WebViewManager : NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    
    private var returnHandler:TrustlyViewCallback?
    private var cancelHandler:TrustlyViewCallback?
    private var externalUrlHandler:TrustlyViewCallback?
    private var changeListenerHandler:TrustlyListenerCallback?
    
    var bankSelectedHandler:TrustlyViewCallback?
    var establishData:[AnyHashable : Any]?
    
    private var mainWebView:WKWebView
    private var returnUrl = Constants.RETURN_URL
    private var cancelUrl = Constants.CANCEL_URL

    init(webView: WKWebView){
        self.mainWebView = webView
    }

}

// MARK: WKUIDelegate Protocol
extension WebViewManager {
    //1: Handles new window creation (window.open)
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        if(webView == mainWebView) {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                // TODO: Fix it
//                self.openOAuth(url: url)
            }
            
        } else {
            //1.2: On the OAuth view opens the new window on a SFSafariViewController
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                presentOnSFSafariViewController(url)
            }
        }
        return nil
    }
}

// MARK: WKUserContentController Protocol
extension WebViewManager {
    public func userContentController(_ userContentController:WKUserContentController, didReceive message:WKScriptMessage){
        let content = message.body as? String
        if content == nil {
            return
        }
        
        if message.webView == mainWebView {
            let params:[String]! = content?.components(separatedBy: "|")
            if params.count == 0 {
                return
            }
            
            let command = params[0]
            if command.isEqual("") {
                return
            }
            
            if command.isEqual("PayWithMyBank.event") {
                let eventName:String! = "event"
                
                var eventDetails = [String:String]()
                eventDetails["page"] = (params.count > 2 ? params[2] : "")
                eventDetails["type"] = (params.count > 5 ? params[5] : "")
                eventDetails["transactionId"] = (params.count > 3 ? params[3] : "")
                eventDetails["merchantReference"] = (params.count > 4 ? params[4] : "")
                
                let data:String! = (params.count > 6 ? params[6] : "")
                let transfer:String! = (params.count > 7 ? params[7] : "")
                
                if data.count != 0 {
                    eventDetails["data"] = data
                }
                
                if data.count != 0 {
                    eventDetails["transfer"] = transfer
                }
                
                notifyListener(eventName, eventDetails)
                
            }
        }
    }
}


// MARK: WKNavigationDelegate Protocol
extension WebViewManager {
    public func webView(_ webView:WKWebView, didFinish navigation:WKNavigation!) {

        let contentSize:CGSize = webView.scrollView.contentSize
        let viewSize:CGSize = webView.bounds.size

        if viewSize.width>0 && contentSize.width>0 {
            let rw = viewSize.width / contentSize.width
            webView.scrollView.minimumZoomScale = rw
            webView.scrollView.maximumZoomScale = rw
            webView.scrollView.zoomScale = rw
        }

        if webView.tag == WidgetView {
            self.notifyEvent("widget","load")
        }
        
        if let theTitle = webView.title, !theTitle.isEmpty {
            let matches = ValidationHelper.findMatchesForErrorCode(content: theTitle)
            
            if let cancelHandler = self.cancelHandler, ValidationHelper.isErrorCodePage(matches: matches, content: theTitle) {
                cancelHandler([:])
            }
            
        } else {
           
            if let url = webView.url, url.absoluteString.contains("/undefined") {
                webView.evaluateJavaScript("document.title", completionHandler: { result, error in
                    guard let dataHtml = result as? String else { return }
                    
                    let matches = ValidationHelper.findMatchesForErrorCode(content: dataHtml)
                    
                    if let cancelHandler = self.cancelHandler, ValidationHelper.isErrorCodePage(matches: matches, content: dataHtml) {
                        cancelHandler([:])
                    }
                })
            }
        }
    }

    public func webView(webView:WKWebView!, didFailNavigation error:NSError!) {

        if webView == mainWebView {
            if (self.cancelHandler != nil) {
                self.cancelHandler!([:])
            }
        }
    }

    //Handles page navigation on the WKWebView
    public func webView(_ webView:WKWebView, decidePolicyFor navigationAction:WKNavigationAction, decisionHandler:(WKNavigationActionPolicy)->Void) {
        let request = navigationAction.request
        let targetFrame = navigationAction.targetFrame;
        let host = request.url?.host
        let query = request.url?.query ?? ""
        let scheme = request.url?.scheme ?? ""
        let absolute = request.url?.absoluteString

        if(webView == mainWebView){
            if(absolute != nil && absolute!.hasPrefix(returnUrl)){
                if returnHandler != nil {
                    returnHandler!(URLUtils.parametersForUrl(request.url!))
                }
                self.notifyListener("close", nil)
                decisionHandler(WKNavigationActionPolicy.cancel)
            }
            else if(absolute != nil && absolute!.hasPrefix(cancelUrl)){
                if cancelHandler != nil {
                    cancelHandler!(URLUtils.parametersForUrl(request.url!))
                }
                self.notifyListener("close", nil)
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else if (scheme == "msg") {
                //messages
                switch(host){
                    case "push":
                    let params = URLUtils.urlDecode(query).components(separatedBy: "|")
                    if ("PayWithMyBank.createTransaction" == params[0]) && bankSelectedHandler != nil {
                        if params.count > 1 {
                            establishData?["paymentProviderId"] = params[1]
                        }
                            
                        if let establishData = establishData {
                            bankSelectedHandler?(establishData)
                        }
                            
                        }
                        break;
                    case .none:
                        break;
                    case .some(_):
                        break;
                }
                decisionHandler(WKNavigationActionPolicy.cancel)
            } else {
                // 3: Handle external links from the main web view by opening the links on the SFSafariViewController
                if targetFrame == nil {
                    if (self.externalUrlHandler != nil) {
                        var mutableDictionary = [String:String]()
                        mutableDictionary["url"] = request.url?.absoluteString

                        self.externalUrlHandler!(mutableDictionary)
                    } else {
                        //Open it on the SFSafariViewController
                        presentOnSFSafariViewController(request.url)
                    }
                    decisionHandler(WKNavigationActionPolicy.cancel)
                } else {
                    decisionHandler(WKNavigationActionPolicy.allow)
                }
            }
        }

    }
}

// MARK: Utility Functions
extension WebViewManager {
    
    func presentOnSFSafariViewController(_ url: URL?) {
        if url != nil {
            let vc = SFSafariViewController(url: url!)
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
              while let presentedViewController = topController.presentedViewController {
                  topController = presentedViewController
              }
              topController.present(vc, animated: true, completion: nil)
           }
        }
    }
    
    func notifyEvent(_ page : String, _ type : String) {
        var eventDetails = [String:String]()
        eventDetails["page"] = "widget"
        eventDetails["type"] = "load"

        self.notifyListener("event", eventDetails)
    }
    
    private func notifyListener(_ eventName:String!, _ eventDetails:[AnyHashable : Any]!) {
        if(changeListenerHandler != nil) {
            changeListenerHandler!(eventName, eventDetails)
        }
    }
}
