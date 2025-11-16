//
//  uICollectionView.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 5.10.2025.
//

import UIKit

extension UICollectionView {
    
    func register(cellType: UICollectionViewCell.Type) {
        register(cellType.nib, forCellWithReuseIdentifier: cellType.identifier)
    }
    
    func dequeCell<T: UICollectionViewCell>(cellType: T.Type, indexPath: IndexPath) -> T {
        
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath) as? T else {
            fatalError("error")
        }
        return cell
    }
    
}
