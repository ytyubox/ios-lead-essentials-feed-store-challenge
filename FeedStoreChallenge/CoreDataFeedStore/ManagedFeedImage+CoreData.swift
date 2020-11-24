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
final class ManagedFeedImage: NSManagedObject {
    convenience init(with feedImage: LocalFeedImage, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = feedImage.id
        self.imageDescription = feedImage.description
        self.location = feedImage.location
        self.url = feedImage.url
        
    }

    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache?
}

extension ManagedFeedImage: Identifiable {}
extension ManagedFeedImage: Named {
    static var name: String {"ManagedFeedImage"}
    static func entityDescription() -> NSEntityDescription {
        FeedStoreChallenge.entity(name: name,
                                  propertys: [
                                    property(name: "id", attributeType: .UUIDAttributeType),
                                    property(name: "imageDescription", isOptional: true, attributeType: .stringAttributeType),
                                    property(name: "location", isOptional: true, attributeType: .stringAttributeType),
                                    property(name: "url", attributeType: .URIAttributeType),
                                  ])
    }
}
