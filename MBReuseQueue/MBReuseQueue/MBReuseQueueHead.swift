//
//  MBReuseQueueHead.swift
//  MBReuseQueue
//
//  Created by Sem Koliesnikov on 25/04/2023.
//

import Foundation
import UIKit

class MBReuseQueueHead: NSObject {
    
    static let defaultQueue = MBReuseQueue()
    
    var maxUnusedCount: UInt = 0
    
    private var dictionaryOfRegisteredClassesOrNibs = [String: Any]()
    private var dictionaryOfSetsOfUnusedObjects = [String: [any MBReusableObject]]()
    private var setOfUsedObjects = [any MBReusableObject]()
    
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
    
    func enqueueReusableObject(_ reusableObject: any MBReusableObject) {
        let identifier = reusableObject.reuseIdentifier
        var setOfUnusedObjects = dictionaryOfSetsOfUnusedObjects[identifier!]
        setOfUnusedObjects?.insert(reusableObject, at: 1)
        dictionaryOfSetsOfUnusedObjects[identifier!] = setOfUnusedObjects
        
        setOfUsedObjects.remove(at: reusableObject.reuseIdentifier!.count)
        
        if unusedCount > maxUnusedCount {
            removeAllUnusedObjects()
        }
    }
    
    func dequeueReusableObject(withIdentifier identifier: String) -> (any MBReusableObject)? {
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
