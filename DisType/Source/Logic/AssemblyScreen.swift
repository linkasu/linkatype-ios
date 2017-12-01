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
//  AssemblyScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//

import Foundation
import MessageUI

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

    func selectVoiceScreen(delegate:SelectVoiceCoordinator) -> SelectVoiceScreen {
        let vc = SelectVoiceScreen.instantiateFromStoryboard()
        vc.delegate = delegate
        return vc
    }
    
    func sendFeedback() -> MFMailComposeViewController? {
        guard
            MFMailComposeViewController.canSendMail()
            else {
                print("Mail services are not available")
                return nil
        }
        
        let composeVC = MFMailComposeViewController()
        
        // Configure the fields of the interface.
        composeVC.setSubject("DisType-Pro feedback")
        
        return composeVC
    }
}
