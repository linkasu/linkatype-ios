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
//  AssemblyCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
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
