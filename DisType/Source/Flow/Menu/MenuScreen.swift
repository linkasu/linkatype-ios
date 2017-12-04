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
//  MenuScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/29/17.
//

import Foundation
import UIKit

protocol MenuScreenDelegate {
    func isUseInternet() -> Bool
    func isSpeakEveryWord() -> Bool
    func saveVoice()
    func sendFeedback()
    func selectVoice()
    func useInternetToggle(_ value:Bool)
    func speakAfterEveryWordToggle(_ value:Bool)
}

class MenuScreen: UIViewController {
    
    var delegate:MenuScreenDelegate?
    
    @IBOutlet weak var useInternetButton: UIButton!
    @IBOutlet weak var useInternetCheckBox: UIButton!
    @IBOutlet weak var speakAfterEveryWordButton: UIButton!
    @IBOutlet weak var speakAfterEveryWordCheckBox: UIButton!
    @IBOutlet weak var screenHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIApplication.shared.delegate?.window??.bounds.width
        preferredContentSize = CGSize(width:width!, height:screenHeightConstraint.constant)
    }

    override func viewWillAppear(_ animated: Bool) {
        speakAfterEveryWordCheckBox.isSelected = delegate!.isSpeakEveryWord()
        super.viewWillAppear(animated)
    }

    // MARK: - Actions
    @IBAction func saveVoice(_ sender: Any) {
        delegate?.saveVoice()
    }
    @IBAction func sendFeedback(_ sender: Any) {
        delegate?.sendFeedback()
    }
    @IBAction func selectVoice(_ sender: Any) {
        delegate?.selectVoice()
    }
    @IBAction func useInternetToggle(_ sender: Any) {
        useInternetCheckBox.isSelected = !useInternetCheckBox.isSelected
        delegate?.useInternetToggle(useInternetCheckBox.isSelected)
    }
    @IBAction func speakAfterEveryWordToggle(_ sender: Any) {
        speakAfterEveryWordCheckBox.isSelected = !speakAfterEveryWordCheckBox.isSelected
        delegate?.speakAfterEveryWordToggle(speakAfterEveryWordCheckBox.isSelected)
    }
}
