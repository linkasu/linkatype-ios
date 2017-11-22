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
    func addNewCategory()
    func addNewMessage(to category:Category)
    func updateCurrentChat(_ _text:String?)
    func deleteCurrentChat(_ complition: @escaping ()->())
    func finish()
}

class MainCoordinator: BaseCoordinator, HomeDelegate, Coordinator, CoordinatorOutput, ChatCollectionDelegate {
    var finishFlow: ((Any) -> Void)?
    
    fileprivate let router: Router
    fileprivate let assembly:AssemblyCoordinator
    fileprivate let screenAssembly: AssemblyScreen
    
    fileprivate lazy var chatCollection:ChatCollection = {
        let chatCollection = ChatCollection(delegate:self)
        return chatCollection
    }()
    
    fileprivate lazy var mainVC:MainScreen = {
        let vc = self.screenAssembly.mainScreen(delegate:self, chatCollection:chatCollection)
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
    
    func speak(_ text: String, with languageCode:String?) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    func addNewChat() {
        DB.addNewChat()
    }
    
    func addNewCategory() {
        
    }
    
    func addNewMessage(to category: Category) {
        
    }
    
    func updateCurrentChat(_ _text:String?) {
        let text = _text ?? ""
        currentChat().update(text:text)
    }
    
    func deleteCurrentChat(_ complition: @escaping ()->()) {
        let chat = currentChat()
        guard let index = DB.chats.index(of:chat), index >= 3 else { return }
        DB.delete(chat)
        complition()
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

