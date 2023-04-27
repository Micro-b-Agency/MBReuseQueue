//
//  MBReuseQueueTests.swift
//  MBReuseQueueTests
//
//  Created by Sem Koliesnikov on 20/04/2023.
//

import XCTest
@testable import MBReuseQueue


import XCTest
@testable import MBReuseQueue

class MBReuseQueueTests: XCTestCase {
    
    enum MBReuseQueueTestsError: Error, Equatable, CustomStringConvertible {
        case emptyQueue
        case invalidIdentifier(String)
        
        var description: String {
            switch self {
            case .emptyQueue:
                return "The queue is empty"
            case .invalidIdentifier(let identifier):
                return "Invalid identifier: \(identifier)"
            }
        }
    }
    
    let kReuseIdentifierA = "kReuseIdentifierA"
    let kReuseIdentifierB = "kReuseIdentifierB"
    
    override func setUp() {
        super.setUp()
        //
    }
    
    override func tearDown() {
        //
        super.tearDown()
    }
    
    // MARK: - default queue
    
    func testDefaultQueue() {
        let q = MBReuseQueue.defaultQueue
        XCTAssertNotNil(q, "No default queue")
        XCTAssertTrue(q.unusedCount == 0)
        XCTAssertTrue(q.usedCount == 0)
        XCTAssertTrue(q.count == 0)
    }
    
    // MARK: - enqueue
    
    func testEnqueue() {
        let q = MBReuseQueue()
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        XCTAssertTrue(q.unusedCount == 1)
        XCTAssertTrue(q.usedCount == 0)
        XCTAssertTrue(q.count == 1)
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        XCTAssertTrue(q.unusedCount == 2)
        XCTAssertTrue(q.usedCount == 0)
        XCTAssertTrue(q.count == 2)
    }
    
