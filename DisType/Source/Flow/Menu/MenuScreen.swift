//
//  MenuScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/29/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIApplication.shared.delegate?.window??.bounds.width
        preferredContentSize = CGSize(width:width!, height:230)
    }

    override func viewWillAppear(_ animated: Bool) {
        useInternetCheckBox.isSelected = delegate!.isUseInternet()
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
