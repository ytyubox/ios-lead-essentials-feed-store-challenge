//
//  CoreData+FetchHelper.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/25.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import CoreData
protocol Named {
   static var name: String {get}
}

protocol FetchRequestWithType: Named where Self: NSManagedObject {
    static
    func fetchRequestWithType() -> NSFetchRequest<Self>
}

extension FetchRequestWithType {
    static
    func fetchRequestWithType() -> NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: name)
    }
}

extension NSManagedObjectContext {
    func fetch<Fetchable:FetchRequestWithType>(_ object: Fetchable.Type) throws -> Fetchable? {
        let request = object.fetchRequestWithType()
        request.returnsObjectsAsFaults = false
        return try fetch(request).first
    }
}
