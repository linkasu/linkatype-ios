//
//  Router.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

class Router {
    fileprivate let navController: UINavigationController
    
    init(navController:UINavigationController) {
        self.navController = navController
    }
    
    func push(_ vc:UIViewController, animated:Bool = true)  {
        navController.pushViewController(vc, animated: animated)
    }
    func dismissTopScreen(animated:Bool = true) {
        navController.popViewController(animated: animated)
    }
}
