//
//  CategoryManager.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

enum StaticCategoryCells:Int {
    case addCategory, total
    
    var text:String {
        switch self {
        case .addCategory:
            return "Добавить категорию"
        case .total:
            return ""
        }
    }
}


class CategoryManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    fileprivate let delegate:CategoryManagerDelegate
    fileprivate var tableView:UITableView?

    fileprivate var selectedIndexPath:IndexPath {
        didSet {
            performSelection()
        }
    }
    
    var currentCategory:Category {
        return DB.categories[selectedIndexPath.row]
    }
    
    var categoriesCount:Int {
        return DB.categories.count + StaticCategoryCells.total.rawValue
    }
    
    var lastIndex:Int {
        return categoriesCount - 1
    }
    
    init(delegate:CategoryManagerDelegate) {
        self.delegate = delegate
        selectedIndexPath = IndexPath(row:0, section:0)
        
        super.init()
    }

    fileprivate func performSelection() {
        switch selectedIndexPath.row {
        case lastIndex :
            delegate.addNewCategory()
        default:
            let category = DB.categories[selectedIndexPath.row]
            delegate.didSelect(category)
        }
    }

    fileprivate func delete(row:Int) {
        guard UIMenuController.shared.isMenuVisible else { return }
        let category = DB.categories[row]
        DB.delete(category)
        tableView?.deleteRows(at: [IndexPath(row:row, section:0)], with: .fade)
        if selectedIndexPath.row == categoriesCount {
            selectedIndexPath = IndexPath(row:lastIndex, section:0)
        }
        
        performSelection()
    }
    
    fileprivate func rename(row:Int){
        guard UIMenuController.shared.isMenuVisible else { return }
        let category = DB.categories[row]
        delegate.willRename(category) { name in
            DB.update(category, text: name)
            self.tableView?.reloadRows(at: [IndexPath(row:row, section:0)], with: .fade)
        }
    }

    // MARK: - Public
    func update(_ category:Category) {
        guard let index = DB.categories.index(of: category) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        tableView?.insertRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return categoriesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.id, for: indexPath)
        
        let text:String
        let index = indexPath.row

        if index == DB.categories.count {
            text = StaticCategoryCells.addCategory.text
        } else {
            text = DB.categories[index].name
        }
        
        if (selectedIndexPath == indexPath) {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            self.tableView(tableView, didSelectRowAt: indexPath)
        }

        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < lastIndex - 1
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(CategoryCell.delete(row:)) {
            delete(row: indexPath.row)
        } else if action == #selector(CategoryCell.rename(row:)) {
            rename(row: indexPath.row)
        } else { return false}
        
        return true
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
    }
}
