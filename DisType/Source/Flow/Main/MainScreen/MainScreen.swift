//
//  MainScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
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

    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var sayButton: UIButton!
    
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
//        alertVC?.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { alertAction in
//            self.hideAlert()
//        }))
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
        delegate?.deleteCurrentChat { newSelectedIndexPath in
            guard let collection = self.chatCollectionView else { return }
            guard let indexPathes = collection.indexPathsForSelectedItems else {return}
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
    }
    @IBAction func speakInputAction(_ sender: Any) {
        guard let text = inputTextView.text else {return}
        let languageCode = inputTextView.textInputMode?.primaryLanguage
        delegate?.speak(text, with:languageCode)
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text
        delegate?.updateCurrentChat(text)
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
