//
//  ManagedFeedImage+CoreDataClass.swift
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

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    static func entityDescription() -> NSEntityDescription {
        FeedStoreChallenge.entity(name: "ManagedFeedImage",
               propertys: [
                property(name: "id", attributeType: .UUIDAttributeType),
                property(name: "imageDescription", isOptional: true, attributeType: .stringAttributeType),
                property(name: "location", isOptional: true, attributeType: .stringAttributeType),
                property(name: "url", attributeType: .URIAttributeType),
               ])
    }
    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedFeedImage> {
        return NSFetchRequest<ManagedFeedImage>(entityName: "ManagedFeedImage")
    }
    class func managedFeeds(with feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array:
        feed.map { [context] feedImage in
            let coreDataFeedImage = ManagedFeedImage(context: context)
            coreDataFeedImage.id = feedImage.id
            coreDataFeedImage.imageDescription = feedImage.description
            coreDataFeedImage.location = feedImage.location
            coreDataFeedImage.url = feedImage.url
            return coreDataFeedImage
            }
        )
    }

    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache?
}

extension ManagedFeedImage: Identifiable {}

