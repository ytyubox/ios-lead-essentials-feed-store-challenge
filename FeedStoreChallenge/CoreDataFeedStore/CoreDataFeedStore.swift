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
public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private lazy var context: NSManagedObjectContext = container.newBackgroundContext()
    public init(url: URL) {
        let model = CoreDataFeedStoreObjectModel()
        container = NSPersistentContainer(name: MODELNAME, managedObjectModel: model)
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
            try! context.fetch(ManagedCache.self)
                .map(context.delete)
                .map(context.save)
            completion(nil)
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform { [self, context] in
            do {
                try context.fetch(ManagedCache.self).map(context.delete)
                createManagedCache(with: (feed, timestamp), in: context)
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
    
    private func createManagedCache(with data: (feed: [LocalFeedImage], timestamp: Date), in context: NSManagedObjectContext) {
        
        _ = ManagedCache(timestamp: data.timestamp, feed: data.feed, in: context)
        
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
