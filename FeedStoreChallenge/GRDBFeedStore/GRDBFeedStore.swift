
//  GRDBFeedStore.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/27.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import GRDB



import GRDB
public class GRDBFeedStore: FeedStore {
    let dbQueue: DatabaseQueue
    public init() throws {
        let config = feedImageConfiguration()
        dbQueue = DatabaseQueue(configuration: config)
        let migrator = feedImageMigrator()
        try migrator.migrate(dbQueue)
    }
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        try? dbQueue.write({ (db) in
            var cache = GRDBCache(timestamp: timestamp.timeIntervalSince1970)
            try cache.insert(db)
            var feeds = feed.map(GRDBFeedImage.init)
            for i in feeds.indices {
                feeds[i].cache_id = cache.id
                try feeds[i].insert(db)
            }
            
            completion(nil)
        })
        
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            try dbQueue.read({ (db) -> Void in
                guard let cache = try GRDBCache
                        .all()
                        .fetchOne(db)
                else { return completion(.empty)}
                let feed = try GRDBFeedImage
                    .all()
                    .fetchAll(db)
                    .map(localFeed(_:))
                completion(.found(feed: feed, timestamp: Date(timeIntervalSince1970: cache.timestamp)))
            })
        } catch {
            completion(.failure(error))
        }
    }
    
    
}

private func feedImageConfiguration() -> Configuration {
    var config = Configuration()
    config.prepareDatabase { (db) in
        db.trace {print("SQL>",$0)}
    }
    return config
}
private func feedImageMigrator() -> DatabaseMigrator {
    var migrator = DatabaseMigrator()
    migrator.registerMigration("createFeedStore") {
        db in
        try db.create(table: "grdbCache", body: { (t) in
            t.autoIncrementedPrimaryKey("id")
            t.column("timestamp", .date).notNull()
        })
        try db.create(table: "grdbFeedimage", body: { (t) in
            t.column("id", .text).notNull()
            t.column("imageDescription", .text)
            t.column("location", .text)
            t.column("url", .text).notNull()
            t.column("cache_id", .integer)
                .notNull()
                .references("grdbCache")
        })
    }
    return migrator
}

private extension GRDBFeedImage {
    init(localFeedImage: LocalFeedImage) {
        self.id = localFeedImage.id
        self.imageDescription = localFeedImage.description
        self.location = localFeedImage.location
        self.url = localFeedImage.url
    }
}
private func localFeed(_ f: GRDBFeedImage) -> LocalFeedImage {
    LocalFeedImage(id: f.id, description: f.imageDescription, location: f.location, url: f.url)
}
