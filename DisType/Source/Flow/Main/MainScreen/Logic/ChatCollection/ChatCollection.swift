//
//  ChatCollection.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

protocol ChatCollectionDelegate {
    func didSelect(_ chat:Chat)
}

class ChatCollection: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    let delegate:ChatCollectionDelegate
    var collectionView:UICollectionView?
    
    var selectedIndexPath:IndexPath {
        didSet { selectedIndex = selectedIndexPath.row }
    }
    
    var selectedIndex:Int = 0 {
        didSet { delegate.didSelect(DB.chats[selectedIndex]) }
    }
    
    init(delegate:ChatCollectionDelegate) {
        self.delegate = delegate
        selectedIndexPath = IndexPath(row:0, section:0)
        super.init()
    }
    
    // MARK: - Public
    func updateLastCell() {
        let indexPath = IndexPath(row: DB.chats.count - 1, section: 0)
        collectionView?.performBatchUpdates({
            collectionView?.insertItems(at: [indexPath])
        }, completion: nil)
    }
    
    func updateSelectedIndex() {
        let chatsCount = DB.chats.count
        guard selectedIndex >= chatsCount  else { return }
        
        selectedIndexPath = IndexPath(row:chatsCount - 1, section:0)
    }
    
    // MARK: - Private
    fileprivate func selectCell(at collectionView:UICollectionView) {
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredVertically)
        delegate.didSelect(DB.chats[selectedIndex])
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView = collectionView
        let chatsCount =  DB.chats.count
        updateSelectedIndex()
        return chatsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ChatCell.id, for: indexPath) as? ChatCell else { return UICollectionViewCell()}
        cell.title.text = DB.chats[indexPath.row].name
        cell.isSelected = (selectedIndexPath == indexPath)
        if (selectedIndexPath == indexPath) {
            selectCell(at: collectionView)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
}
