//
//  Settings.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/29/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import RealmSwift

class Settings:Object {
    @objc dynamic var voiceId: String = ""
    @objc dynamic var isUseInternet: Bool = false
    @objc dynamic var isSpeakEveryWord: Bool = false
}
