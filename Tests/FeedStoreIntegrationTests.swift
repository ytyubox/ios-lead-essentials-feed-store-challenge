//
//  FeedStoreIntegrationTests.swift
//  Tests
//
//  Created by Caio Zullo on 01/09/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreIntegrationTests: XCTestCase {

    //  ***********************
    //
    //  Uncomment and implement the following tests if your
    //  implementation persists data to disk (e.g., CoreData/Realm)
    //
    //  ***********************
    
    override func setUp() {
        super.setUp()
     
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT(dbQueueManager: DBQueueFactory())

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_deliversFeedInsertedOnAnotherInstance() {
        let manager = DBQueueFactory()
        let storeToInsert = makeSUT(dbQueueManager: manager)
        let storeToLoad = makeSUT(dbQueueManager: manager)
        let feed = uniqueImageFeed()
        let timestamp = Date()
        XCTAssertNil(insert((feed, timestamp), to: storeToInsert))

        expect(storeToLoad, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
   
    func test_insert_overridesFeedInsertedOnAnotherInstance() {
        let manager = DBQueueFactory()
        let storeToInsert = makeSUT(dbQueueManager:  manager)
        let storeToOverride = makeSUT(dbQueueManager: manager)
        let storeToLoad = makeSUT(dbQueueManager: manager)

        insert((uniqueImageFeed(), Date()), to: storeToInsert)

        let latestFeed = uniqueImageFeed()
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: storeToOverride)

        expect(storeToLoad, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_delete_deletesFeedInsertedOnAnotherInstance() {
//        let storeToInsert = makeSUT()
//        let storeToDelete = makeSUT()
//        let storeToLoad = makeSUT()
//
//        insert((uniqueImageFeed(), Date()), to: storeToInsert)
//
//        deleteCache(from: storeToDelete)
//
//        expect(storeToLoad, toRetrieve: .empty)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(dbQueueManager: DBQueueManager, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = try! GRDBFeedStore(path: testSpecificStoreURL().path, dbManeger: dbQueueManager)
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, file: file, line: line)
        }
        return sut
    }
    private func testSpecificStoreURL() throws -> URL {
        try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
    }
    
    private func setupEmptyStoreState() {
        try? removeTestPersistenceState()
    }

    private func undoStoreSideEffects() {
        try? removeTestPersistenceState()
    }
    
    private func removeTestPersistenceState() throws {
        try FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
@testable import FeedStoreChallenge
extension FeedStoreIntegrationTests {
    func test_DatabaseQueueWillReleaseAfterAllDependentedFeedStoreRelease() {
        let dbManager =  DBQueueFactory()
        var store1: FeedStore? = makeSUT(dbQueueManager: dbManager)
        var store2: FeedStore? = makeSUT(dbQueueManager: dbManager)
        weak var dbQueue = (store1 as? GRDBFeedStore)?.dbQueue
        XCTAssertNotNil(dbQueue)
        store1 = nil
        XCTAssertNotNil(dbQueue)
        store2 = nil
        XCTAssertNil(store2) // fix warning of: Variable 'store2' was written to, but never read
        XCTAssertNil(dbQueue)
    }
}

