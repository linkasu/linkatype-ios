//
//  AssemblyScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
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
