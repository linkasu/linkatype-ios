//
//  BaseCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation

class BaseCoordinator:Equatable {
    var childCoordinators: [BaseCoordinator] = []
    
    func addDependency(_ coordinator: BaseCoordinator) {
        guard notContains(coordinator) else { return }
        
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: BaseCoordinator?) {
        guard
            let coordinator = coordinator,
            let index = childCoordinators.index(of: coordinator)
            else { return }
        
        childCoordinators.remove(at: index)
    }
    
    // MARK: - Equatable
    static func ==(lhs: BaseCoordinator, rhs: BaseCoordinator) -> Bool {
        return type(of: lhs) == type(of: rhs)
    }
    
    // MARK: - Private
    fileprivate func contains(_ coordinator:BaseCoordinator) -> Bool {
        return childCoordinators.contains{ $0 == coordinator }
    }
    fileprivate func notContains(_ coordinator:BaseCoordinator) -> Bool {
        return !contains(coordinator)
    }
}
