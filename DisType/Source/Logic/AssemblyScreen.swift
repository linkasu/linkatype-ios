//
//  AssemblyScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation

class AssemblyScreen {
    
    func mainScreen(delegate:MainCoordinator) -> MainScreen {
        let vc = MainScreen.instantiateFromStoryboard()
        vc.delegate = delegate
        let chatCollection = ChatCollection(with:delegate)
        vc.chatDelegate = chatCollection
        return vc
    }
    
}
