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
        print("\(chat.name) selected")
        let text = chat.text
        mainVC.set(inputText:text)
    }

    // MARK: - CategoryManagerDelegate
    func addNewCategory() {
        mainVC.showGetNewCategoryName { name in
            let category = Category()
            category.name = name
            DB.add(category)
            self.categoryManager.update(category)
        }
    }
    
    func didSelect(_ category: Category) {
        messageManager.category = category
    }
    func didDelete(_ category:Category) {
    }
    
    func willRename(_ category:Category, complition: @escaping (String)->()) {
        mainVC.showRename(category) { name in
            complition(name)
        }
    }
    
    // MARK: - MessageManagerDelegate
    func currentCategory() -> Category {
        return categoryManager.currentCategory
    }
    
    func didSelect(_ message: Message) {
        self.speak(message.text)
    }

    func addNewMessage(for category:Category) {
        mainVC.showGetNewMessageName { text in
            let message = Message()
            message.text = text
            message.categoryId = category.id
            DB.add(message)
            self.messageManager.update(message)
        }
    }
    
    func didDelete(_ message:Message) {
    }
    func willRename(_ message:Message, complition: @escaping (String)->()) {
        mainVC.showRename(message) { name in
            complition(name)
        }
    }
    
    // MARK: - Private
    func add(_ category: Category) {
        
    }
    
    func add(_ message: Message, to category: Category) {
        
    }
    
    fileprivate func currentChat() -> Chat {
        let index = chatCollection.selectedIndex
        return DB.chats[index]
    }
}

