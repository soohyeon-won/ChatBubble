//
//  StringEx.swift
//  
//
//  Created by Eric JI on 2019/11/25.
//  Copyright © 2019 Eric JI. All rights reserved.
//

import Foundation

extension String {
    
    var withWhitespacesAndNewlines: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
