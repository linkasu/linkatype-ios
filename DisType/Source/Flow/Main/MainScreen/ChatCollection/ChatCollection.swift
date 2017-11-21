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
        delegate.didSelect(DB.chats[indexPath.row])
    }
}
