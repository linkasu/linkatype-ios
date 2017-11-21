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
    let minChatCount = 3
    let chatName = "ЧАТ"
    
    fileprivate let router: Router
    fileprivate let assembly: AssemblyCoordinator
    
    fileprivate var state: AppState
    
    init(_ router: Router, _ assembly: AssemblyCoordinator) {
        self.router = router
        self.assembly = assembly
        state = .main
    }
    
    // MARK: - Private
    fileprivate func initDB() {
        let chatsCount = DB.chats.count
        if chatsCount < minChatCount {
            var count = chatsCount + 1
            while count <= minChatCount {
                let chat = Chat()
                chat.name = "\(chatName)\(count)"
                DB.add(chat)
                count += 1
            }
        }
    }

    func start() {
        initDB()
        
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
