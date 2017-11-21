//
//  ChatCell.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/20/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

class ChatCell: UICollectionViewCell {
    static let id = String(describing:ChatCell.self) //NSStringFromClass(ChatCell.self)
    
    @IBOutlet weak var title: UILabel!
}
