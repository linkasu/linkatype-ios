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
//  ChatCollection.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
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
