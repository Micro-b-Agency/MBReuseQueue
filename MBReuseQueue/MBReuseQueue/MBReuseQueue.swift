//
//  MBReuseQueue.swift
//  MBReuseQueue
//
//  Created by Sem Koliesnikov on 20/04/2023.
//


import Foundation
import UIKit

let MBReuseQueueEmptyException = "MBReuseQueueEmptyException"

class MBReuseQueue {
    private var dictionaryOfSetsOfUnusedObjects = [String: NSMutableSet]()
    private var dictionaryOfSetsOfUsedObjects = [String: NSMutableSet]()
    var dictionaryOfRegisteredClassesOrNibs = [String: Any]()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllUnusedObjects), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    static let defaultQueue = MBReuseQueue()
    
    // MARK: - private accessors
    
    private func setOfUnusedObjects(withIdentifier identifier: String) -> NSMutableSet {
        if let unusedSet = dictionaryOfSetsOfUnusedObjects[identifier] {
            return unusedSet
        }
        let unusedSet = NSMutableSet()
        dictionaryOfSetsOfUnusedObjects[identifier] = unusedSet
        return unusedSet
    }
    
    private func setOfUsedObjects(withIdentifier identifier: String) -> NSMutableSet {
        if let usedSet = dictionaryOfSetsOfUsedObjects[identifier] {
            return usedSet
        }
        let usedSet = NSMutableSet()
        dictionaryOfSetsOfUsedObjects[identifier] = usedSet
        return usedSet
    }
    
    private func dictionaryForRegisteredClassesOrNibs() -> [String: Any] {
        if dictionaryOfRegisteredClassesOrNibs.isEmpty {
            dictionaryOfRegisteredClassesOrNibs = [:]
        }
        return dictionaryOfRegisteredClassesOrNibs
    }
    
    // MARK: - counts
    
    var unusedCount: Int {
        var unusedCount = 0
        for set in dictionaryOfSetsOfUnusedObjects.values {
            unusedCount += set.count
        }
        return unusedCount
    }
    
    var usedCount: Int {
        var usedCount = 0
        for set in dictionaryOfSetsOfUsedObjects.values {
            usedCount += set.count
        }
        return usedCount
    }
    
    var count: Int {
        unusedCount + usedCount
    }
    
    // MARK: - Enqueueing and dequeuing objects
    
    func enqueueReusableObject(_ reusableObject: any MBReusableObject) {
        guard let reuseIdentifier = reusableObject.reuseIdentifier else { return }
        setOfUsedObjects(withIdentifier: reuseIdentifier).remove(reusableObject)
        setOfUnusedObjects(withIdentifier: reuseIdentifier).add(reusableObject)
    }
    
    func dequeueReusableObject(withIdentifier identifier: String) -> (any MBReusableObject)? {
        var reusableObject = setOfUnusedObjects(withIdentifier: identifier).anyObject() as? (any MBReusableObject)
        
        if reusableObject == nil {
            reusableObject = newReuseObject(withIdentifier: identifier)
            
            if reusableObject == nil {
                NSException(name: NSExceptionName(rawValue: MBReuseQueueEmptyException), reason: "No class or nib was registered with the MBReuseQueue for identifier \(identifier)", userInfo: nil).raise()
            }
        }
        
        setOfUsedObjects(withIdentifier: identifier).add(reusableObject!)
        setOfUnusedObjects(withIdentifier: identifier).remove(reusableObject!)
        
        reusableObject?.prepareForReuse()
        
        return reusableObject
    }
    
    // MARK: - Registring classes or nibs
    func registerNib(_ nib: UINib, forObjectReuseIdentifier identifier: String) {
        dictionaryOfRegisteredClassesOrNibs[identifier] = nib
    }
    
    func registerNibWithName(nibName: String, bundle nibBundle: Bundle?, forObjectReuseIdentifier identifier: String) {
        registerNib(UINib(nibName: nibName, bundle: nibBundle), forObjectReuseIdentifier: identifier)
    }
    
    func registerClass(_ objectClass: AnyClass?, forObjectReuseIdentifier identifier: String) {
        if let objectClass = objectClass {
            dictionaryOfRegisteredClassesOrNibs[identifier] = NSStringFromClass(objectClass)
        } else {
            dictionaryOfRegisteredClassesOrNibs.removeValue(forKey: identifier)
        }
    }
    
    // MARK: - Creating objects
    
    func newReuseObject(withIdentifier identifier: String) -> (any MBReusableObject)? {
        var object: (any MBReusableObject)?
            if let classOrNib = dictionaryOfRegisteredClassesOrNibs[identifier] {
                if let className = classOrNib as? String,
                   let cls = NSClassFromString(className) as? any MBReusableObject.Type {
                    object = cls.init(reuseIdentifier: identifier)
                } else if let nib = classOrNib as? UINib {
                    let objects = nib.instantiate(withOwner: nil, options: nil)
                    object = objects.last as? (any MBReusableObject)
                }
                object?.reuseIdentifier = identifier
            }
            return object
        }
    
    // MARK: - Remove objects
    @objc func removeAllUnusedObjects() {
        dictionaryOfSetsOfUnusedObjects.removeAll()
    }
}
