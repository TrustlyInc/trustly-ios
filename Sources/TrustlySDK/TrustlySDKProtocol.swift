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
import Foundation

public protocol TrustlySDKProtocol: AnyObject {
    /*!
        @brief Sets a callback to handle external URLs
        @param onExternalUrl Called when the TrustlySDK panel must open an external URL. If not handled an internal in app WebView will show the external URL.The external URL is sent on the returnParameters entry key “url”.
    */
    func onExternalUrl(onExternalUrl: TrustlyViewCallback?) -> Void;
    
    /*!
        @brief Sets a callback to handle event triggered by javascript
        @param eventName Name of the event.
        @param eventDetails Dictionary with information about the event.
    */
    func onChangeListener(_ eventName: String, _ eventDetails: [AnyHashable : Any]) -> Void;
    
    /*!
        @brief Sets a callback to handle event triggered by javascript
        @param data Establish data values.
    */
    func onBankSelected(data: [AnyHashable : Any]);
    
    /*!
        @brief Sets a callback to handle event triggered by javascript
        @param data Establish data values.
    */
    func onReturn(_ returnParameters: [AnyHashable : Any]) -> Void;
    
    /*!
        @brief Sets a callback to handle event triggered by javascript
        @param data Establish data values.
    */
    func onCancel(_ returnParameters: [AnyHashable : Any]) -> Void;
}
