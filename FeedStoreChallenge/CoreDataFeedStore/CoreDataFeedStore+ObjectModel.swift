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
    let feed = ManagedFeedImage.entityDescription()
    let cache = ManagedCache.entityDescription(destinationEntity: feed)
    m.entities = [
        cache,
        feed,
    ]
    return m
}

// MARK: - Model description helpers
func entity(name: String, propertys: [NSPropertyDescription]) -> NSEntityDescription {
    let entity = NSEntityDescription()
    entity.name = name
    entity.managedObjectClassName = name
    entity.properties = propertys
    return entity
}
func relation(
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

func property(
    name: String,
    isOptional: Bool = false,
    attributeType: NSAttributeType 
) -> NSPropertyDescription {
    let p = NSAttributeDescription()
    p.name = name
    p.isOptional = isOptional
    p.attributeType = attributeType
    return p
}
