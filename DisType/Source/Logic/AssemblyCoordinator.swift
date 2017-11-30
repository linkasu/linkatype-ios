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
    fileprivate let appPreference = AppSettingsManager()
    fileprivate let ttsManager: TTSManager

    
    lazy var appCoordinator: AppCoordinator = {
        return AppCoordinator(router, self)
    }()
    
    lazy var mainCoordinator: MainCoordinator = {
        let coordinator = MainCoordinator(router, assembly:self, screenAssembly:screenAssembly, appPreference:appPreference, ttsManager:ttsManager)
        return coordinator
    }()
    
    lazy var menuCoordinator: MenuCoordinator = {
        let coordinator = MenuCoordinator(router, assembly:self, screenAssembly:screenAssembly, appPreference:appPreference, ttsManager:ttsManager , sourceView:mainCoordinator.sourceView)
        return coordinator
    }()
    
    lazy var selectVoiceCoordinator: SelectVoiceCoordinator = {
        let coordinator = SelectVoiceCoordinator(router, assembly:self, screenAssembly:screenAssembly, appPreference:appPreference, ttsManager:ttsManager, sourceView:mainCoordinator.sourceView)
        return coordinator
    }()
    
    init(_ router:Router) {
        self.router = router
        ttsManager = TTSManager(appPreference:appPreference)
    }
}
