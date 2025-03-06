/*  ___________________________________________________________________________________________________________
 *
 *    TRUSTLY CONFIDENTIAL AND PROPRIETARY INFORMATION
 *  ___________________________________________________________________________________________________________
 *
 *      Copyright (c) 2012 - 2020 Trustly
 *      All Rights Reserved.
 *
 *   NOTICE:  All information contained herein is, and remains, the confidential and proprietary property of
 *   Trustly and its suppliers, if any. The intellectual and technical concepts contained herein are the
 *   confidential and proprietary property of Trustly and its suppliers and  may be covered by U.S. and
 *   Foreign Patents, patents in process, and are protected by trade secret or copyright law. Dissemination of
 *   this information or reproduction of this material is strictly forbidden unless prior written permission is
 *   obtained from Trustly.
 *   ___________________________________________________________________________________________________________
*/
import UIKit
@preconcurrency import WebKit
import AuthenticationServices
import SafariServices

public typealias TrustlyViewCallback = (_ returnParameters: [AnyHashable : Any]) -> Void;
public typealias TrustlyListenerCallback = (_ eventName: String, _ eventDetails: [AnyHashable : Any]) -> Void;

protocol TrustlyViewProtocol {
    func selectBankWidget(establishData: [AnyHashable : Any], onBankSelected: @escaping TrustlyViewCallback) -> UIView;
}

func Rgb2UIColor(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}

let WidgetView:Int = 100
    
@available(iOS 12.0, *)
class TrustlyView : UIView, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {

//    public var navBarColor:UIColor!
//    public var navBarButtonColor:UIColor!
//    public var navBarTitleColor:UIColor!
//    public var navBarSubtitleColor:UIColor!
    private let inAppIntegrationContext = "InAppBrowser"
    private var returnHandler:TrustlyViewCallback?
    private var cancelHandler:TrustlyViewCallback?
    private var externalUrlHandler:TrustlyViewCallback?
    private var bankSelectedHandler:TrustlyViewCallback?
    private var changeListenerHandler:TrustlyListenerCallback?
    private var establishData:[AnyHashable : Any]?
    private var mainWebView:WKWebView!
    private var returnUrl = Constants.returnURL
    private var cancelUrl = Constants.cancelURL
    private var urlScheme = ""
    private var webSession: ASWebAuthenticationSession!
    private var baseUrls = ["paywithmybank.com", "trustly.one"]
    private let oauthLoginPath = "/oauth/login/"
    private var sessionCid = "ios wrong sessionCid"
    private var cid = "ios wrong cid"
    private var isLocalEnvironment = false
    private var trustlySettings: TrustlySettings? = nil
    private var loading: UIActivityIndicatorView = {

        let indicator = UIActivityIndicatorView()
        
        indicator.autoresizingMask = [
            .flexibleLeftMargin, .flexibleRightMargin,
            .flexibleTopMargin, .flexibleBottomMargin
        ]
        
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        
        if #available(iOS 13.0, *) {
            indicator.style = .large
        } else {
            indicator.style = .gray
        }
        
        indicator.startAnimating()
        
