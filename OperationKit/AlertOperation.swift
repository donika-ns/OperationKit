//
//  AlertOperation.swift
//  OperationKit
//
//  Created by SiSo Mollov on 3/4/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import UIKit

public class AlertOperation: OKOperation {
    // MARK: Properties
    
    private let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private let presentationContext: UIViewController?
    
    public var title: String? {
        get {
            return alertController.title
        }
        
        set {
            alertController.title = newValue
            name = newValue
        }
    }
    
    public var message: String? {
        get {
            return alertController.message
        }
        
        set {
            alertController.message = newValue
        }
    }
    
    // MARK: Initialization
    
    public init(presentationContext: UIViewController? = nil) {
        
        if presentationContext == nil {
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            
            if let vc = viewController as? UINavigationController {
                self.presentationContext = vc.visibleViewController
                
            } else if let vc = viewController as? UITabBarController {
                self.presentationContext = vc.selectedViewController
                
            } else {
                
                self.presentationContext = viewController
            }
        } else {
            self.presentationContext = presentationContext
        }
        
        super.init()
        
        addCondition(AlertPresentation())
        
        /*
            This operation modifies the view controller hierarchy.
            Doing this while other such operations are executing can lead to
            inconsistencies in UIKit. So, let's make them mutally exclusive.
        */
        addCondition(MutuallyExclusive<UIViewController>())
    }
    
    public func addAction(_ title: String, style: UIAlertActionStyle = .default, handler: (AlertOperation) -> Void = { _ in }) {
        let action = UIAlertAction(title: title, style: style) { [weak self] _ in
            if let strongSelf = self {
                handler(strongSelf)
            }
            
            self?.finish()
        }
        
        alertController.addAction(action)
    }
    
    override public func execute() {
        guard let presentationContext = presentationContext else {
            finish()
            
            return
        }
        
        DispatchQueue.main.async {
            if self.alertController.actions.isEmpty {
                self.addAction("OK")
            }
            
            presentationContext.present(self.alertController, animated: true, completion: nil)
        }
    }
}
