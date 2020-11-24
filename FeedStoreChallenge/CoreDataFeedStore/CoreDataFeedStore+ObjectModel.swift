//
//  Model.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/24.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData
import Foundation

func CoreDataFeedStoreObjectModel() -> NSManagedObjectModel {
    let m = NSManagedObjectModel()
    let feed = feedEntity()
    let cache = cacheEntity(entity: feed)
    m.entities = [
        cache,
        feed,
    ]
    return m
}

private func cacheEntity(entity destinationEntity: NSEntityDescription) -> NSEntityDescription {
    entity(name: "ManagedCache", propertys: [
        property(name: "timestamp", attributeType: .dateAttributeType),

        relation(name: "feed", isOrdered: true, destinationEntity: destinationEntity),
    ])
}

private func feedEntity() -> NSEntityDescription {
    entity(name: "ManagedFeedImage",
           propertys: [
               property(name: "id", attributeType: .UUIDAttributeType),
               property(name: "imageDescription", isOptional: true, attributeType: .stringAttributeType),
               property(name: "location", isOptional: true, attributeType: .stringAttributeType),
               property(name: "url", attributeType: .URIAttributeType),
           ])
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
    relation.destinationEntity = destinationEntity
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
    usesScalarValueType _: Bool = false
) -> NSPropertyDescription {
    let p = NSAttributeDescription()
    p.name = name
    p.isOptional = isOptional
    p.attributeType = attributeType
    return p
}
