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
    let realm = try! Realm()
    
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
}
