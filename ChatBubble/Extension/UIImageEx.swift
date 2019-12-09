//
//  UIImageEx.swift
//  
//
//  Created by Eric JI on 2019/11/26.
//  Copyright © 2019 Eric JI. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeForBubble() -> UIImage {
        
        let edge = UIEdgeInsets(top: 15, left: 21, bottom: 15, right: 21)
        
        let resizeImage = self.resizableImage(withCapInsets: edge, resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
        
        return resizeImage
    }
    
}
