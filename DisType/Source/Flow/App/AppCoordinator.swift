//
//  AppCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation

enum AppState {
    case main
}

final class AppCoordinator: BaseCoordinator, Coordinator {
    fileprivate let router: Router
    fileprivate let assembly: AssemblyCoordinator
    
    fileprivate var state: AppState
    
    init(_ router: Router, _ assembly: AssemblyCoordinator) {
        self.router = router
        self.assembly = assembly
        state = .main
    }
    
    func start() {
        switch state {
        case .main:
            runMainFlow()
        }
    }
    
    fileprivate func runMainFlow() {
        let mainCoordinator = assembly.mainCoordinator
        addDependency(mainCoordinator)
        
        mainCoordinator.finishFlow = { [weak self, weak mainCoordinator] item in
            self?.router.dismissTopScreen()
            self?.removeDependency(mainCoordinator)
            self?.start()
        }
        
        mainCoordinator.start()
    }
    
}
