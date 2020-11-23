//
//  ManagedCache+CoreDataClass.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/23.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

/**
 * This file is auto generate by Xcode
 * FroCoreDataFeedStore.xcdatamodeld
 * by XCode.app -> Editor -> Create NSManagedObject Subclass...
 */

import CoreData
import Foundation

@objc(ManagedCache)
public class ManagedCache: NSManagedObject {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }
    
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    class func createUniqueInstance(with data: (feed: [LocalFeedImage], timestamp: Date), in context: NSManagedObjectContext) throws {
        try fetch(with: context).map(context.delete)
        let coreDataFeedImages = ManagedFeedImage.managedFeeds(with: data.feed, in: context)
        let cache = ManagedCache(context: context)
        cache.feed = coreDataFeedImages
        cache.timestamp = data.timestamp
    }
    @nonobjc class func fetchRequestWithType() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }
    class func fetch(with context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = ManagedCache.fetchRequestWithType()
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}


extension ManagedCache: Identifiable {}
