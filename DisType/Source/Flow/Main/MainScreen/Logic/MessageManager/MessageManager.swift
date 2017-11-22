//
//  MessageTable.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

enum StaticMessageCells:Int {
    case addMessage, total
    
    var text:String {
        switch self {
        case .addMessage:
            return "Добавить высказывание"
        case .total:
            return ""
        }
    }
}

protocol MessageManagerDelegate {
    func currentCategory() -> Category
    func didSelect(_ message:Message)
}

class MessageManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    let delegate:MessageManagerDelegate
    var tableView:UITableView?
    
    var messages: Results<Message> {
        let category = delegate.currentCategory()
        let messages = DB.messages(for: category)
        return messages
    }
    
    var messagesCount:Int {
        return messages.count + StaticMessageCells.total.rawValue
    }
    
    init(delegate:MessageManagerDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        let text:String
        let index = indexPath.row
        if index == messages.count {
            text = StaticMessageCells.addMessage.text
        } else {
            text = messages[index].text
        }
        
        cell.textLabel?.text = text
        return cell
    }
}
