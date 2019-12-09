//
//  ChatSentView.swift
//  ChatBubble
//
//  Created by Eric JI on 2019/11/26.
//  Copyright © 2019 Eric JI. All rights reserved.
//

import UIKit

protocol ChatSentViewDelegate: class {
    func ChatSentDidResize(chatSentView: ChatSentView)
    func ChatSent(chatSentView: ChatSentView, didSendMessage message: String)
}

class ChatSentView: UIView {
    
    weak var delegate: ChatSentViewDelegate?
    
    // MARK: Private Properties
    
    let textView = ChatEditView(frame: .zero, textContainer: nil)
    private let sendButton = UIButton(type: .system)
    private let blurredBackgroundView: UIToolbar = UIToolbar()
    private var textHeightConstraint: NSLayoutConstraint!
    private var sendButtonHeightConstraint: NSLayoutConstraint!
    
    // MARK: Initialization
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.setup()
        self.stylize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupSendButton()
        self.setupSendButtonConstraints()
        self.setupTextView()
        self.setupTextViewConstraints()
    }
    
    func setupTextView() {
        textView.bounds = self.bounds.inset(by: UIEdgeInsets.padding)
        textView.inputViewDelegate = self
        textView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        self.styleTextView()
        self.addSubview(textView)
    }
    
    func styleTextView() {
        textView.layer.rasterizationScale = UIScreen.main.scale
        textView.tintColor = UIColor.red
        textView.layer.shouldRasterize = true
        textView.layer.cornerRadius = 15.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
    }
    
    func setupSendButton() {
        
        self.sendButton.isEnabled = false
        
        let buttonTitle = "Send"
        self.sendButton.setAttributedTitle(NSAttributedString(string: buttonTitle, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.red]), for: .normal)
        self.sendButton.addTarget(self, action: #selector(self.onTapSentButton(sender:)), for: .touchUpInside)
        self.sendButton.bounds = CGRect(x: 0, y: 0, width: 40, height: 1)
        self.addSubview(sendButton)
    }
    
    func setupSendButtonConstraints() {
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        sendButtonHeightConstraint = sendButton.heightAnchor.constraint(equalToConstant: 30)
        NSLayoutConstraint.activate([
            sendButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -UIEdgeInsets.padding.right),
            sendButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -UIEdgeInsets.padding.bottom),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButtonHeightConstraint
        ])
        
    }
    
    func setupTextViewConstraints() {
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        
        textHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: UIEdgeInsets.padding.top),
            textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: UIEdgeInsets.padding.left),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -UIEdgeInsets.padding.bottom),
            textView.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -UIEdgeInsets.padding.right),
            textHeightConstraint
        ])

    }
    
    // MARK: Styling
    
    func stylize() {
        self.textView.backgroundColor = UIColor.white
        self.textView.font = UIFont.textDefaultFont
        self.textView.textColor = UIColor.darkText
        self.blurredBackgroundView.isHidden = false
        self.backgroundColor = UIColor.clear
    }
    
    // MARK: Reset
    
    func reset() {
        self.textView.resignFirstResponder()
    }
    
    // MARK: Action
    
    @objc private func onTapSentButton(sender: UIButton) {
        if self.textView.text.count > 0 {
            self.delegate?.ChatSent(chatSentView: self, didSendMessage: self.textView.text)
            self.textView.text = ""
        }
    }
    
}

extension ChatSentView: ChatEditViewDelegate {
    
    func chatEditTextViewDidChangeSize(_ textView: ChatEditView) {
        let textViewHeight = textView.bounds.height
        if textView.text.count == 0 {
            self.sendButtonHeightConstraint.constant = textViewHeight
        }
        self.textHeightConstraint.constant = textViewHeight
        self.delegate?.ChatSentDidResize(chatSentView: self)
    }
    
    func chatEdit(_ isValid: Bool) {
        self.sendButton.isEnabled = isValid
    }
    
}

// MARK: - Const

fileprivate extension UIFont {
    static let textDefaultFont = UIFont.systemFont(ofSize: 22)
}

fileprivate extension UIEdgeInsets {
    static let padding = UIEdgeInsets(top: 10, left: 15, bottom: 12, right: 10)
}
