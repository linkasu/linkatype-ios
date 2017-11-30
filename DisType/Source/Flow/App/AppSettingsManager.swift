//
//  AppPreference.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/29/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import RealmSwift

class AppSettingsManager {
    var voiceId:String { return DB.settings.voiceId}
    var isUseInternet:Bool { return DB.settings.isUseInternet }
    var isSpeakEveryWord:Bool { return DB.settings.isSpeakEveryWord }

    
    // MARK: - Public
    func useInternet(_ value:Bool) {
        DB.update(useInternet: value)
    }
    func speakEveryWord(_ value:Bool) {
        DB.update(speakEveryWord: value)
    }

    func voiceId(_ _id:String) {
        DB.update(voiceId: _id)
    }
}
