//
//  ShareViewController.swift
//  Share
//
//  Created by 홍승아 on 2021/03/07.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    // Text가 입력될 때마다 호출
    override func isContentValid() -> Bool {
        
        return self.contentText.isEmpty == false
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
