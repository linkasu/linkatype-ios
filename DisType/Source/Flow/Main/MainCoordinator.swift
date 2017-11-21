//
//  MainCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
protocol HomeDelegate {
    func didEntered(_ text:String)
    func finish()
}

class MainCoordinator: BaseCoordinator, HomeDelegate, Coordinator, CoordinatorOutput, ChatCollectionDelegate {
    var finishFlow: ((Any) -> Void)?
    
    fileprivate let router: Router
    fileprivate let assembly:AssemblyCoordinator
    fileprivate let screenAssembly: AssemblyScreen
    
    fileprivate lazy var mainVC:MainScreen = {
        let vc = self.screenAssembly.mainScreen(delegate:self)
        return vc
    }()
    
    init(_ router: Router, assembly: AssemblyCoordinator, screenAssembly:AssemblyScreen) {
        self.router = router
        self.assembly = assembly
        self.screenAssembly = screenAssembly
    }

    // MARK: - Public
    func start() {
        router.push(mainVC)
    }
    
    // MARK: - HomeDelegate
    func didEntered(_ text:String) {
    }
    
    func finish() {
        finishFlow!("sss")
    }
    // MARK: - ChatCollectionDelegate
    func willUnSelect(_ chat: Chat) {
        guard let text = mainVC.inputTextView.text else { return }
        chat.update(text:text)
    }
    
    func didSelect(_ chat: Chat) {
        print("\(chat.name) selected")
        let text = chat.text
        mainVC.set(inputText:text)
    }
}