        return indicator
    }()

    
    //Constructors

    override init(frame:CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    

    private func notifyListener(_ eventName:String!, _ eventDetails:[AnyHashable : Any]!) {
        if(changeListenerHandler != nil) {
            changeListenerHandler!(eventName, eventDetails)
        }
    }

    func initView() {
        
        if let tempCid = generateCid() {
            cid = tempCid
            sessionCid = getOrCreateSessionCid(cid)
        }
        
//        self.navBarColor = Rgb2UIColor(254, 255, 254)
//        self.navBarButtonColor = Rgb2UIColor(109, 109, 109)
//        self.navBarTitleColor = Rgb2UIColor(0, 0, 0)
//        self.navBarSubtitleColor = Rgb2UIColor(51, 51, 51)

        let configuration = WKWebViewConfiguration()
        let userController = WKUserContentController()
        userController.add(self, name: "PayWithMyBankNativeSDK")
        configuration.userContentController = userController
        
        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        
        configuration.preferences = wkPreferences

        let frame = CGRect(x:0, y:0, width: self.frame.size.width, height: self.frame.size.height)
        mainWebView = WKWebView(frame:frame, configuration:configuration)
        mainWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainWebView.navigationDelegate = self
        mainWebView.uiDelegate = self
        mainWebView.scrollView.bounces = false
        mainWebView.backgroundColor = UIColor.clear
        mainWebView.isOpaque = false
        
        if #available(iOS 16.4, *) {
            mainWebView.isInspectable = true
        }

        addSubview(mainWebView)
    }

    //TrustlySDK Protocol
    public func verify(verifyData:[AnyHashable : Any], onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) -> UIView? {
        var mutableDictionary = verifyData
        mutableDictionary["paymentType"] = Constants.paymentTypeVerification
        
        return establish(establishData: mutableDictionary, onReturn:onReturn, onCancel:onCancel)
    }
    
    public func onExternalUrl(onExternalUrl: TrustlyViewCallback?) {
        self.externalUrlHandler = onExternalUrl
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

    //WKUIDelegate Protocol
    
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
    
    //WKUserContentController Protocol

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

    //WKNavigationDelegate Protocol
    
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

    func getGrp() -> String! {
        return getDefault(key: "Trustly.grp", def: generateGrp())
    }
    
    func getDefault(key:String, def: String) -> String{
        let userDefaults:UserDefaults = UserDefaults.standard
        var value = userDefaults.object(forKey: key) as? String
        if(value == nil){
            value = def
            userDefaults.set(value,forKey: key)
            userDefaults.synchronize()
        }
        return value ?? ""
    }

    func generateGrp() -> String! {
        var grp:String!
        let grpInt:Int = Int(arc4random_uniform(100))
        grp = String(format:"%d", grpInt)
        return grp
    }
    
    private func addSessionCid() {
        
        self.establishData?["sessionCid"] = sessionCid
        self.establishData?["metadata.cid"] = cid

    }
    
}

@available(iOS 12.0, *)
extension TrustlyView: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

@available(iOS 12.0, *)
extension TrustlyView {
    public static let trustlyCloseWebview = "trustly.close.webView"
    
    private func openOAuth(url: URL) {
        let host = url.host!
        let path = url.path
        
        //1.1: On the main view creates a new OAuth view (new WKWebview) and opens the URL there
        if self.isLocalEnvironment || (self.checkUrl(host: host) &&
            path.contains(self.oauthLoginPath)) {

            self.buildASWebAuthenticationSession(url: url, callbackURL: urlScheme)

        }
    }
    
    // MARK: - Oauth autenthication
    private func buildASWebAuthenticationSession(url: URL, callbackURL: String){
        webSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURL, completionHandler: { (url, error) in
            self.proceedToChooseAccount()
        })
        
        if #available(iOS 13, *) {
            webSession.prefersEphemeralWebBrowserSession = true
            webSession.presentationContextProvider = self
        }

        webSession.start()
    }
    
    private func buildASWebAuthenticationSession(url: URL, callbackURL: String, onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) {
        webSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURL, completionHandler: { (url, error) in
            if let stringUrl = url?.absoluteString {
                let returnedEstablish = EstablishDataUtils.buildEstablishFrom(urlWithParameters: stringUrl)
                
                onReturn?(returnedEstablish)
                
            } else {
                onCancel?([:])
            }
        })
        
        if #available(iOS 13, *) {
            webSession.prefersEphemeralWebBrowserSession = true
            webSession.presentationContextProvider = self
        }

        webSession.start()
    }

    private func proceedToChooseAccount(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.mainWebView.evaluateJavaScript("window.Trustly.proceedToChooseAccount();", completionHandler: nil)
        }
    }
    
    // MARK: - Utility Functions
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
    
    private func checkUrl(host: String) -> Bool {
        
        for url in self.baseUrls {
            if host.contains(url) {
                return true
            }
        }
        
        return false
    }
    
    private func startLoading() {
        self.loading.center = CGPoint(
            x: self.bounds.midX,
            y: self.bounds.midY
        )
        
        self.addSubview(self.loading)
    }

    private func stopLoading() {
        self.loading.stopAnimating()
    }
}

