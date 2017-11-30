//
//  SelectVoiceScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/30/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

protocol SelectVoiceScreenDelegate {
    func voices() -> [String]
    func selectedVoiceName() -> String
    func didSelect(_ voiceName:String)
}

class SelectVoiceScreen: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate:SelectVoiceScreenDelegate?
    
    fileprivate var voices:[String] = []
    fileprivate var selectedVoiceName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        voices = delegate?.voices() ?? []
        selectedVoiceName = delegate?.selectedVoiceName() ?? ""
        
        preferredContentSize = CGSize(width: 400, height: 44 * voices.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectVoiceCell", for: indexPath)
        
        let name = voices[indexPath.row]
        cell.textLabel?.text = name
        cell.isSelected = (name == selectedVoiceName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(voices[indexPath.row])
        tableView.cellForRow(at: indexPath)?.isSelected = true
    }
    
}
