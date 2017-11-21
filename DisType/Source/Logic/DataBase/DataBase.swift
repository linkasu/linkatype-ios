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
    let minChatCount = 3
    let chatName = "ЧАТ"
    
    let realm = try! Realm()

    init() {
        initDB()
    }
    
    fileprivate func initDB() {
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
        return realm.objects(Chat.self)
    }
    
    var categories: Results<Category> {
        return realm.objects(Category.self)
    }
    
    func messages(for category:Category) -> Results<Message> {
        return realm.objects(Message.self).filter("category = \(category)")
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
    
    // MARK: - Delete
    func delete(_ chat:Chat) {
        guard let index = DB.chats.index(of: chat), index > 2 else { return }
        realm.beginWrite()
        realm.delete(chat)
        try! realm.commitWrite()
    }

    func delete(_ category:Category) {
        realm.beginWrite()
        realm.delete(category)
        try! realm.commitWrite()
    }

    func delete(_ message:Message) {
        realm.beginWrite()
        realm.delete(message)
        try! realm.commitWrite()
    }
}
