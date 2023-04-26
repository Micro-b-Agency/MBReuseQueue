//
//  MBReusableTestObject.swift
//  MBReuseQueueTests
//
//  Created by Sem Koliesnikov on 26/04/2023.
//

import Foundation
@testable import MBReuseQueue

class MBReusableTestObject: NSObject, MBReusableObject {
    
    required init?(reuseIdentifier: String?) {
        self.reuseIdentifier = reuseIdentifier
    }
    
    var reuseIdentifier: String?
    var prepareForReuseBlock: (() -> Void)?
    
    func prepareForReuse() {
        prepareForReuseBlock?()
    }
}
