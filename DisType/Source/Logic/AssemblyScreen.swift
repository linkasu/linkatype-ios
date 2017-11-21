//
//  AssemblyScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation

class AssemblyScreen {
    
    func mainScreen(delegate:MainCoordinator, chatCollection:ChatCollection) -> MainScreen {
        let vc = MainScreen.instantiateFromStoryboard()
        vc.chatDelegate = chatCollection
        vc.delegate = delegate
        return vc
    }
    
}
