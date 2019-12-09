//
//  DateEx.swift
//
//
//  Created by Eric JI on 2019/11/26.
//  Copyright © 2019 Eric JI. All rights reserved.
//

import Foundation

extension Date {
    
    var timeString: String {
        let formatter = DateFormatter()
        let language = Bundle.main.preferredLocalizations.first! as String
        formatter.locale = Locale(identifier: language)
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
    
}

