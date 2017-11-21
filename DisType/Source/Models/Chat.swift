//
//  Chat.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/20/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import RealmSwift

class Chat: Object {
    @objc dynamic var name = ""
    @objc dynamic var id = NSUUID().uuidString
}
