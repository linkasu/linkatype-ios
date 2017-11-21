//
//  Coordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation

protocol Coordinator {
    func start()
}

protocol CoordinatorOutput {
    var finishFlow: ((Any) -> Void)? { get set }
}
