/*-
 * Copyright © 2016  Alex Makushkin
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
//
//  TTSManager.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/30/17.
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
