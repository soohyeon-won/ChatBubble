//
//  BubbleView.swift
//  ChatBubble
//
//  Created by Eric JI on 2019/11/26.
//  Copyright © 2019 Eric JI. All rights reserved.
//

import UIKit

class BubbleView: UITextView {

    private let bubble: UIImageView = UIImageView()

    override var bounds: CGRect {
        didSet {
            // update bubble imageview size
            bubble.frame = bounds
        }
    }
    
    init(messageType: MessageType, frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = UIFont.defaultFont
        self.textColor = UIColor.black
        self.isScrollEnabled = false
        self.isEditable = false
        self.layer.borderColor = UIColor.clear.cgColor
        
        switch messageType {
        case .received:
            self.textContainerInset = UIEdgeInsets.receivedTextInsets
        case .sent:
            self.textContainerInset = UIEdgeInsets.sentTextInsets
        }
        
        self.addSubview(bubble)
        sendSubviewToBack(bubble)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate extension UIFont {
    static let defaultFont = UIFont.systemFont(ofSize: 20.0)
}

fileprivate extension UIEdgeInsets {
    static let sentTextInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    static let receivedTextInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
}
