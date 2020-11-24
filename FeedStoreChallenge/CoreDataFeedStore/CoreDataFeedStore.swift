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
    typealias Object = ManagedCache
    private let container: NSPersistentContainer
    private lazy var context: NSManagedObjectContext = container.newBackgroundContext()
    public init(url: URL) {
        let model = CoreDataFeedStoreObjectModel()
        container = NSPersistentContainer(name: MODELNAME, managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: url)
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Development mistake: Persistent store load failure: \(error)")
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform {
            completion(nil)
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform { [context] in
            do {
                try ManagedCache.createUniqueInstance(with: (feed, timestamp), in: context)

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
                if let cache = try ManagedCache.fetch(with: context) {
                    completion(.found(feed: cache.managedFeeds.map(\.model), timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

}

extension ManagedCache {
    var managedFeeds: [ManagedFeedImage] {
        feed.compactMap {
            $0 as? ManagedFeedImage
        }
    }
}

extension ManagedFeedImage {
    var model: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
