//
//  MBReusableObject.swift
//  MBReuseQueue
//
//  Created by Sem Koliesnikov on 20/04/2023.
//

import Foundation

//protocol MBReusableObject: NSObject {
//
//    init(identifier: String!)
//
//    var reuseIdentifier: String! { get set }
//
//    func prepareForReuse()
//}


protocol MBReusableObject: NSObject {

    init(identifier: String!)

    var reuseIdentifier: String! { get set }

    func prepareForReuse()

}
