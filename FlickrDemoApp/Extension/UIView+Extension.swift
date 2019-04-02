//
//  UIView+Extension.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 28..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var insets: UIEdgeInsets {
        var edgeInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            edgeInsets = self.safeAreaInsets
        }
        
        return edgeInsets
    }
    
    func fadeIn(_ duration: TimeInterval? = 0.2, completion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration!, animations: {
            self.alpha = 1
        }, completion: { (value: Bool) in
            if let completionHandler = completion {
                completionHandler()
            }
        })
    }

    func fadeOut(_ duration: TimeInterval? = 0.2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!, animations: {
            self.alpha = 0
        }, completion: { (value: Bool)   in
            self.isHidden = true
            if let completionHandler = completion {
                completionHandler()
            }
        })
    }
}
