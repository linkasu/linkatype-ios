//
//  Feedback.swift
//  DisType
//
//  Created by Mike Kholomeev on 12/12/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import Alamofire

class Feedback {
   
    let feedbackURL = "http://feedback.aacidov.ru"
    
    func send(text:String, to email:String) {
        var params:Parameters = [:]
        
        params["email"] = email
        params["text"] = text
        params["app"] = "distype"
        
        let start = CACurrentMediaTime()
        
        Alamofire.request(feedbackURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            let end = CACurrentMediaTime()
            let elapsedTime = end - start

            switch response.result {
            case .success:
                print(response)
                
                break
            case .failure(let error):
                
                print(error)
            }
        }
    }
}
