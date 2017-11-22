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

protocol CategoryManagerDelegate {
    func didSelect(_ category:Category)
    func addNewCategory()
}

class CategoryManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    fileprivate let delegate:CategoryManagerDelegate
    fileprivate var selectedIndexPath:IndexPath
    fileprivate var tableView:UITableView?
    
    var currentCategory:Category {
        return DB.categories[selectedIndexPath.row]
    }
    
    var categoriesCount:Int {
        return DB.categories.count + StaticCategoryCells.total.rawValue
    }
    
    init(delegate:CategoryManagerDelegate) {
        self.delegate = delegate
        selectedIndexPath = IndexPath(row:0, section:0)
        super.init()
    }
    
    // MARK: - Public
    func updateLastRow() {
        let indexPath = IndexPath(row: categoriesCount - 1, section: 0)
//        tableView?.performBatchUpdates({
            tableView?.insertRows(at: [indexPath], with: .fade)
//        }, completion: nil)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return categoriesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let text:String
        let index = indexPath.row

        if index == DB.categories.count {
            text = StaticCategoryCells.addCategory.text
        } else {
            text = DB.categories[index].name
        }
//        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        cell.textLabel?.text = text
        return cell
    }
    
}
