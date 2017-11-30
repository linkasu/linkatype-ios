//
//  TTSManager.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/30/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import AVFoundation

class TTSManager {
    fileprivate var languageCode:String? = "ru-RU"
    fileprivate let appPreference: AppSettingsManager
    
    var selectedVoice:AVSpeechSynthesisVoice? {
        didSet {
            appPreference.voiceId(selectedVoice!.identifier)
        }
    }

    
    init(appPreference: AppSettingsManager) {
        self.appPreference = appPreference
        
        let voiceId = appPreference.voiceId
        if let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
            selectedVoice = voice
        } else {
            let voices = AVSpeechSynthesisVoice.speechVoices()
            let voice = voices.filter({ $0.language == "ru-RU" }).first
            selectedVoice = voice
        }
    }

    func languageVoices() -> [AVSpeechSynthesisVoice] {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let languageVoices = voices.filter { $0.language == self.languageCode }
        
        return languageVoices
    }

    func voicesNames() -> [String] {
        let names = languageVoices().reduce([]) { (result, obj) -> [String] in
            var acc = result
            acc.append(obj.name)
            return acc
        }

        return names
    }
    
    func select(voice name:String) {
        guard let voice = languageVoices().filter({$0.name==name}).first else { return }
        selectedVoice = voice
    }
    
    func speak(_ text: String, with languageCode:String? = "ru_RU") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = selectedVoice
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
}
