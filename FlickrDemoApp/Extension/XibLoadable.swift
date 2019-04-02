//
//  XibLoadable.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 27..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import Foundation

public protocol XibLoadable: class {
    static var xibId: String { get }
}

public extension XibLoadable {
    static var xibId: String {
        return String(describing: self)
    }

    var xibId: String {
        return String(describing: type(of: self))
    }
}
