//
//  Router.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

class Router:NSObject, UIPopoverPresentationControllerDelegate {
    fileprivate let navController: UINavigationController
    
    init(navController:UINavigationController) {
        self.navController = navController
    }
    
    func presentModaly(_ vc:UIViewController, sourceView:UIView? = nil, barButtonItem:UIBarButtonItem? = nil, animated:Bool = true)  {
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        vc.popoverPresentationController?.delegate = self
        if let barItem = barButtonItem {
            vc.popoverPresentationController?.barButtonItem = barItem
        } else if let view = sourceView {
            vc.popoverPresentationController?.sourceView = view
        } else {
            assertionFailure("Not specified sourceView or barButtonItem for menu popover")
        }
        
        // present the popover
        navController.present(vc, animated: animated, completion: {
            vc.view.superview?.layer.cornerRadius = 4
        })
    }
    
    func push(_ vc:UIViewController, animated:Bool = true)  {
        navController.pushViewController(vc, animated: animated)
    }
    func dismissTopScreen(animated:Bool = true) {
        navController.popViewController(animated: animated)
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
