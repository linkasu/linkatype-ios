//
//  ChatCollection.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

class ChatCollection: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    override init() {
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return DB.chats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ChatCell.id, for: indexPath) as? ChatCell else { return UICollectionViewCell()}
        cell.title.text = DB.chats[indexPath.row].name
        
        return UICollectionViewCell()
    }
}
