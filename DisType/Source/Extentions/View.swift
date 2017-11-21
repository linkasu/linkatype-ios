//
//  View.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func corner(radius:CGFloat = 5, color:UIColor = UIColor.white, width:CGFloat = 0.5) {
        layer.cornerRadius = radius
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        clipsToBounds = true
    }
    
    func makeRound() {
        self.layer.cornerRadius = frame.size.width/2
    }
}

