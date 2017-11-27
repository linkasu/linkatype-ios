//
//  MainCoordinator.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

typealias allertReturn = (String)->()

class MainCoordinator: BaseCoordinator, HomeDelegate, Coordinator, CoordinatorOutput, ChatCollectionDelegate, CategoryManagerDelegate, MessageManagerDelegate {
    
    let systemSoundID: SystemSoundID = 1070
    var finishFlow: ((Any) -> Void)?
    
    fileprivate let router: Router
    fileprivate let assembly:AssemblyCoordinator
    fileprivate let screenAssembly: AssemblyScreen
    
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
    
    func speak(_ text: String, with languageCode:String? = "ru_RU") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    func addNewChat() {
        DB.addNewChat()
        chatCollection.updateLastCell()
    }
    
    func updateCurrentChat(_ _text:String?) {
        let text = _text ?? ""
        currentChat().update(text:text)
    }
    
    func deleteCurrentChat(_ complition: @escaping (IndexPath)->()) {
        let chat = currentChat()
        guard let index = DB.chats.index(of:chat), index >= 3 else { return }
        DB.delete(chat)
        complition(chatCollection.selectedIndexPath)
    }
    
    func beepSound() {
        AudioServicesPlayAlertSound(systemSoundID)
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

