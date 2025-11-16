//
//  LoadingShowable.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 5.10.2025.
//

import UIKit


protocol LoadingShowable where Self: UIViewController {
    func showLoading()
    func hideLoading()
}

extension LoadingShowable {
    
    func showLoading() {
        LoadingView.shared.startLoading()
    }
    
    func hideLoading() {
        LoadingView.shared.stopLoading()
    }
    
}