// MARK: Establish
extension TrustlyView {

    /** @abstract This function is responsible to open the lightbox, according to TrustlySettings service. If the context of the lightbox is `web view`, this function will
     return a UIView instance with a WebView embedded, in case the context valeu be `in-app-browser`, this function will return a empty UIView, andwill open the
     lightbox in an ASWebAuthentication instance.
     @param establishData eD: [AnyHashable : Any]
     @param onReturn: TrustlyCallback?
     @param onCancel: TrustlyCallback?
     */
    public func establish(establishData eD: [AnyHashable : Any], onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) -> UIView? {
        
        self.startLoading()
        
        self.prepareEstablish(establishData: eD)
        
        EstablishDataUtils.validateEstablishData(establishData: self.establishData ?? [:])
        
        DispatchQueue.global(qos: .background).async{
            
            if let establish = self.establishData {
                
                getTrustlySettingsWith(establish: establish) { trustlySettings in

                    if let settings = trustlySettings?.settings
                        , settings.integrationStrategy == Constants.lightboxContentInApp {
                        
                        DispatchQueue.main.async {
                            // Update the UI on the main thread
                            self.establishASWebAuthentication(onReturn: onReturn, onCancel: onCancel)
                        }
                        
                    } else {
                        self.establishWebView(onReturn: onReturn, onCancel: onCancel)
                    }
                }
            }
        }

        return self
    }

