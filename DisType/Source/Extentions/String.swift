//
//  String.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/21/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation

extension String {
    var guessLanguage: String {
        let length = self.utf16.count
        let languageCode = CFStringTokenizerCopyBestStringLanguage(self as CFString, CFRange(location: 0, length: length)) as String? ?? ""
        
        let locale = Locale(identifier: languageCode)
        return locale.localizedString(forLanguageCode: languageCode) ?? "Unknown"
    }
    
    var language: String? {
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagScheme.language], options: 0)
        tagger.string = self
        return tagger.tag(at: 0, scheme: NSLinguisticTagScheme.language, tokenRange: nil, sentenceRange: nil).map { $0.rawValue }
    }
}
