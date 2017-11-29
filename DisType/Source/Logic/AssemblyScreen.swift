//
//  AssemblyScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation

class AssemblyScreen {
    
    func mainScreen(delegate:MainCoordinator,
                    chatCollection:ChatCollection,
                    categoryManager:CategoryManager,
                    messageManager:MessageManager) -> MainScreen {
        let vc = MainScreen.instantiateFromStoryboard()
        vc.messageDelegate = messageManager
        vc.categoryDelegate = categoryManager
        vc.chatDelegate = chatCollection
        vc.delegate = delegate
        return vc
    }
    
    
    func menuScreen(delegate:MenuCoordinator) -> MenuScreen {
        let vc = MenuScreen.instantiateFromStoryboard()
        vc.delegate = delegate
        return vc
    }

}
