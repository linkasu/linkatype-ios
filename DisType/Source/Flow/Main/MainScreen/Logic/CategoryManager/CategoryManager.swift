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
    
    var currentCategory:Category
//    {
//        return DB.categories[selectedIndexPath.row]
//    }
    
    var rowsCount:Int {
        return DB.categories.count + StaticCategoryCells.total.rawValue
    }
    
    let firstRowIndex:Int = 0
    var lastRowIndex:Int {
        return rowsCount - 1
    }
    
    init(delegate:CategoryManagerDelegate) {
        self.delegate = delegate
        selectedIndexPath = IndexPath(row:0, section:0)
        currentCategory = DB.categories[selectedIndexPath.row]
        
        super.init()
    }

    // MARK: - Private
    fileprivate func performSelection() {
        switch selectedIndexPath.row {
        case lastRowIndex :
            delegate.willAddNewCategory { self.addCategory(named: $0) }
        default:
            let category = DB.categories[selectedIndexPath.row]
            delegate.didSelect(category)
            currentCategory = category
            tableView?.reloadRows(at: [selectedIndexPath], with: .fade)
        }
    }

    fileprivate func addCategory(named name:String) {
        let category = Category()
        category.name = name
        DB.add(category)
        currentCategory = category
        addTableRow(with:currentCategory)
    }

    fileprivate func delete(row:Int) {
        guard UIMenuController.shared.isMenuVisible else { return }
        let deleteCategory = DB.categories[row]
        DB.delete(deleteCategory)
        tableView?.deleteRows(at: [IndexPath(row:row, section:0)], with: .fade)

        let newSelectedIndex:Int
        if let currentCategoryIndex = DB.categories.index(of: currentCategory) {
            newSelectedIndex = currentCategoryIndex
        } else if selectedIndexPath.row >= lastRowIndex {
            newSelectedIndex = lastRowIndex - 1
        } else {
            newSelectedIndex = selectedIndexPath.row
        }
        
        selectedIndexPath = IndexPath(row:newSelectedIndex, section:0)
    }
    
    fileprivate func rename(row:Int){
        guard UIMenuController.shared.isMenuVisible else { return }
        let category = DB.categories[row]
        delegate.willRename(category) { name in
            DB.update(category, name: name)
            self.tableView?.reloadRows(at: [IndexPath(row:row, section:0)], with: .fade)
        }
    }

    fileprivate func addTableRow(with category:Category) {
        guard let index = DB.categories.index(of: category) else { assertionFailure("Category dissapeared!!");return }
        let indexPath = IndexPath(row: index, section: 0)
        tableView?.insertRows(at: [indexPath], with: .fade)
        selectedIndexPath = indexPath
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return rowsCount
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
        }

        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != lastRowIndex && indexPath.row != firstRowIndex
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if action == #selector(CategoryCell.delete(row:)) { delete(row: indexPath.row) }
        else if action == #selector(CategoryCell.rename(row:)) { rename(row: indexPath.row) }
        else { return false}
        
        return true
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
    }
}
