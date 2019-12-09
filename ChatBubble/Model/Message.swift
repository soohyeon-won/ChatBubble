//
//  Message.swift
//  ChatBubble
//
//  Created by Eric JI on 2019/12/09.
//  Copyright © 2019 ericji. All rights reserved.
//

import Foundation

enum MessageType: Int, Codable {
    case sent = 0
    case received
}

struct Message: Codable {

    let content: String
    let messageType: MessageType
    let time: String

    init(content: String, messageType: MessageType, time: String){
        self.messageType = messageType
        self.content = content.withWhitespacesAndNewlines
        self.time = time
    }

    enum CodingKeys: String, CodingKey {
        case content
        case messageType
        case time
    }
    
}
