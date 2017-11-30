//
//  MenuCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/29/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

enum MenuSelection {
    case saveVoice, sendFeedback, selectVoice//, useInternet, speakEveryWord
}

class MenuCoordinator: BaseCoordinator, MenuScreenDelegate {
    
    var finishFlow: ((Any) -> Void)?
    
    fileprivate let router: Router
    fileprivate let assembly:AssemblyCoordinator
    fileprivate let screenAssembly: AssemblyScreen
    fileprivate let appPreference: AppSettingsManager
    fileprivate let ttsManager: TTSManager
    fileprivate let sourceView: UIView?
    fileprivate let barButtonitem: UIBarButtonItem?


    fileprivate var menuSelection:MenuSelection?

    fileprivate lazy var menuVC:MenuScreen = {
        let vc = self.screenAssembly.menuScreen(delegate:self)
        return vc
    }()
    
    init(_ router: Router, assembly: AssemblyCoordinator, screenAssembly:AssemblyScreen, appPreference:AppSettingsManager, ttsManager: TTSManager, sourceView: UIView? = nil, barButtonitem:UIBarButtonItem? = nil) {
        self.router = router
        self.assembly = assembly
        self.screenAssembly = screenAssembly
        self.appPreference = appPreference
        self.sourceView = sourceView
        self.barButtonitem = barButtonitem
        self.ttsManager = ttsManager
    }
    
    // MARK: - Public
    func start() {
        router.presentModaly(menuVC, sourceView: sourceView, barButtonItem:barButtonitem)
    }
    
    // MARK: - MenuScreenDelegate
    func isUseInternet() -> Bool {
        return appPreference.isUseInternet
    }
    func isSpeakEveryWord() -> Bool {
        return appPreference.isSpeakEveryWord
    }
    
    func saveVoice() {
        menuVC.dismiss(animated: true, completion: nil)
        finishFlow?(MenuSelection.saveVoice)
    }
    
    func sendFeedback() {
        menuVC.dismiss(animated: true, completion: nil)
        finishFlow?(MenuSelection.sendFeedback)
    }
    
    func selectVoice() {
        menuVC.dismiss(animated: true, completion: nil)
        finishFlow?(MenuSelection.selectVoice)
    }
    
    func useInternetToggle(_ value:Bool) {
        appPreference.useInternet(value)
    }
    
    func speakAfterEveryWordToggle(_ value:Bool) {
        appPreference.speakEveryWord(value)
    }
}
