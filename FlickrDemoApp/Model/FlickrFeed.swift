//
//  FlickrFeed.swift
//  FlickrDemoApp
//
//  Created by Lee Kanghee on 2019. 3. 27..
//  Copyright © 2019년 Lee Kanghee. All rights reserved.
//

import Foundation

struct ImageItem: Decodable {
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case mobileImageURL = "m"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        imageURL = try values.decodeIfPresent(String.self, forKey: .mobileImageURL)
    }
}

struct FlickrFeedItem: Decodable {
    let title: String?
    let link: String?
    let media: ImageItem?
    let dateTaken: String?
    let description: String?
    let published: String?
    let author: String?
    let authorID: String?
    let tags: String?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case link = "link"
        case media = "media"
        case dateTaken = "date_taken"
        case description = "description"
        case published = "published"
        case author = "author"
        case authorID = "author_id"
        case tags = "tags"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        media = try values.decodeIfPresent(ImageItem.self, forKey: .media)
        dateTaken = try values.decodeIfPresent(String.self, forKey: .dateTaken)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        published = try values.decodeIfPresent(String.self, forKey: .published)
        author = try values.decodeIfPresent(String.self, forKey: .author)
        authorID = try values.decodeIfPresent(String.self, forKey: .authorID)
        tags = try values.decodeIfPresent(String.self, forKey: .tags)
    }
    
    var imageURL: String? {
        return self.media?.imageURL
    }
}

struct FlickrFeed: Decodable {
    let title: String?
    let link: String?
    let description: String?
    let modified: String?
    let generator: String?
    let items: [FlickrFeedItem]?

    enum CodingKeys: String, CodingKey {
        case title
        case link
        case description
        case modified
        case generator
        case items
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        modified = try values.decodeIfPresent(String.self, forKey: .modified)
        generator = try values.decodeIfPresent(String.self, forKey: .generator)
        items = try values.decodeIfPresent([FlickrFeedItem].self, forKey: .items)
    }
}
