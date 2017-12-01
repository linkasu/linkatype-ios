/*-
 * Copyright © 2016  Alex Makushkin
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
//
//  MenuCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/29/17.
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
