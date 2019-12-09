//
//  ChatEditView.swift
//  ChatBubble
//
//  Created by Eric JI on 2019/11/26.
//  Copyright © 2019 Eric JI. All rights reserved.
//

import UIKit

protocol ChatEditViewDelegate: class {
    func chatEditTextViewDidChangeSize(_ textView: ChatEditView)
    func chatEdit(_ isValid: Bool)
}

class ChatEditView: UITextView {
    
    weak var inputViewDelegate: ChatEditViewDelegate?
        
    var maxHeight: CGFloat {
        return UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait ? CGFloat.maxHeightPortrait : CGFloat.maxHeightLandScape
    }
    
    // MARK: Private Properties
    
    private let sizingTextView = UITextView()

    private var maxSize: CGSize {
        return CGSize(width: self.bounds.width, height: CGFloat.maxHeightPortrait)
    }

    
    // MARK: Property Overrides
    
    override var contentSize: CGSize {
        didSet {
            resize()
        }
    }
    
    override var font: UIFont! {
        didSet {
            sizingTextView.font = font
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            sizingTextView.textContainerInset = textContainerInset
        }
    }
    
    // MARK: Initializers
    
    override init(frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer);
        font = UIFont.textDefaultFont
        textContainerInset = UIEdgeInsets.textDefaultInsets
        self.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Sizing
    
    func resize() {
        bounds.size.height = self.targetHeight()
        inputViewDelegate?.chatEditTextViewDidChangeSize(self)
    }

    func targetHeight() -> CGFloat {
        
        sizingTextView.text = self.text
        let targetSize = sizingTextView.sizeThatFits(maxSize)
        let targetHeight = targetSize.height
        let maxHeight = self.maxHeight
        return targetHeight < maxHeight ? targetHeight : maxHeight
        
    }
    
    func updatePosition() {
        guard let end = self.selectedTextRange?.end else { return }
        
        let caretRect = self.caretRect(for: end)
        let topOfLine = caretRect.minY
        let bottomOfLine = caretRect.maxY
        
        let contentOffsetTop = self.contentOffset.y
        let bottomOfVisibleTextArea = contentOffsetTop + self.bounds.height
        
        /*
        If the caretHeight and the inset padding is greater than the total bounds then we are on the first line and aligning will cause bouncing.
        */
        
        let caretHeightPlusInsets = caretRect.height + self.textContainerInset.top + self.textContainerInset.bottom
        if caretHeightPlusInsets < self.bounds.height {
            var overflow: CGFloat = 0.0
            if topOfLine < contentOffsetTop + self.textContainerInset.top {
                overflow = topOfLine - contentOffsetTop - self.textContainerInset.top
            } else if bottomOfLine > bottomOfVisibleTextArea - self.textContainerInset.bottom {
                overflow = (bottomOfLine - bottomOfVisibleTextArea) + self.textContainerInset.bottom
            }
            self.contentOffset.y += overflow
        }
    }

}

extension ChatEditView: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.updatePosition()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let isValid = textView.text.count > 0
        self.inputViewDelegate?.chatEdit(isValid)
    }
    
}

// MARK: - const
fileprivate extension CGFloat {
    static let maxHeightPortrait: CGFloat = 160
    static let maxHeightLandScape: CGFloat = 60
}

fileprivate extension UIFont {
    static let textDefaultFont = UIFont.systemFont(ofSize: 17.0)
}

fileprivate extension UIEdgeInsets {
    static let textDefaultInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
}

