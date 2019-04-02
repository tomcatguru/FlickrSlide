//
//  String+Extension.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 27..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import Foundation

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {
            return self
        }

        return String(self.dropFirst(prefix.count))
    }
}
