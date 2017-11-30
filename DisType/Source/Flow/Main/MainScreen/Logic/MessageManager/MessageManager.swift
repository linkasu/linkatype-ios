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


class MessageManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    let delegate:MessageManagerDelegate
    var tableView:UITableView?
    var category:Category {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.tableView?.reloadData()
            }
        }
    }
    
    var messages: List<Message> {
        return category.messages
    }
    
    var messagesCount:Int {
        let count = messages.count
        return count + StaticMessageCells.total.rawValue
    }
    
    var lastIndex:Int {
        return messagesCount - 1
    }
    
    init(delegate:MessageManagerDelegate) {
        self.delegate = delegate
        category = delegate.currentCategory()
        super.init()
    }
    
    // MARK: - Private
    fileprivate func addMessage(with text:String) {
        let message = Message()
        message.text = text
        DB.add(message, to:category)
        update(message)
    }

    fileprivate func delete(row:Int) {
        guard UIMenuController.shared.isMenuVisible
            else { return }
        let message = messages[row]
        DB.delete(message)
        tableView?.deleteRows(at: [IndexPath(row:row, section:0)], with: .fade)
    }
    
    fileprivate func rename(row:Int){
        guard UIMenuController.shared.isMenuVisible
            else { return }
        let message = messages[row]
        delegate.willRename(message) { name in
            DB.update(message, text: name)
            self.tableView?.reloadRows(at: [IndexPath(row:row, section:0)], with: .fade)
        }
    }
    
    fileprivate func update(_ message:Message) {
        guard let index = messages.index(of: message) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        tableView?.insertRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return messagesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        let text:String
        let index = indexPath.row

        switch index {
        case lastIndex:
            text = StaticMessageCells.addMessage.text
        default:
            text = messages[index].text
        }
        
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case lastIndex :
            delegate.willAddNewMessage(for:category) { self.addMessage(with: $0) }
        default:
            let message = messages[indexPath.row]
            delegate.didSelect(message)
        }
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < lastIndex
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(MessageCell.delete(row:)) {
            delete(row: indexPath.row)
        } else if action == #selector(MessageCell.rename(row:)) {
            rename(row: indexPath.row)
        } else { return false}
        
        return true
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
    }
}
