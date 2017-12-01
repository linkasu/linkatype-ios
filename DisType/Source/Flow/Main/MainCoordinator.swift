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
//  MainCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//

import Foundation
import AVFoundation
import UIKit
import MessageUI

typealias allertReturn = (String)->()

extension MainCoordinator: ChatCollectionDelegate, CategoryManagerDelegate, MessageManagerDelegate {}

class MainCoordinator: BaseCoordinator, HomeDelegate, Coordinator, CoordinatorOutput {
    
    let systemSoundID: SystemSoundID = 1070
    var finishFlow: ((Any) -> Void)?
    var barButtonItem: UIBarButtonItem {
        return mainVC.menuButton
    }
    var sourceView: UIView {
        return mainVC.menuSourceView
    }

    fileprivate let router: Router
    fileprivate let assembly:AssemblyCoordinator
    fileprivate let screenAssembly: AssemblyScreen
    fileprivate let appPreference: AppSettingsManager
    fileprivate let ttsManager: TTSManager
    
    fileprivate lazy var chatCollection:ChatCollection = {
        let chatCollection = ChatCollection(delegate:self)
        return chatCollection
    }()
    fileprivate lazy var categoryManager: CategoryManager = {
        let categoryManager = CategoryManager(delegate:self)
        return categoryManager
    }()
    fileprivate lazy var messageManager: MessageManager = {
        let messageManager = MessageManager(delegate:self)
        return messageManager
    }()

    fileprivate lazy var mainVC:MainScreen = {
        let vc = self.screenAssembly.mainScreen(delegate:self,
                                                chatCollection:chatCollection,
                                                categoryManager:categoryManager,
                                                messageManager:messageManager)
        return vc
    }()
    
    init(_ router: Router, assembly:AssemblyCoordinator, screenAssembly:AssemblyScreen, appPreference:AppSettingsManager, ttsManager: TTSManager) {
        self.router = router
        self.assembly = assembly
        self.screenAssembly = screenAssembly
        self.appPreference = appPreference
        self.ttsManager = ttsManager
    }

    // MARK: - Public
    func start() {
        router.push(mainVC)
    }
    
    // MARK: - HomeDelegate
    func didEntered(_ text:String) {
    }
    
    func speak(_ text: String, with languageCode:String? = "ru_RU") {
        ttsManager.speak(text)
    }
    
    func addNewChat() {
        DB.addNewChat()
        chatCollection.updateLastCell()
    }
    
    func chatTextDidChanged(_ _text:String?) {
        let spaceChar = Character(" ")
        let text = _text ?? ""
        currentChat().update(text:text)
        
        guard
            appPreference.isSpeakEveryWord,
            let lastChar = text.last,
            lastChar == spaceChar,
            let lastWord = text.split(separator: spaceChar).map({String($0)}).last
            else { return }
        speak(lastWord)
    }
    
    func deleteCurrentChat(_ complition: @escaping (IndexPath)->()) {
        let chat = currentChat()
        guard let index = DB.chats.index(of:chat), index >= 3 else { return }
        DB.delete(chat)
        chatCollection.updateSelectedIndex()
        complition(chatCollection.selectedIndexPath)
    }
    
    func beepSound() {
        AudioServicesPlayAlertSound(systemSoundID)
    }
    
    func showMenu() {
        let menuCoordinator = assembly.menuCoordinator
        addDependency(menuCoordinator)
        
        menuCoordinator.finishFlow = { result in
            self.removeDependency(menuCoordinator)
            guard let selection = result as? MenuSelection else { return }
            
            switch selection {
            case .saveVoice:
                ()
            case .sendFeedback:
                self.showSendFeedback()
            case .selectVoice:
                self.showSelectVoice()
            }
        }
        
        menuCoordinator.start()
    }
    
    fileprivate func showSelectVoice() {
        let selectVoiceCoordinator = assembly.selectVoiceCoordinator
        addDependency(selectVoiceCoordinator)
        
        selectVoiceCoordinator.finishFlow = { result in
            self.removeDependency(selectVoiceCoordinator)
            guard let selection = result as? String else { return }
            
            self.ttsManager.select(voice: selection)
        }
        
        selectVoiceCoordinator.start()
    }
    
    fileprivate func showSendFeedback() {
        guard let screen = screenAssembly.sendFeedback() else { return }
        router.push(screen)
    }

    func finish() {
        finishFlow!("sss")
    }

    // MARK: - ChatCollectionDelegate
    func didSelect(_ chat: Chat) {
        let text = chat.text
        mainVC.set(inputText:text)
    }

    // MARK: - CategoryManagerDelegate
    func willAddNewCategory(_ complition: @escaping allertReturn) {
        mainVC.showGetNewCategoryName(complition)
    }
    
    func didSelect(_ category: Category) {
        messageManager.category = category
    }
    func didDelete(_ category:Category) {
    }
    
    func willRename(_ category:Category, complition: @escaping allertReturn) {
        mainVC.showRename(category, block: complition)
    }
    
    // MARK: - MessageManagerDelegate
    func currentCategory() -> Category {
        return categoryManager.currentCategory
    }
    
    func didSelect(_ message: Message) {
        self.speak(message.text)
    }

    func willAddNewMessage(for category:Category, complition: @escaping allertReturn) {
        mainVC.showGetNewMessageName(complition)
    }
    
    func didDelete(_ message:Message) {
    }
    func willRename(_ message:Message, complition: @escaping allertReturn) {
        mainVC.showRename(message, block: complition)
    }
    
    // MARK: - Private
    fileprivate func currentChat() -> Chat {
        let index = chatCollection.selectedIndex
        return DB.chats[index]
    }
}

