//
//  GRDBFeedDataBase.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/12/3.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import GRDB
public protocol DBQueueManager {
    func makeQueue(path: String?) throws -> DatabaseQueue
    func recylcle(queue: DatabaseQueue)
}

public class DBQueueFactory: DBQueueManager {
    public init() {}
    private var pool:[String?: (count:Int,dbQueue: DatabaseQueue)] = [:]
    public func makeQueue(path: String?) throws -> DatabaseQueue {
        if let (count, dbQueue) = pool[path] {
           pool[path] = (count + 1, dbQueue)
            return dbQueue
        }
        let config = feedImageConfiguration()
        let dbQueue = DatabaseQueue(configuration: config)
        let migrator = feedImageMigrator()
        try migrator.migrate(dbQueue)
        pool[path] = (1, dbQueue)
        return dbQueue
    }
    public func recylcle(queue: DatabaseQueue) {
        for (path, pair) in pool where queue === pair.dbQueue {
            if pair.count == 1 {
                pool[path] = nil
            } else {
                pool[path] = (pair.count - 1, queue)
            }
        }
    }
    
    
    
    private func feedImageConfiguration() -> Configuration {
        var config = Configuration()
        config.prepareDatabase { (db) in
            //        db.trace {print("SQL>",$0)}
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
                t.autoIncrementedPrimaryKey("feedImage_id")
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
    
}
