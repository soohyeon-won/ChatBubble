//
//  MessageCell.swift
//  ChatBubble
//
//  Created by Eric JI on 2019/11/25.
//  Copyright © 2019 Eric JI. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    // max text size
    private var maxTextSize: CGSize {
        // Cell's width can take up to 3/4 of screen
        let maxWidth = self.bounds.width * 0.75
        let maxHeight = CGFloat.greatestFiniteMagnitude
        return CGSize(width: maxWidth, height: maxHeight)
    }
    
    private let sentTextView = BubbleView(messageType: .sent)
    private let receivedTextView = BubbleView(messageType: .received)
    private let sentTimeLabel = UILabel()
    private let receivedTimeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        sentTimeLabel.font = UIFont.time
        receivedTimeLabel.font = UIFont.time
        self.contentView.addSubview(sentTimeLabel)
        self.contentView.addSubview(receivedTimeLabel)

        self.contentView.addSubview(sentTextView)
        self.contentView.addSubview(receivedTextView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    func set(message: Message) -> CGSize {
        
        receivedTextView.isHidden = (message.messageType == .sent)
        sentTextView.isHidden = (message.messageType == .received)
        
        receivedTimeLabel.isHidden = (message.messageType == .sent)
        sentTimeLabel.isHidden = (message.messageType == .received)
                
        switch message.messageType {
        case .sent:
            return adjustSize(in: sentTextView, in: sentTimeLabel, with: message)
        case .received:
            return adjustSize(in: receivedTextView, in: receivedTimeLabel, with: message)
        }
        
    }
    
    // MARK: Update Size/Position
    
    private func adjustSize(in textView: BubbleView, in timeLabel: UILabel, with message: Message) -> CGSize {
        
        // time
        timeLabel.text = message.time
        timeLabel.sizeToFit()

        var cellSize = CGSize.zero
        textView.text = message.content
        cellSize = textView.sizeThatFits(maxTextSize)
        if cellSize.height < CGFloat.minimumHeight {
            cellSize.height = CGFloat.minimumHeight
        }
        textView.bounds.size = cellSize
        updateLayout(in: textView, in: timeLabel, type: message.messageType)
        return cellSize
    }
    
    private func updateLayout(in textView: BubbleView, in timeLabel: UILabel, type: MessageType) {
        
        // Handle the postion of the bubbles
        let halfTextViewWidth = textView.bounds.width / 2.0
        let halfTextViewHeight = textView.bounds.height / 2.0

        // calculate offset
        let leftCenterX = halfTextViewWidth + CGFloat.padding
        
        // set position of the bubbles
        textView.center.y = halfTextViewHeight
        textView.center.x = (type == .received) ? leftCenterX : self.bounds.width - leftCenterX
        
        // Handle the position of the time labels
        let timeLblOffset = textView.bounds.width + 2 * CGFloat.padding
        // time label size
        let timeLblWidth = timeLabel.bounds.width
        let timeLblHeight = timeLabel.bounds.height
        
        if type == .received {
            // time lable should appear after text view
            timeLabel.frame.origin.x = timeLblOffset
        } else {
            // time lable should appear before text view
            timeLabel.frame.origin.x = self.bounds.width - timeLblOffset - timeLblWidth
        }
        timeLabel.frame.origin.y = textView.bounds.height - timeLblHeight - CGFloat.padding

    }

}

// MARK: - Const
fileprivate extension CGFloat {
    
    static let padding: CGFloat = 5.0
    static let minimumHeight: CGFloat = 50.0
    
}

fileprivate extension UIFont {
    
    static let time = UIFont.systemFont(ofSize: 10)
    
}

