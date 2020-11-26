//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/23.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData
import Foundation
private let MODELNAME = "CoreDataFeedStore"
private let MODEL = CoreDataFeedStoreObjectModel()
public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private lazy var context: NSManagedObjectContext = container.newBackgroundContext()
    public init(url: URL) {
        container = NSPersistentContainer(name: MODELNAME, managedObjectModel: MODEL)
        container.persistentStoreDescriptions = [coreDataStoreDescription(url: url)]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Development mistake: Persistent store load failure: \(error)")
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform {
            [context] in
            do {
                try context.deleteManagedCache()
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform {
            [context] in
            do {
                try context.deleteManagedCache()
                _ = context.createManagedCache(feed: feed, timestamp: timestamp)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = container.newBackgroundContext()
        context.perform {
            [context] in

            do {
                completion(
                    try context.fetch(ManagedCache.self)
                        .map{
                            cache in
                            .found(feed: cache.managedFeeds.map(\.model), timestamp: cache.timestamp)
                        } ?? .empty
                )
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}
private
extension NSManagedObjectContext {
    func deleteManagedCache() throws {
        try fetch(ManagedCache.self).map(delete)
    }
    func createManagedCache(feed: [LocalFeedImage], timestamp: Date) -> ManagedCache {
        ManagedCache(feed: feed, timestamp: timestamp, in: self)
    }
}
private func coreDataStoreDescription(url: URL) -> NSPersistentStoreDescription {
    let description = NSPersistentStoreDescription(url: url)
    description.shouldAddStoreAsynchronously = false
    return description

}
private extension ManagedCache {
    var managedFeeds: [ManagedFeedImage] {
        feed.compactMap {
            $0 as? ManagedFeedImage
        }
    }
}

private extension ManagedFeedImage {
    var model: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
