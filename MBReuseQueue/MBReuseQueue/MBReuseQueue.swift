//
//  MBReuseQueue.swift
//  MBReuseQueue
//
//  Created by Sem Koliesnikov on 20/04/2023.
//

import Foundation
import UIKit

let MBReuseQueueEmptyException: String! = "MBReuseQueueEmptyException"


class MBReuseQueue: NSObject {

//    var maxUnusedCount: UInt
    //    private(set) var unusedCount: UInt = 0
    //    private(set) var usedCount: UInt = 0
    //    private(set) var count: UInt = 0
    
    func registerNib(forObjectReuseIdentifier: UINib) -> NSString {
        
    }
    
    private var _dictionaryOfSetsOfUnusedObjects: NSMutableDictionary!
    private var dictionaryOfSetsOfUnusedObjects: NSMutableDictionary! {
        get {
            if (_dictionaryOfSetsOfUnusedObjects == nil) {
                _dictionaryOfSetsOfUnusedObjects = NSMutableDictionary()
            }
            return _dictionaryOfSetsOfUnusedObjects
        }
        set { _dictionaryOfSetsOfUnusedObjects = newValue }
    }
    private var _dictionaryOfSetsOfUsedObjects: NSMutableDictionary!
    private var dictionaryOfSetsOfUsedObjects: NSMutableDictionary! {
        get {
            if (_dictionaryOfSetsOfUsedObjects == nil) {
                _dictionaryOfSetsOfUsedObjects = NSMutableDictionary()
            }
            return _dictionaryOfSetsOfUsedObjects
        }
        set { _dictionaryOfSetsOfUsedObjects = newValue }
    }
    private var _dictionaryOfRegisteredClassesOrNibs: NSMutableDictionary!
    private var dictionaryOfRegisteredClassesOrNibs: NSMutableDictionary! {
        get {
            if (_dictionaryOfRegisteredClassesOrNibs == nil) {
                _dictionaryOfRegisteredClassesOrNibs = NSMutableDictionary()
            }
            return _dictionaryOfRegisteredClassesOrNibs
        }
        set { _dictionaryOfRegisteredClassesOrNibs = newValue }
    }
    
//    override init() {
//         self = super.init()
//         if (self != nil) {
//                NotificationCenter.default.addObserver(self, selector:Selector(("removeAllUnusedObjects")), name: UIApplication.didReceiveMemoryWarningNotification, object:nil)
//            }
//            return self
//        }
//
    
    func dealloc() {
        NotificationCenter.default.removeObserver(self)
    }
    
    class func defaultQueue() -> Self {
        var reuseQueue: MBReuseQueue = { MBReuseQueue() } ()
        //        var onceToken: (&onceToken, { _reuseQueue = MBReuseQueue() })
        return reuseQueue as! Self
    }
    
    
    // MARK: - private accessors
    
    func setOfUnusedObjectsWithIdentifier(identifier: String!) -> NSMutableSet! {
        var unusedSet: NSMutableSet! = self.dictionaryOfSetsOfUnusedObjects[identifier as Any] as? NSMutableSet
        if (unusedSet == nil) {
            unusedSet = NSMutableSet()
            self.dictionaryOfSetsOfUnusedObjects[identifier as Any] = unusedSet
        }
        return unusedSet
    }
    
    func setOfUsedObjectsWithIdentifier(identifier: String!) -> NSMutableSet! {
        var usedSet: NSMutableSet! = self.dictionaryOfSetsOfUsedObjects[identifier!] as? NSMutableSet
        if (usedSet == nil) {
            usedSet = NSMutableSet()
            self.dictionaryOfSetsOfUsedObjects[identifier as Any] = usedSet
        }
        return usedSet
    }
    
    // `dictionaryOfRegisteredClassesOrNibs` has moved as a getter.
    
    
    // MARK: - counts
    
    func unusedCount() -> UInt {
        var unusedCount: UInt = 0
        for set: NSSet? in self.dictionaryOfSetsOfUnusedObjects.allValues {
            unusedCount += set.count()
        }
        return unusedCount
    }
    