    func testEnqueueWithMultipleIdentifiers() {
        let q = MBReuseQueue()
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        XCTAssertTrue(q.unusedCount == 1)
        XCTAssertTrue(q.usedCount == 0)
        XCTAssertTrue(q.count == 1)
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierB)!)
        XCTAssertTrue(q.unusedCount == 2)
        XCTAssertTrue(q.usedCount == 0)
        XCTAssertTrue(q.count == 2)
    }
    
    func testEnqueueWithoutIdentifier() {
        let q = MBReuseQueue()
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: nil)!)
        XCTAssertTrue(q.unusedCount == 0)
        XCTAssertTrue(q.usedCount == 0)
        XCTAssertTrue(q.count == 0)
    }
    
    func testDequeue() {
        let q = MBReuseQueue()
        
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        
        XCTAssertTrue(q.unusedCount == 1)
        XCTAssertTrue(q.usedCount == 0)
        XCTAssertTrue(q.count == 1)
        
        q.dequeueReusableObject(withIdentifier: kReuseIdentifierA)
        
        XCTAssertTrue(q.unusedCount == 0)
        XCTAssertTrue(q.usedCount == 1)
        XCTAssertTrue(q.count == 1)
        
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        
        XCTAssertTrue(q.unusedCount == 1)
        XCTAssertTrue(q.usedCount == 1)
        XCTAssertTrue(q.count == 2)
        
        q.dequeueReusableObject(withIdentifier: kReuseIdentifierA)
        
        XCTAssertTrue(q.unusedCount == 0)
        XCTAssertTrue(q.usedCount == 2)
        XCTAssertTrue(q.count == 2)
    }
    
    
    func testDequeueWithMultipleIdentifiers() {
        let q = MBReuseQueue()
        
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        
        XCTAssertTrue(q.unusedCount == 1)
        XCTAssertTrue(q.usedCount == 0)
        XCTAssertTrue(q.count == 1)
        
        guard let r = q.dequeueReusableObject(withIdentifier: kReuseIdentifierA) else {
            XCTFail("Failed to dequeue object")
            return
        }
        
        XCTAssertEqual(r.reuseIdentifier, kReuseIdentifierA)
        
        XCTAssertTrue(q.unusedCount == 0)
        XCTAssertTrue(q.usedCount == 1)
        XCTAssertTrue(q.count == 1)
        
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierB)!)
        
        XCTAssertTrue(q.unusedCount == 1)
        XCTAssertTrue(q.usedCount == 1)
        XCTAssertTrue(q.count == 2)
        
        guard let r2 = q.dequeueReusableObject(withIdentifier: kReuseIdentifierB) else {
            XCTFail("Failed to dequeue object")
            return
        }
        
        XCTAssertEqual(r2.reuseIdentifier, kReuseIdentifierB)
        
        XCTAssertTrue(q.unusedCount == 0)
        XCTAssertTrue(q.usedCount == 2)
        XCTAssertTrue(q.count == 2)
    }
    
    func testPrepareForReuse() {
        
        var blockDidRun = false
        
        let q = MBReuseQueue()
        
        let r = MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)
        r!.prepareForReuseBlock = {
            blockDidRun = true
        }
        
        q.enqueueReusableObject(r!)
        XCTAssertFalse(blockDidRun)
        
        guard let _ = q.dequeueReusableObject(withIdentifier: kReuseIdentifierA) else {
            XCTFail("Failed to dequeue object")
            return
        }
        XCTAssertTrue(blockDidRun)
    }
    
    func testMemoryWarning() {
        let q = MBReuseQueue()
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
        
        q.dequeueReusableObject(withIdentifier: kReuseIdentifierA)
        
        XCTAssertEqual(q.unusedCount, 2)
        XCTAssertEqual(q.usedCount, 1)
        XCTAssertEqual(q.count, 3)
        
        NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        
        XCTAssertEqual(q.unusedCount, 0)
        XCTAssertEqual(q.usedCount, 1)
        XCTAssertEqual(q.count, 1)
    }
    
    //    func testDequeueEmpty() {
    //        let q = MBReuseQueue()
    //        do {
    //            _ = try q.dequeueReusableObject(withIdentifier: kReuseIdentifierA)
    //            XCTAssertTrue(false)
    //        } catch let error as NSError {
    //            XCTAssertEqual(error.domain, MBReuseQueueEmptyException)
    //            XCTAssertEqual(error.code, 0)
    //        }
    //    }
    //
    //    func testDequeueEmptyForIdentifier() {
    //        let q = MBReuseQueue()
    //        let object = MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)
    //        object!.reuseIdentifier = kReuseIdentifierA
    //        q.enqueueReusableObject(object!)
    //        q.dequeueReusableObject(withIdentifier: kReuseIdentifierB)
    //        do {
    //            _ = try q.dequeueReusableObject(withIdentifier: kReuseIdentifierB)
    //            XCTAssertTrue(false)
    //        } catch let error as NSError {
    //            XCTAssertEqual(error.domain, MBReuseQueueEmptyException)
    //            XCTAssertEqual(error.code, 0)
    //        }
    //    }
    //
    //    func testDequeueEmptied() {
    //        let q = MBReuseQueue()
    //        q.enqueueReusableObject(MBReusableTestObject(reuseIdentifier: kReuseIdentifierA)!)
    //        _ = try? q.dequeueReusableObject(withIdentifier: kReuseIdentifierA)
    //        do {
    //            _ = try q.dequeueReusableObject(withIdentifier: kReuseIdentifierA)
    //            XCTAssertTrue(false)
    //        } catch let error as NSError {
    //            XCTAssertEqual(error.domain, MBReuseQueueErrorDomain)
    //            XCTAssertEqual(error.code, MBReuseQueueErrorCode.emptyQueue.rawValue)
    //        }
    //    }
    //
    //    func testRegisterClass() {
    //        let q = MBReuseQueue()
    //        q.registerClass(MBReusableTestObject.self, forObjectReuseIdentifier: kReuseIdentifierA)
    //        guard let r = try? q.dequeueReusableObject(withIdentifier: kReuseIdentifierA) as? MBReusableTestObject else {
    //            XCTAssertTrue(false)
    //            return
    //        }
    //        XCTAssertEqual(r.reuseIdentifier, kReuseIdentifierA)
    //        XCTAssertTrue(r is MBReusableTestObject)
    //
    //        do {
    //            _ = try q.dequeueReusableObject(withIdentifier: kReuseIdentifierB)
    //            XCTAssertTrue(false)
    //        } catch let error as NSError {
    //            XCTAssertEqual(error.domain, MBReuseQueueErrorDomain)
    //            XCTAssertEqual(error.code, MBReuseQueueErrorCode.emptyQueue.rawValue)
    //        }
    //    }
    //
    //    func testRegisterNib() {
    //        // hack for tests
    //        var bundleContainingNib: Bundle?
    //        for bundle in Bundle.allBundles {
    //            if let locatedPath = bundle.path(forResource: "MBReusableTest", ofType: "nib") {
    //                bundleContainingNib = bundle
    //                break
    //            }
    //        }
    //        // end hack for tests
    //
    //        let q = MBReuseQueue()
    //        q.registerNib(UINib(nibName: "MBReusableTest", bundle: bundleContainingNib), forObjectReuseIdentifier: kReuseIdentifierA)
    //
    //        guard let r = q.dequeueReusableObject(withIdentifier: kReuseIdentifierA) as? MBReusableTestObject else {
    //            XCTFail()
    //            return
    //        }
    //        XCTAssertEqual(r.reuseIdentifier, kReuseIdentifierA)
    //
    //        XCTAssertNotNil(r)
    //        XCTAssertTrue(type(of: r) == MBReusableTestObject.self)
    //
    //        do {
    //            try q.dequeueReusableObject(withIdentifier: kReuseIdentifierB)
    //            XCTFail()
    //        } catch let error as MBReuseQueueError {
    //            XCTAssertEqual(error.errorCode, MBReuseQueueErrorCode.emptyQueue)
    //        } catch {
    //            XCTFail()
    //        }
    //    }
    
}

enum MBReuseQueueErrorCode: Int {
    case emptyQueue = 1
    case invalidIdentifier = 2
}

extension MBReuseQueueErrorCode: CustomStringConvertible {
    var description: String {
        switch self {
        case .emptyQueue:
            return "MBReuseQueueError: The reuse queue is empty."
        case .invalidIdentifier:
            return "MBReuseQueueError: The identifier is invalid."
        }
    }
}

let MBReuseQueueErrorDomain = "com.example.MBReuseQueueErrorDomain"

struct MBReuseQueueError: Error {
    let errorCode: MBReuseQueueErrorCode
    let userInfo: [String: Any]?
    
    init(errorCode: MBReuseQueueErrorCode, userInfo: [String: Any]? = nil) {
        self.errorCode = errorCode
        self.userInfo = userInfo
    }
}
