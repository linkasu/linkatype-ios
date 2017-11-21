//
//  Message.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/20/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import RealmSwift

class Message: Object {
    @objc dynamic var text = ""
    @objc dynamic var category : Category? = nil
}
