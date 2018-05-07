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
//  SelectVoiceScreen.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/30/17.
//

import Foundation
import UIKit

protocol SelectVoiceScreenDelegate {
    func voicesNamesIDs() -> [String:String]
    func selectedVoiceName() -> String
    func didSelect(_ position: Int)
    func didCloseScreen()
}

class SelectVoiceScreen: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate:SelectVoiceScreenDelegate?
    
    fileprivate var voicesIDs:[String:String] = [:]
    fileprivate var selectedVoiceName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        voicesIDs = delegate?.voicesNamesIDs() ?? [:]
        selectedVoiceName = delegate?.selectedVoiceName() ?? ""
        let height = 44 * voicesIDs.count > 400 ? 400 : 44 * voicesIDs.count
        preferredContentSize = CGSize(width: 400, height: height)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.didCloseScreen()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voicesIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LanguageCell.id, for: indexPath) as? LanguageCell else { return UITableViewCell()}
        
        let name = Array(voicesIDs.keys)[indexPath.row]
        cell.textLabel?.text = name
        cell.isSelected = (name == selectedVoiceName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(indexPath.row)
        tableView.cellForRow(at: indexPath)?.isSelected = true
    }
    
}

class LanguageCell: UITableViewCell {
    static let id = String(describing:LanguageCell.self)
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}
