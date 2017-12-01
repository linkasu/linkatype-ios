/*-
 * Copyright © 2016  Alex Makushkin
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
//
//  Router.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
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
