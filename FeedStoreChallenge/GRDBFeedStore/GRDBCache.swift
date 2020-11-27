//
//  GRDBCache.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/27.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import GRDB

struct GRDBCache: Codable {
    /// timestamp in GRDB in save as Double, whitch missing some float point
    /// 123.456789 is save as 123.456, lost 0.000789
    var timestamp: Double
    fileprivate(set) var id: Int64 = 0
}
extension GRDBCache: TableRecord,  FetchableRecord, MutablePersistableRecord {
    static let feeds = hasMany(GRDBFeedImage.self)
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
