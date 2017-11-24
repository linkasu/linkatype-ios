//
//  DataBase.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/20/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import RealmSwift

let DB = DataBase()

class DataBase {
    let minCategoriesCount = 1
    let categoryName = "Без категории"
    let minChatCount = 3
    let chatName = "ЧАТ"
    
    var realm :Realm { return try! Realm()}

    init() {
        let config = Realm.Configuration(schemaVersion: try! schemaVersionAtURL(Realm.Configuration.defaultConfiguration.fileURL!) + 1)
        Realm.Configuration.defaultConfiguration = config
        
        initDB()
    }
    
    fileprivate func initDB() {
        initChats()
        initCategories()
    }
    
    fileprivate func initCategories() {
        let categotiesCount = categories.count
        if categotiesCount < minCategoriesCount {
            var count = categotiesCount + minCategoriesCount
            while count <= minCategoriesCount {
                let category = Category()
                category.name = categoryName
                self.add(category)
                count += 1
            }
        }
    }
    
    fileprivate func initChats() {
        let chatsCount = self.chats.count
        if chatsCount < minChatCount {
            var count = chatsCount + 1
            while count <= minChatCount {
                let chat = Chat()
                chat.name = "\(chatName)\(count)"
                self.add(chat)
                count += 1
            }
        }
    }

    var chats: Results<Chat> {
        return realm.objects(Chat.self).sorted(byKeyPath: #keyPath(Chat.name))
    }
    
    var categories: Results<Category> {
        return realm.objects(Category.self).sorted(byKeyPath: #keyPath(Category.name))
    }
    
    func messages(for category:Category) -> Results<Message> {
        let messagesAll = realm.objects(Message.self)
        let messages = messagesAll.filter("%K = %@", #keyPath(Message.categoryId), category.id)
        return messages.sorted(byKeyPath: #keyPath(Message.text))
//            { (message) -> Bool in
//            message.category == category
//        })
    }
    
    // MARK: - Add
    func addNewChat() {
        let chat = Chat()
        chat.name = "\(chatName)\(DB.chats.count+1)"
        DB.add(chat)
    }
    
    func add(_ chat:Chat) {
        realm.beginWrite()
        realm.add(chat)
        try! realm.commitWrite()
    }

    func add(_ category:Category) {
        realm.beginWrite()
        realm.add(category)
        try! realm.commitWrite()
    }
    
    func add(_ message:Message) {
        realm.beginWrite()
        realm.add(message)
        try! realm.commitWrite()
    }
    
    // MARK: - Update
    func update(_ chat:Chat, text:String) {
        realm.beginWrite()
        chat.text = text
        try! realm.commitWrite()
    }
    func update(_ category:Category, text:String) {
        realm.beginWrite()
        category.name = text
        try! realm.commitWrite()
    }
    func update(_ message:Message, text:String) {
        realm.beginWrite()
        message.text = text
        try! realm.commitWrite()
    }

    // MARK: - Delete
    func delete(_ chat:Chat) {
        guard let index = DB.chats.index(of: chat), index > 2 else { return }
        realm.beginWrite()
        realm.delete(chat)
        try! realm.commitWrite()
    }

    func delete(_ category:Category) {
        let messages = self.messages(for: category)
        realm.beginWrite()
        realm.delete(messages)
        realm.delete(category)
        try! realm.commitWrite()
    }

    func delete(_ message:Message) {
        realm.beginWrite()
        realm.delete(message)
        try! realm.commitWrite()
    }
}