    private func establishWebView(onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) {
        
        if establishData?.index(forKey: "metadata.integrationContext") == nil {
            establishData?["metadata.integrationContext"] = inAppIntegrationContext
        }
        
        returnHandler = onReturn
        cancelHandler = onCancel
        externalUrlHandler = nil
        
        do {
            let environment = try buildEnvironment(
                resourceUrl: .index,
                environment: (establishData?["env"] ?? "") as! String,
                localUrl: (establishData?["envHost"] ?? "") as! String,
                paymentType: (establishData?["paymentType"] ?? "") as! String,
                build: Constants.buildSDK
            )
            
            isLocalEnvironment = environment.isLocal
            
            if let establish = establishData {
                
                loadLightbox(establish: establish, url: environment.url) { (data, response, error) in
                    DispatchQueue.main.async{
                        if(error == nil){
                            self.mainWebView?.load(data!, mimeType:"text/html", characterEncodingName:"UTF-8", baseURL: (response?.url)!)
                            self.stopLoading()
                            
                        } else {
                            self.cancelHandler!([:])
                            
                        }
                    }
                }
            }
            
        } catch NetworkError.invalidUrl {
            print("Error: Invalid url.")
            
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    private func establishASWebAuthentication(onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) {
         
         if let scheme = establishData?["metadata.urlScheme"] as? String {
             self.urlScheme = scheme.components(separatedBy: ":")[0]
             establishData?["returnUrl"] = scheme
             establishData?["cancelUrl"] = scheme
         }
        
        do {
            let environment = try buildEnvironment(
                resourceUrl: .establish,
                environment: (establishData?["env"] ?? "") as! String,
                localUrl: (establishData?["envHost"] ?? "") as! String,
                paymentType: (establishData?["paymentType"] ?? "") as! String,
                build: Constants.buildSDK,
                path: .mobile
            )
            
            isLocalEnvironment = environment.isLocal
            
            var url = environment.url.absoluteString
            
            let normalizedEstablish:[String : AnyHashable] = EstablishDataUtils.normalizeEstablishWithDotNotation(establish: establishData as! [String : AnyHashable])
            
            if let token = JSONUtils.getJsonBase64From(dictionary: normalizedEstablish) {

                url = "\(url)?token=\(token)"

                self.buildASWebAuthenticationSession(url: URL(string: url)!, callbackURL: urlScheme, onReturn: onReturn, onCancel: onCancel)
                
                self.stopLoading()
            }
            
        } catch NetworkError.invalidUrl {
            print("Error: Invalid url.")
            
        } catch {
            print("Error: building url.")
        }

     }
    
    private func prepareEstablish(establishData eD: [AnyHashable : Any]) {
        establishData = eD
        
        self.addSessionCid()

        let deviceType = "\(establishData?["deviceType"] ?? Constants.deviceType):\(Constants.devicePlatform)"
        establishData?["deviceType"] = deviceType
        
        if let lang = establishData?["metadata.lang"] as? String {
            establishData?["lang"] = lang
        }
        
        establishData?["metadata.sdkIOSVersion"] = Constants.buildSDK
        
        returnUrl = Constants.returnURL
        establishData?["returnUrl"] = returnUrl
        cancelUrl = Constants.cancelURL
        establishData?["cancelUrl"] = cancelUrl
        establishData?["version"] = Constants.establishVersion
        establishData?["grp"] = self.getGrp()

        if establishData?["paymentProviderId"] != nil {
            establishData?["widgetLoaded"] = "true"
        }
        
        if let scheme = establishData?["metadata.urlScheme"] as? String {
            self.urlScheme = scheme.components(separatedBy: ":")[0]
        }
        
    }
}

// MARK: widget implemetation
extension TrustlyView: TrustlyViewProtocol {
    public func selectBankWidget(establishData eD:[AnyHashable : Any], onBankSelected: @escaping TrustlyViewCallback) -> UIView {
        establishData = eD
        
        self.addSessionCid()
        
        var query = [String : Any]()
        var hash = [String : Any]()
        
        let deviceType = establishData?["deviceType"] ?? "mobile" + ":ios:native"
        query["deviceType"] = deviceType
        
        if let lang = establishData?["metadata.lang"] as? String {
            query["lang"] = lang
        }

        query["onlinePPSubType"] = establishData?["onlinePPSubType"]
        query["accessId"] = establishData?["accessId"]
        query["merchantId"] = establishData?["merchantId"]
        query["paymentType"] = establishData?["paymentType"] ?? "Instant"
        query["deviceType"] = deviceType
        query["grp"] = self.getGrp()
        query["dynamicWidget"] = "true"
        query["sessionCid"] = sessionCid
        query["cid"] = cid
        
        if establishData?["customer.address.country"] != nil {
            query["customer.address.country"]=establishData?["customer.address.country"]
        }
        
        if (establishData?["customer.address.country"] == nil || establishData?["customer.address.country"] as! String == "us") &&
            establishData?["customer.address.state"] != nil{
            query["customer.address.state"]=establishData?["customer.address.state"]
        }
        
        hash["merchantReference"] = establishData?["merchantReference"] ?? ""
        hash["customer.externalId"] = establishData?["customer.externalId"] ?? ""
        
        bankSelectedHandler = onBankSelected

        do {
            let environment = try buildEnvironment(
                resourceUrl: .widget,
                environment: (eD["env"] ?? "") as! String,
                localUrl: (eD["envHost"] ?? "") as! String,
                paymentType: (eD["paymentType"] ?? "") as! String,
                build: Constants.buildSDK,
                query: query,
                hash: hash
            )
            
            isLocalEnvironment = environment.isLocal
            
            var request = URLRequest(url: environment.url)
            request.httpMethod = "GET"
            request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField:"Accept")

            self.notifyEvent("widget", "loading")

            self.mainWebView!.tag = WidgetView
            self.mainWebView!.load(request)
            
        } catch NetworkError.invalidUrl {
            print("Error: Invalid url.")
            
        } catch {
            print("Unexpected error: \(error).")
        }
        
        return self
    }
}

extension Notification.Name{
    @available(iOS 12.0, *)
    static let trustlyCloseWebview = Notification.Name(TrustlyView.trustlyCloseWebview)
}
