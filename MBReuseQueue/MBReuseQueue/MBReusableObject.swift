//
//  MBReusableObject.swift
//  MBReuseQueue
//
//  Created by Sem Koliesnikov on 20/04/2023.
//

import Foundation
import UIKit

protocol MBReusableObject: AnyObject {
    var reuseIdentifier: String? { get set }
    func prepareForReuse()
}

//extension UITableViewCell: MBReusableObject {}
//extension UICollectionReusableView: MBReusableObject {}

