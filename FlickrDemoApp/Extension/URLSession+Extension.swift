//
//  URLSession+Extension.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 27..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import Foundation

extension URLSession {
    func decodeableTask<T: Decodable>(with url: URL,
                                      completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }

            completionHandler(try? JSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func requestFlickerFeed(with url: URL,
                    completionHandler: @escaping (FlickrFeed?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.decodeableTask(with: url, completionHandler: completionHandler)
    }
}
