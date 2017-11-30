//
//  SelectVoiceCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/30/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit


class SelectVoiceCoordinator: BaseCoordinator, SelectVoiceScreenDelegate {
    
    var finishFlow: ((Any) -> Void)?
    
    fileprivate let router: Router
    fileprivate let assembly:AssemblyCoordinator
    fileprivate let screenAssembly: AssemblyScreen
    fileprivate let appPreference: AppSettingsManager
    fileprivate let ttsManager: TTSManager
    fileprivate let sourceView: UIView?
    
    
    fileprivate var menuSelection:MenuSelection?
    
    fileprivate lazy var selectVoiceVC:SelectVoiceScreen = {
        let vc = self.screenAssembly.selectVoiceScreen(delegate:self)
        return vc
    }()
    
    init(_ router: Router, assembly: AssemblyCoordinator, screenAssembly:AssemblyScreen, appPreference:AppSettingsManager, ttsManager: TTSManager, sourceView: UIView? = nil) {
        self.router = router
        self.assembly = assembly
        self.screenAssembly = screenAssembly
        self.appPreference = appPreference
        self.sourceView = sourceView
        self.ttsManager = ttsManager
    }
    
    // MARK: - Public
    func start() {
        router.presentModaly(selectVoiceVC, sourceView: sourceView)
    }
    
    // MARK: - SelectVoiceScreenDelegate
    func voices() -> [String] {
        return ttsManager.voicesNames()
    }
    
    func selectedVoiceName() -> String {
        guard let name = ttsManager.selectedVoice?.name else { return "" }
        return name
    }
    
    func didSelect(_ voiceName: String) {
        ttsManager.select(voice: voiceName)
    }
    

}

