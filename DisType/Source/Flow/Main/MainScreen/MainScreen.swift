/*-
 * Copyright © 2016  Alex Makushkin
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
//
//  MainScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//

import Foundation
import UIKit


class MainScreen: UIViewController, UITextViewDelegate {
    fileprivate var allertReturnBlock: allertReturn?
    
    var alertVC: UIAlertController?

    var delegate:HomeDelegate?
    var chatDelegate:ChatCollection!
    var categoryDelegate:CategoryManager!
    var messageDelegate:MessageManager!
    
    var currentChat: Chat {
        let index = chatCollectionView.indexPathsForSelectedItems![0].row
        return DB.chats[index]
    }
    
    lazy var singleInputTextLineHeight: CGFloat = {
        return inputTextHeight.constant
    }()

    lazy var allertCloseGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(hideAlert))
    }()

    @IBOutlet weak var menuSourceView: UIView!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var sayButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputTextHeight: NSLayoutConstraint!

    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSayButton()
        setupTextView()
        setupChatCollectionView()
        setupCategoryTableView()
        setupMessageTableView()
        setupTableMenu()
    }
    
    // MARK: - Setup
    fileprivate func setupTableMenu() {
        let deleteMenuItem = UIMenuItem(title: "Удалить", action: #selector(CategoryCell.delete(row:)))
        let renameMenuItem = UIMenuItem(title: "Переименовать", action: #selector(CategoryCell.rename(row:)))
        UIMenuController.shared.menuItems = [deleteMenuItem, renameMenuItem]
        UIMenuController.shared.update()
    }
    

    fileprivate func setupMessageTableView() {
        messageTableView.delegate = messageDelegate
        messageTableView.dataSource = messageDelegate
    }

    fileprivate func setupCategoryTableView() {
        categoryTableView.delegate = categoryDelegate
        categoryTableView.dataSource = categoryDelegate
    }

    fileprivate func setupChatCollectionView() {
        chatCollectionView.delegate = chatDelegate
        chatCollectionView.dataSource = chatDelegate
    }

    fileprivate func setupSayButton() {
        sayButton.corner(radius: 4, width: 0)
    }

    fileprivate func setupTextView() {
        inputTextView.delegate = self
        inputTextView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }

    fileprivate func showAllert(named name:String, withPreFilled text:String = "", buttonText:String = "", block:@escaping allertReturn) {
        allertReturnBlock = block
        alertVC = UIAlertController(title: name, message: nil, preferredStyle: .alert)
        alertVC?.addTextField(configurationHandler: { textField in
            guard text != "" else { return }
            textField.text = text
            textField.selectAll(nil)
        })
        alertVC?.addAction(UIAlertAction(title: buttonText, style: .default, handler: { (action) in
            self.hideAlert()
            guard
                let textField = self.alertVC?.textFields?[0],
                let text = textField.text
                else { return }
            
            block(text)
        }))
        
        present(alertVC!, animated: true, completion: {
            self.alertVC?.view.superview?.addGestureRecognizer(self.allertCloseGesture)
        })
    }
    
    @objc fileprivate func hideAlert() {
        alertVC?.view.superview?.removeGestureRecognizer(self.allertCloseGesture)
        alertVC?.dismiss(animated: true, completion: {
            guard let block = self.allertReturnBlock else { return }
            block("")
        })
    }

    // MARK: - Public
    func set(inputText:String) {
        UIView.animate(withDuration: 0.2) {
            self.inputTextView.text = inputText
        }
    }
    
    func showGetNewCategoryName(_ block:@escaping allertReturn) {
        showAllert(named: "Введите имя новой категории", buttonText:"Добавить", block: block)
    }
    
    func showGetNewMessageName(_ block:@escaping allertReturn) {
        showAllert(named: "Введите новое высказывание",  buttonText:"Добавить", block: block)
    }

    func showRename(_ category:Category, block:@escaping allertReturn) {
        showAllert(named: "Переименуйте категорию",
                   withPreFilled:category.name,
                   buttonText:"Обновить",
                   block: block)
    }
    
    func showRename(_ message:Message, block:@escaping allertReturn) {
        showAllert(named: "Переименуйте высказывание",
                   withPreFilled:message.text,
                   buttonText:"Обновить",
                   block: block)
    }
    
    // MARK: - Actions
    @IBAction func deleteChatAction(_ sender: UIBarButtonItem) {
        guard let collection = self.chatCollectionView else { return }
        guard let indexPathes = collection.indexPathsForSelectedItems else { return }

        delegate?.deleteCurrentChat { newSelectedIndexPath in
            collection.deleteItems(at: indexPathes)
            collection.reloadItems(at: [newSelectedIndexPath])
        }
    }
    @IBAction func addChatAction(_ sender: UIBarButtonItem) {
        delegate?.addNewChat()
    }

    @IBAction func clearInputAction(_ sender: UIBarButtonItem) {
        inputTextView.text = ""
    }
    
    @IBAction func toneSignalAction(_ sender: UIBarButtonItem) {
        delegate?.beepSound()
    }
    
    @IBAction func menuAction(_ sender: Any) {
        delegate?.showMenu()
    }
    
    @IBAction func speakInputAction(_ sender: Any) {
        guard let text = inputTextView.text else {return}
        let languageCode = inputTextView.textInputMode?.primaryLanguage
        delegate?.speak(text, with:languageCode)
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text
        delegate?.chatTextDidChanged(text)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let result = text=="\n"
        result ? speakInputAction(textView) : ()
        
        return true && !result
    }
    
    // MARK: - Observations
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentSize", let textView = object as? UITextView else { return }

        let contentHeight = textView.contentSize.height
        let inputBarHeight = textView.bounds.size.height

        //Center vertical alignment
        var topCorrect = (inputBarHeight - contentHeight * textView.zoomScale) / 2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        textView.contentOffset = CGPoint(x: 0, y: -topCorrect)
        inputTextHeight.constant = textView.contentSize.height;
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}
