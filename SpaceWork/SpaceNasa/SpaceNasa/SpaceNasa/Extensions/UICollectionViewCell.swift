//
//  Untitled.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 5.10.2025.
//

import UIKit

extension UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}
