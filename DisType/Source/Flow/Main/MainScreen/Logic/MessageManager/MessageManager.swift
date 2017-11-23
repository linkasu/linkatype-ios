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
            messages = DB.messages(for: category)
            UIView.animate(withDuration: 0.1) {
                self.tableView?.reloadData()
            }
        }
    }
    
    var messages: Results<Message>?
    
    var messagesCount:Int {
        let count = (messages?.count == nil) ? 0 : messages!.count
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
   
    fileprivate func delete(row:Int) {
        guard UIMenuController.shared.isMenuVisible,
            let message = messages?[row]
            else { return }
        DB.delete(message)
        tableView?.deleteRows(at: [IndexPath(row:row, section:0)], with: .fade)
//        delegate.didDelete(message)
    }
    fileprivate func rename(row:Int){
        guard UIMenuController.shared.isMenuVisible,
            let message = messages?[row]
            else { return }
        tableView?.reloadRows(at: [IndexPath(row:row, section:0)], with: .fade)
        delegate.didRename(message)
    }
    
    // MARK: - Public
    func update(_ message:Message) {
        guard let index = messages?.index(of: message) else { return }
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
            text = messages?[index].text ?? ""
        }
        
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case lastIndex :
            delegate.addNewMessage(for:category)
        default:
            guard let message = messages?[indexPath.row] else { return }
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
