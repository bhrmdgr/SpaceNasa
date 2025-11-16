//
//  LoadingView.swift
//  SpaceNasa
//
//  Created by Behram Doğru on 6.10.2025.
//

import UIKit

class LoadingView {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    static let shared = LoadingView()
    
    var blurView: UIVisualEffectView = UIVisualEffectView()
    
    private init() {
        configure()
    }
    
    func configure() {
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        //blurView.backgroundColor = .black
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = UIWindow(frame: UIScreen.main.bounds).frame
        
        activityIndicator.center = blurView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        blurView.contentView.addSubview(activityIndicator)
        
    }
    
    func startLoading() {
        UIApplication.shared.windows.first?.addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        blurView.removeFromSuperview()
    }
    
}
