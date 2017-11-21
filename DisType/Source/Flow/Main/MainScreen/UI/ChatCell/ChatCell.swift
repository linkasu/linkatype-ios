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
    static let id = String(describing:ChatCell.self)
    
    @IBOutlet weak var title: UILabel!
    
    override var isSelected: Bool {
        didSet {
            print(title.text!, " selected=\(isSelected)")
            title.textColor = isSelected ? UIColor.white : UIColor.lightGray
        }
    }

    override var isHighlighted: Bool {
        didSet {
            print(title.text!, " highlighted=\(isHighlighted)")
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = self.isHighlighted ? UIColor.white : UIColor.dtBlue
            }
        }
    }
}
