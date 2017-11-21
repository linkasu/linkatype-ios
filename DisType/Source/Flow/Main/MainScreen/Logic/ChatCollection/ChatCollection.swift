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
    func willUnSelect(_ chat:Chat)
    func didSelect(_ chat:Chat)
}

class ChatCollection: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    let delegate:ChatCollectionDelegate
    var selectedIndex:Int = 0 {
        willSet{
            delegate.willUnSelect(DB.chats[selectedIndex])
        }
        
        didSet {
            delegate.didSelect(DB.chats[selectedIndex])
        }
    }
    
    init(with _delegate:ChatCollectionDelegate) {
        delegate = _delegate
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DB.chats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ChatCell.id, for: indexPath) as? ChatCell else { return UICollectionViewCell()}
        cell.title.text = DB.chats[indexPath.row].name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
}
