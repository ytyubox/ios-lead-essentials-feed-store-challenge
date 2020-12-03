
//  GRDBFeedStore.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/27.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import GRDB



public class GRDBFeedStore: FeedStore {
    
    internal let dbQueue: DatabaseQueue
    private var dbManeger: DBQueueManager
    
    public init(path: String?, dbManeger: DBQueueManager) throws {
        self.dbManeger = dbManeger
        dbQueue = try dbManeger.makeQueue(path: path)
    }
    deinit {
        dbManeger.recylcle(queue: dbQueue)
    }
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        try? dbQueue.write({ (db) in
            try GRDBFeedImage.deleteAll(db)
            try GRDBCache.deleteAll(db)
            completion(nil)
        })
    }
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        var cache = GRDBCache(timestamp: timestamp.timeIntervalSinceReferenceDate)
        var feeds = feed.map(GRDBFeedImage.init)
        do {
            try dbQueue.write({ (db) in
                try GRDBFeedImage.deleteAll(db)
                try GRDBCache.deleteAll(db)
                try cache.insert(db)
                for i in feeds.indices {
                    feeds[i].cache_id = cache.id
                    try feeds[i].insert(db)
                }
                
                completion(nil)
            })
        } catch {
            completion(error)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        do {
            try dbQueue.read({ (db) -> Void in
                guard let cache = try GRDBCache
                        .all()
                        .fetchOne(db)
                else {
                    return completion(.empty)
                }
                let feed = try GRDBFeedImage
                    .all()
                    .fetchAll(db)
                    .map(localFeed(_:))
                completion(.found(feed: feed, timestamp: Date(timeIntervalSinceReferenceDate: cache.timestamp)))
            })
        } catch {
            completion(.failure(error))
        }
    }
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
