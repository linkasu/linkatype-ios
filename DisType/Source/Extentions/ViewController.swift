//
//  ViewController.swift
//  DisType
//
//  Created by Mike Kholomeev on 11/17/17.
//  Copyright © 2017 NixSolutions. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController
{
    class func instantiateFromStoryboard() -> Self
    {
        return instantiateFromStoryboardHelper(type: self, storyboardName: String(describing: self))
    }
    
    class func instantiateFromStoryboard(storyboardName: String) -> Self
    {
        return instantiateFromStoryboardHelper(type: self, storyboardName: storyboardName)
    }
    
    private class func instantiateFromStoryboardHelper<T>(type: T.Type, storyboardName: String) -> T
    {
        //        var storyboardId = ""
        //        let components = "\(type(of: type))".components(separatedBy:".")
        //
        //        if components.count > 1
        //        {
        //            storyboardId = components[1]
        //        }
        
        let storyboad = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboad.instantiateViewController(withIdentifier: storyboardName) as! T
        
        return controller
    }
}
