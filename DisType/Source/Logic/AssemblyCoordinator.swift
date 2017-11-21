//
//  AssemblyCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

class AssemblyCoordinator {
    fileprivate let router: Router
    fileprivate let screenAssembly = AssemblyScreen()
    
    lazy var appCoordinator: AppCoordinator = {
        return AppCoordinator(router, self)
    }()
    
//    lazy var authCoordinator: AuthCoordinator = {
//        return AuthCoordinator(router, assembly:self, screenAssembly:screenAssembly, loginManager:LoginManager())
//    }()
//    
    lazy var mainCoordinator: MainCoordinator = {
        return MainCoordinator(router, assembly:self, screenAssembly:screenAssembly)
    }()
    
    init(_ router:Router) {
        self.router = router
    }
}
