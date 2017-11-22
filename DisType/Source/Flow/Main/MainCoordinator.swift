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

protocol HomeDelegate {
    func didEntered(_ text:String)
    func speak(_ text:String, with languageCode:String?)
    func addNewChat()
    func updateCurrentChat(_ _text:String?)
    func deleteCurrentChat(_ complition: @escaping (IndexPath)->())
    func finish()
}

class MainCoordinator: BaseCoordinator, HomeDelegate, Coordinator, CoordinatorOutput, ChatCollectionDelegate, CategoryManagerDelegate, MessageManagerDelegate {

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
    
    func finish() {
        finishFlow!("sss")
    }

    // MARK: - ChatCollectionDelegate
    func didSelect(_ chat: Chat) {
        print("\(chat.name) selected")
        let text = chat.text
        mainVC.set(inputText:text)
    }

    func addNewCategory() {
        mainVC.showGetNewCategoryName {
            let category = Category()
            category.name = $0
            DB.add(category)
            self.categoryManager.updateLastRow()
        }
    }
    
    // MARK: - CategoryManagerDelegate
    func didSelect(_ category: Category) {
    }
    // MARK: - MessageManagerDelegate
    func currentCategory() -> Category {
        return categoryManager.currentCategory
    }
    
    func didSelect(_ message: Message) {
        self.speak(message.text)
    }

    func addNewMessage() {
        
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

