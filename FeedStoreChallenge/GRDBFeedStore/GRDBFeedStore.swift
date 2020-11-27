
//  GRDBFeedStore.swift
//  FeedStoreChallenge
//
//  Created by 游宗諭 on 2020/11/27.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
public class GRDBFeedStore: FeedStore {
    public init() {
        
    }
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    
}
