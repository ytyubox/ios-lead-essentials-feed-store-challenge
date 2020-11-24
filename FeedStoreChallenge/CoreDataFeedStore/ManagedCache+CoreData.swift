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
public final class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    convenience init (timestamp: Date, feed: [LocalFeedImage], in context: NSManagedObjectContext)  {
        self.init(context: context)
        self.feed = NSOrderedSet(array: feed.map{ManagedFeedImage(with: $0, in: context)})
        self.timestamp = timestamp
    }
}


extension ManagedCache: Identifiable {}
extension ManagedCache: FetchRequestWithType {
    static var name: String {"ManagedCache"}
    static func entityDescription(
        destinationEntity: NSEntityDescription) -> NSEntityDescription {
        FeedStoreChallenge.entity(name: Self.name, propertys: [
            property(name: "timestamp", attributeType: .dateAttributeType),
            relation(name: "feed", isOrdered: true, destinationEntity: destinationEntity),
        ])
    }
}
