//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/23.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData
private let MODELNAME = "CoreDataFeedStore"
public class CoreDataFeedStore: FeedStore {
    typealias Object = ManagedCache
    private let container: NSPersistentContainer
    private lazy var context: NSManagedObjectContext = container.newBackgroundContext()
    public init(url: URL) {
        let model = CoreDataFeedStoreObjectModel()
        container = InnerContainer(name: MODELNAME, managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: url)
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (_, error) in
            if let error = error {
            fatalError("Development mistake: Persistent store load failure: \(error)")
            }
        }
    }
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
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
                if let cache = try  ManagedCache.fetch(with: context) {
                    completion(.found(feed: cache.managedFeeds.map(\.model), timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Inner
    private class InnerContainer: NSPersistentContainer{
        override class func defaultDirectoryURL() -> URL {
            super.defaultDirectoryURL().appendingPathComponent("CoreDataFeedStore")
        }
    }
}

extension ManagedCache {
    var managedFeeds:[ManagedFeedImage] {
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
// MARK: - Model relation
private func CoreDataFeedStoreObjectModel() -> NSManagedObjectModel {
    let m = NSManagedObjectModel()
    let feed = feedEntity()
    let cache = cacheEntity(entity: feed)
    m.entities = [cache, feed]
    return m
}

private func cacheEntity(entity destinationEntity: NSEntityDescription) -> NSEntityDescription{
     entity(name: "ManagedCache", propertys: [
        property(name:"timestamp", attributeType: .dateAttributeType),
    
        relation(name: "feed", isOrdered: true, destinationEntity: destinationEntity)
    ])
}

private func feedEntity() -> NSEntityDescription {
    entity(name: "ManagedFeedImage",
           propertys: [
            property(name:"id", attributeType: .UUIDAttributeType),
            property(name:"imageDescription", isOptional: true, attributeType: .stringAttributeType),
            property(name:"location", isOptional:true, attributeType: .stringAttributeType),
            property(name:"url", attributeType: .URIAttributeType)
           ]
    )
}
private func entity(name: String, propertys: [NSPropertyDescription]) -> NSEntityDescription {
    let entity = NSEntityDescription()
    entity.name = name
    entity.managedObjectClassName = name
    entity.properties = propertys
    return entity
}
private func relation(
    name: String,
    isOrdered: Bool,
    destinationEntity: NSEntityDescription
) -> NSPropertyDescription {
    let relation = NSRelationshipDescription()
    relation.name = name
    relation.destinationEntity =     destinationEntity
    relation.isOrdered = isOrdered
    relation.minCount = 0
    relation.maxCount = 0
    relation.deleteRule = .cascadeDeleteRule
    return relation
}
private func property(
    name: String,
    isOptional: Bool = false,
    attributeType: NSAttributeType,
    usesScalarValueType: Bool = false
) -> NSPropertyDescription {
    let p = NSAttributeDescription()
    p.name = name
    p.isOptional = isOptional
    p.attributeType = attributeType
    return p
}

