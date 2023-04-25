//
//  MBReuseQueueHead.swift
//  MBReuseQueue
//
//  Created by Sem Koliesnikov on 25/04/2023.
//

import Foundation
import UIKit

//class MBReuseQueueHead {
//
//    static let defaultQueue = MBReuseQueue()
//
//    var maxUnusedCount: UInt
//
//    private var reusableObjects = [String: [MBReusableObject]]()
//    private var usedObjects = [MBReusableObject]()
//
//    init() {
//        self.maxUnusedCount = 10
//    }
//
//    func enqueueReusableObject(_ reusableObject: MBReusableObject) {
//        reusableObject.prepareForReuse()
//        if let identifier = reusableObject.reuseIdentifier {
//            var unusedObjects = reusableObjects[identifier] ?? [MBReusableObject]()
//            if unusedObjects.count < maxUnusedCount {
//                unusedObjects.append(reusableObject)
//                reusableObjects[identifier] = unusedObjects
//            }
//        }
//    }
//
//    func dequeueReusableObject(withIdentifier identifier: String) throws -> MBReusableObject {
//        guard var unusedObjects = reusableObjects[identifier], unusedObjects.count > 0 else {
//            throw NSException(name: NSExceptionName(rawValue: MBReuseQueueEmptyException), reason: "ACReuseQueue is empty for identifier: \(identifier)", userInfo: nil) as! Error
//        }
//
//        let reusableObject = unusedObjects.removeLast()
//        usedObjects.append(reusableObject)
//        return reusableObject
//    }
//
//    func registerNib(nib: UINib, forObjectReuseIdentifier identifier: String) {
//        MBReuseQueueHead.defaultQueue.dictionaryOfRegisteredClassesOrNibs[identifier] = nib
////        dictionaryOfRegisteredClassesOrNibs[identifier] = nib
//    }
//
//        func registerNib(_ nib: UINib, forObjectReuseIdentifier identifier: String) {
//            MBReuseQueueHead.defaultQueue.dictionaryOfRegisteredClassesOrNibs[identifier] = nib
//        }
//
//
//        func registerNibWithName (nibName: String, bundle nibBundle: Bundle, forObjectReuseIdentifier identifier: String) {
//            let nib = UINib(nibName: nibName, bundle: nibBundle)
//            registerNib(nib, forObjectReuseIdentifier: identifier)
//        }
//
//
//        func registerClass(_ objectClass: AnyClass?, forObjectReuseIdentifier identifier: String) {
//            if let cls = objectClass {
//                MBReuseQueueHead.defaultQueue.dictionaryOfRegisteredClassesOrNibs[identifier] = NSStringFromClass(cls)
//            } else {
//                MBReuseQueueHead.defaultQueue.dictionaryOfRegisteredClassesOrNibs.removeValue(forKey: identifier)
//            }
//        }
//    }
//
//
//
//
//
//    func registerNibs(_ nib: UINib, forObjectReuseIdentifier identifier: String) {
//        let objectClass = MBReusableObject.self
//        objectClass.registerNib(nib, forObjectReuseIdentifier: identifier)
//    }
//
//    func registerNibWithName(_ nibName: String, bundle nibBundle: Bundle?, forObjectReuseIdentifier identifier: String) {
//        let objectClass = MBReusableObject.self
//        objectClass.registerNib(withName: nibName, bundle: nibBundle, forObjectReuseIdentifier: identifier)
//    }
//
//    func registerClass(_ objectClass: AnyClass, forObjectReuseIdentifier identifier: String) {
//        objectClass.registerClass(forObjectReuseIdentifier: identifier)
//    }
//
//    var unusedCount: UInt {
//        var count: UInt = 0
//        for (_, unusedObjects) in reusableObjects {
//            count += UInt(unusedObjects.count)
//        }
//        return count
//    }
//
//    var usedCount: UInt {
//        return UInt(usedObjects.count)
//    }
//
//    var count: UInt {
//        return unusedCount + usedCount
//    }
//
//    func removeAllUnusedObjects() {
//        reusableObjects.removeAll()
//    }
//}

class MBReuseQueueHead: NSObject {
    
    static let defaultQueue = MBReuseQueue()
    
    var maxUnusedCount: UInt = 0
    
    private var dictionaryOfRegisteredClassesOrNibs = [String: Any]()
    private var dictionaryOfSetsOfUnusedObjects = [String: [MBReusableObject]]()
    private var setOfUsedObjects = [MBReusableObject]()
    
    var unusedCount: UInt {
        var count: UInt = 0
        for (_, set) in dictionaryOfSetsOfUnusedObjects {
            count += UInt(set.count)
        }
        return count
    }
    
    var usedCount: UInt {
        return UInt(setOfUsedObjects.count)
    }
    
    var count: UInt {
        return usedCount + unusedCount
    }
    
    func enqueueReusableObject(_ reusableObject: MBReusableObject) {
        let identifier = reusableObject.reuseIdentifier
        var setOfUnusedObjects = dictionaryOfSetsOfUnusedObjects[identifier!]
        setOfUnusedObjects?.insert(reusableObject, at: 1)
        dictionaryOfSetsOfUnusedObjects[identifier!] = setOfUnusedObjects
        
        setOfUsedObjects.remove(at: reusableObject.reuseIdentifier!.count)
        
        if unusedCount > maxUnusedCount {
            removeAllUnusedObjects()
        }
    }
    
    func dequeueReusableObject(withIdentifier identifier: String) -> MBReusableObject? {
        guard let setOfUnusedObjects = dictionaryOfSetsOfUnusedObjects[identifier],
              let reusableObject = setOfUnusedObjects.first else {
            return nil
        }
        
        setOfUsedObjects.insert(reusableObject, at: 1)
        var newSetOfUnusedObjects = setOfUnusedObjects
        newSetOfUnusedObjects.remove(at: reusableObject.reuseIdentifier!.count)
        dictionaryOfSetsOfUnusedObjects[identifier] = newSetOfUnusedObjects
        
        return reusableObject
    }
    
    func registerNib(_ nib: UINib, forObjectReuseIdentifier identifier: String) {
        dictionaryOfRegisteredClassesOrNibs[identifier] = nib
    }
    
    func registerNib(withName nibName: String, bundle nibBundle: Bundle?, forObjectReuseIdentifier identifier: String) {
        let nib = UINib(nibName: nibName, bundle: nibBundle)
        registerNib(nib, forObjectReuseIdentifier: identifier)
    }
    
    func registerClass(_ objectClass: AnyClass?, forObjectReuseIdentifier identifier: String) {
        if let objectClass = objectClass {
            dictionaryOfRegisteredClassesOrNibs[identifier] = NSStringFromClass(objectClass)
        } else {
            dictionaryOfRegisteredClassesOrNibs.removeValue(forKey: identifier)
        }
    }
    
    func removeAllUnusedObjects() {
        dictionaryOfSetsOfUnusedObjects.removeAll()
    }
}