    func usedCount() -> UInt {
        var usedCount:UInt = 0
        for set: NSSet? in self.dictionaryOfSetsOfUsedObjects.allValues {
            usedCount += set.count()
        }
        return usedCount
    }
    
    func count() -> UInt {
        return self.unusedCount() + self.usedCount()
    }
    
    
    // MARK: - Enqueueing and dequeuing objects
    
    func enqueueReusableObject(reusableObject: MBReusableObject!) {
        if !reusableObject.NSObject(Selector("reuseIdentifier")) ||
            (reusableObject.reuseIdentifier == nil) { return }
        
        self.setOfUsedObjectsWithIdentifier(identifier: reusableObject.reuseIdentifier.remove(at: reusableObject))
        self.setOfUsedObjectsWithIdentifier = reusableObject.reuseIdentifier.removeObject(reusableObject)
        self.setOfUnusedObjectsWithIdentifier = reusableObject.reuseIdentifier.addObject(reusableObject)
    }
    
    
    func dequeueReusableObjectWithIdentifier(identifier:String!) -> MBReusableObject! {
        
        var reusableObject:MBReusableObject! = self.ofUnusedObjectsWithIdentifier = identifier.anyObject()
        
        if (reusableObject == nil) {
            reusableObject = self.newReuseObjectWithIdentifier(identifier: identifier)
            
            if reusableObject == nil {
                NSException.raise(MBReuseQueueEmptyException, format:"No class or nib was registered with the MBReuseQueue for identifier %@", identifier)
            }
        }
        
        self.ofUsedObjectsWithIdentifier = identifier.addObject(reusableObject)
        self.ofUnusedObjectsWithIdentifier = identifier.removeObject(reusableObject)
        
        if reusableObject.respondsToSelector(Selector("prepareForReuse")) {
            reusableObject.prepareForReuse()
        }
        
        return reusableObject
    }
    
    // MARK: - Registring classes or nibs
    
    func registerNib(nib:UINib!, forObjectReuseIdentifier identifier:String!) {
        self.dictionaryOfRegisteredClassesOrNibs[identifier!] = nib
    }
    
    func registerNibWithName(nibName:String!, bundle nibBundle:Bundle!, forObjectReuseIdentifier identifier:String!) {
        self.registerNib(nib: UINib(nibName: nibName, bundle:nibBundle), forObjectReuseIdentifier:identifier)
    }
    
    func registerClass(objectClass: AnyClass, forObjectReuseIdentifier identifier: String!) {
        if (objectClass != nil) {
            self.dictionaryOfRegisteredClassesOrNibs[identifier!] = NSStringFromClass(objectClass)
        } else {
            self.dictionaryOfRegisteredClassesOrNibs.removeObject(forKey: identifier!)
        }
    }
    
    // MARK: - creating objects
    
    func newReuseObjectWithIdentifier(identifier:String!) -> MBReusableObject! {
        
        var object:AnyObject! = nil
        
        let classOrNib:AnyObject! = self.dictionaryOfRegisteredClassesOrNibs[identifier!] as AnyObject
        
        if classOrNib.isKindOfClass(String.self) {
            let cls:AnyClass = NSClassFromString(classOrNib as! String)!
            object = cls
            if object.responds(to: #selector(UITableViewHeaderFooterView.init(reuseIdentifier:))) {
                object = object(reuseIdentifier: identifier)
            } else {
                object = object
                if object.responds(to: Selector(("setReuseIdentifier:"))) {
                    object.reuseIdentifier = identifier
                }
            }
            
        } else if classOrNib.isKind(UINib.self) {
            let nib: UINib! = (classOrNib as! UINib)
            let objects:[AnyObject]! = nib.instantiateWithOwner(nil, options:nil)
            object = objects.lastObject()
            if object.responds(to: Selector(("setReuseIdentifier:"))) {
                object.reuseIdentifier = identifier
            }
        }
        return object as? any MBReusableObject
    }
    
    // MARK: - remove objects
    
    
    func removeAllUnusedObjects() {
        self.dictionaryOfSetsOfUnusedObjects.removeAllObjects()
    }
}
