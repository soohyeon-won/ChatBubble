//
//  YjiChatInput.swift
//  YjiChatBubble
//
//  Created by 季 雲 on 2017/08/04.
//  Copyright © 2017 Ericji. All rights reserved.
//

import UIKit

protocol YjiChatInputDelegate : class {
    func chatInputDidResize(_ chatInput: YjiChatInput, with height:CGFloat)
    func chatInput(_ chatInput: YjiChatInput, didSendMessage message: String)
}

class YjiChatInput: UIView {
    
    // MARK: Styling
    
    struct Appearance {
        static var includeBlur = true
        static var tintColor = UIColor(red: 0.0, green: 120 / 255.0, blue: 255 / 255.0, alpha: 1.0) // send button color
        static var backgroundColor = UIColor.white
        static var textViewFont = UIFont.systemFont(ofSize: 17.0)
        static var textViewTextColor = UIColor.darkText
        static var textViewBackgroundColor = UIColor.white
    }
    
    /*
     These methods are included for ObjC compatibility.  If using Swift, you can set the Appearance variables directly.
     */
    
    class func setAppearanceIncludeBlur(_ includeBlur: Bool) {
        Appearance.includeBlur = includeBlur
    }
    
    class func setAppearanceTintColor(_ color: UIColor) {
        Appearance.tintColor = color
    }
    
    class func setAppearanceBackgroundColor(_ color: UIColor) {
        Appearance.backgroundColor = color
    }
    
    class func setAppearanceTextViewFont(_ textViewFont: UIFont) {
        Appearance.textViewFont = textViewFont
    }
    
    class func setAppearanceTextViewTextColor(_ textColor: UIColor) {
        Appearance.textViewTextColor = textColor
    }
    
    class func setAppearanceTextViewBackgroundColor(_ color: UIColor) {
        Appearance.textViewBackgroundColor = color
    }
    
    // MARK: Public Properties
    
    var textViewInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    weak var delegate: YjiChatInputDelegate?
    
    // MARK: Private Properties
    
    public let textView = YjiStretchyTextView(frame: CGRect.zero, textContainer: nil)
    fileprivate let sendButton = UIButton(type: .system)
    let blurredBackgroundView: UIToolbar = UIToolbar()
    fileprivate var heightConstraint: NSLayoutConstraint!
    fileprivate var sendButtonHeightConstraint: NSLayoutConstraint!
    
    // MARK: Initialization
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        
        // send button 
        self.sendButton.isEnabled = false
        self.sendButton.setTitle("Send", for: UIControlState())
        self.sendButton.addTarget(self, action: #selector(YjiChatInput.sendButtonPressed(_:)), for: .touchUpInside)
        self.sendButton.bounds = CGRect(x: 0, y: 0, width: 40, height: 1)
        self.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(-5)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        
        // textView
        textView.bounds = UIEdgeInsetsInsetRect(self.bounds, self.textViewInsets)
        textView.stretchyTextViewDelegate = self
        textView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        textView.layer.rasterizationScale = UIScreen.main.scale
        textView.layer.shouldRasterize = true
        textView.layer.cornerRadius = 5.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        self.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.top.equalTo(5)
            make.bottom.equalTo(-5)
            make.right.equalTo(sendButton.snp.left).offset(-5)
        }
        
        self.addSubview(self.blurredBackgroundView)
        self.sendSubview(toBack: self.blurredBackgroundView)
        blurredBackgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        // Styling
        self.textView.backgroundColor = Appearance.textViewBackgroundColor
        self.sendButton.tintColor = Appearance.tintColor
        self.textView.tintColor = Appearance.tintColor
        self.textView.font = Appearance.textViewFont
        self.textView.textColor = Appearance.textViewTextColor
        self.blurredBackgroundView.isHidden = !Appearance.includeBlur
        self.backgroundColor = Appearance.backgroundColor
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Button Presses
    func sendButtonPressed(_ sender: UIButton) {
        if self.textView.text.characters.count > 0 {
            self.delegate?.chatInput(self, didSendMessage: self.textView.text)
            self.textView.text = ""
        }
    }
}

extension YjiChatInput: YjiStretchyTextViewDelegate {
    
    func stretchyTextViewDidChangeSize(_ textView: YjiStretchyTextView) {
        let textViewHeight = textView.bounds.height
        if textView.text.characters.count == 0 {
            sendButton.snp.updateConstraints({ (make) in
                make.height.equalTo(textViewHeight)
            })
        }
        let targetConstant = textViewHeight + textViewInsets.top + textViewInsets.bottom
        self.delegate?.chatInputDidResize(self, with: targetConstant)
    }
    
    func stretchyTextView(_ textView: YjiStretchyTextView, validityDidChange isValid: Bool) {
        self.sendButton.isEnabled = isValid
    }
}
