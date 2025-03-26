//
//  WebViewManager.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 18/02/25.
//

import Foundation
@preconcurrency import WebKit
import SafariServices
import AuthenticationServices

public typealias TrustlyViewCallback = (_ returnParameters: [AnyHashable : Any]) -> Void;
public typealias TrustlyListenerCallback = (_ eventName: String, _ eventDetails: [AnyHashable : Any]) -> Void;

class WebViewManager: NSObject {
    
    var establishData:[AnyHashable : Any]?
    var mainWebView:WKWebView!
    var returnHandler:TrustlyViewCallback?
    var cancelHandler:TrustlyViewCallback?
    var bankSelectedHandler:TrustlyViewCallback?
    
    private var webSession:ASWebAuthenticationSession!
    private var externalUrlHandler:TrustlyViewCallback?
    
    private var changeListenerHandler:TrustlyListenerCallback?
    
    private var returnUrl = Constants.returnURL
    private var cancelUrl = Constants.cancelURL
    
    private var sessionCid = "ios wrong sessionCid"
    private var cid = "ios wrong cid"
    
    override init() {
        super.init()
        
        self.createNotifications()
    }
    private func notifyListener(_ eventName:String!, _ eventDetails:[AnyHashable : Any]!) {
        if(changeListenerHandler != nil) {
            changeListenerHandler!(eventName, eventDetails ?? [:])
        }
    }
    
    public func onChangeListener(onChangeListener: TrustlyListenerCallback?) {
        changeListenerHandler = onChangeListener
    }
    
    func notifyEvent(_ page : String, _ type : String) {
        var eventDetails = [String:String]()
        eventDetails["page"] = "widget"
        eventDetails["type"] = "load"
        
        self.notifyListener("event", eventDetails)
    }
}

// MARK: WKUIDelegate Protocol
extension WebViewManager: WKUIDelegate{
    
    
    //1: Handles new window creation (window.open)
    public func webView(_ webView: WKWebView,
                   createWebViewWith configuration: WKWebViewConfiguration,
                   for navigationAction: WKNavigationAction,
                   windowFeatures: WKWindowFeatures) -> WKWebView? {
        if(webView == mainWebView) {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                self.openOAuth(url: url)
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
extension WebViewManager: WKScriptMessageHandler {
    
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
extension WebViewManager: WKNavigationDelegate {
    
    public func webView(_ webView:WKWebView, didFinish navigation:WKNavigation!) {

        let contentSize:CGSize = webView.scrollView.contentSize
        let viewSize:CGSize = webView.bounds.size

        if viewSize.width>0 && contentSize.width>0 {
            let rw = viewSize.width / contentSize.width
            webView.scrollView.minimumZoomScale = rw
            webView.scrollView.maximumZoomScale = rw
            webView.scrollView.zoomScale = rw
        }

        if webView.tag == Constants.widgetView {
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


// MARK: Oauth support
@available(iOS 12.0, *)
extension WebViewManager: ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

    func openOAuth(url: URL) {
        let host = url.host!
        let path = url.path
        let isLocalEnvironment = false
        
        if isLocalEnvironment || (self.checkUrl(host: host) &&
                                       path.contains(Constants.oauthLoginPath)) {

            self.buildASWebAuthenticationSession(url: url, callbackURL: EstablishDataUtils.extractUrlSchemeFrom(establishData ?? [:]), completionHandler: { (url, error) in

                if url != nil {
                    self.proceedToChooseAccount()
                }
            })
        }
    }
    
    func openOAuth (url: URL, urlScheme: String) {
        
        self.buildASWebAuthenticationSession(url: url, callbackURL: urlScheme, completionHandler: { (url, error) in
            
            if let stringUrl = url?.absoluteString {
                let returnedEstablish = EstablishDataUtils.buildEstablishFrom(urlWithParameters: stringUrl)

                self.returnHandler?(returnedEstablish)

            } else {
                self.cancelHandler?([:])

            }
        })
    }
    
    private func checkUrl(host: String) -> Bool {
        
        for url in Constants.baseUrls {
            if host.contains(url) {
                return true
            }
        }
        
        return false
    }

    // MARK: - Oauth autenthication
    private func buildASWebAuthenticationSession(url: URL, callbackURL: String, completionHandler: @escaping (_ url: URL?, _ error: Error?) -> Void){
        
        webSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURL, completionHandler: { (url, error) in
            completionHandler(url, error)
        })
        
        if #available(iOS 13, *) {
            webSession.prefersEphemeralWebBrowserSession = true
            webSession.presentationContextProvider = self
        }

        webSession.start()
    }
    
    private func proceedToChooseAccount(){
        self.mainWebView.evaluateJavaScript("window.Trustly.proceedToChooseAccount();", completionHandler: nil)
    }
}

// MARK: - Utility Functions
extension WebViewManager{
    
    private func createNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(closeWebview), name: .trustlyCloseWebview, object: nil)
    }
    
    @objc func closeWebview(notification: Notification){
        
        NotificationCenter.default.removeObserver(self, name: .trustlyCloseWebview, object: nil)
        
        if webSession != nil {
            webSession.cancel()
        }

        self.proceedToChooseAccount()
    }
    
    //Utility Functions
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
}

extension Notification.Name{
    @available(iOS 12.0, *)
    public static let trustlyCloseWebview = Notification.Name(Constants.trustlyCloseWebview)
}
