//
//  FeedbackScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 12/12/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

protocol FeedbackCoordinatorDelegate {
    func didSend(text:String, to email:String?)
    func didCloseScreen()
}

class FeedbackScreen: UIViewController {

    var delegate: FeedbackCoordinatorDelegate?
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var textTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.corner()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.didCloseScreen()
    }
    
    @IBAction func send(_ sender: Any) {
        delegate?.didSend(text:textTextView.text, to:emailTextField.text)
    }

}
