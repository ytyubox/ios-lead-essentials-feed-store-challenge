//
//  GRDBFeedImage.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/27.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import GRDB
struct GRDBFeedImage: Codable {
    internal init(id: UUID, imageDescription: String? = nil, location: String? = nil, url: URL) {
        self.id = id
        self.imageDescription = imageDescription
        self.location = location
        self.url = url
    }
    
    var id: UUID
    var imageDescription: String?
    var location: String?
    var url: URL
    var cache_id: Int64? = nil
    var feedImage_id: Int64? = nil
}
extension GRDBFeedImage: TableRecord, FetchableRecord, MutablePersistableRecord {
    static let cache = belongsTo(GRDBCache.self)
    mutating func didInsert(with rowID: Int64, for column: String?) {
        feedImage_id = rowID
    }
}
