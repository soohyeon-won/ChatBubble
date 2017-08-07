//
//  YjiChatController.swift
//  YjiChatBubble
//
//  Created by 季 雲 on 2017/08/04.
//  Copyright © 2017 Ericji. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol YjiChatControllerDelegate {
    @objc optional func shouldChatController(_ chatController: YjiChatController, addMessage message: YjiChatMessage) -> Bool
    @objc optional func chatController(_ chatController: YjiChatController, didAddNewMessage message: YjiChatMessage)
}

class YjiChatController: UIViewController {
    
    // MARK: Public Properties
    
    /*!
     Use this to set the messages to be displayed
     */
    var messages: [YjiChatMessage] = []
    var opponentImage: UIImage?
    weak var delegate: YjiChatControllerDelegate?
    
    // MARK: Private Properties
    
    fileprivate let sizingCell = YjiChatMessageCell()
    private let tableView: UITableView = UITableView()
    fileprivate let chatInput = YjiChatInput(frame: CGRect.zero)
    private var bottomChatInputConstraint: NSLayoutConstraint!
    fileprivate let msgCellId = "msgCellId"
    var curChatInputHeight: CGFloat = 40
    var curChatInputBottom: CGFloat = 0
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.frame = self.view.bounds
        tableView.register(YjiChatMessageCell.classForCoder(), forCellReuseIdentifier: msgCellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.view.addSubview(tableView)
        chatInput.delegate = self
        self.view.addSubview(chatInput)
        
        // layout setting
        chatInput.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            make.height.equalTo(curChatInputHeight)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(chatInput.snp.top)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listenForKeyboardChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollToBottom()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardObservers()
    }
    
    deinit {
        /*
         Need to remove delegate and datasource or they will try to send scrollView messages.
         */
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
    }
    
    // MARK: Keyboard Notifications
    
    private func listenForKeyboardChanges() {
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(YjiChatController.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func unregisterKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillChangeFrame(_ note: Notification) {
        let keyboardAnimationDetail = note.userInfo!
        let duration = keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        var keyboardFrame = (keyboardAnimationDetail[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if let window = self.view.window {
            keyboardFrame = window.convert(keyboardFrame, to: self.view)
        }
        let animationCurve = keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        self.tableView.isScrollEnabled = false
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast
        self.view.layoutIfNeeded()
        var chatInputOffset = -((self.view.bounds.height - self.bottomLayoutGuide.length) - keyboardFrame.minY)
        if chatInputOffset > 0 {
            chatInputOffset = 0
        }
        curChatInputBottom = chatInputOffset
        resizeChatInputHandle()
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationCurve), animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }, completion: {(finished) -> () in
            self.tableView.isScrollEnabled = true
            self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal
        })
    }
    
    // MARK: Rotate device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.tableView.reloadData()
        }) { (_) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                self.scrollToBottom()
            }, completion: nil)
        }
        
    }
    
    // MARK: Scrolling
    fileprivate func scrollToBottom() {
        if messages.count > 0 {
            var lastItemIdx = self.tableView.numberOfRows(inSection: 0) - 1
            if lastItemIdx < 0 {
                lastItemIdx = 0
            }
            let lastIndexPath = IndexPath(row: lastItemIdx, section: 0)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        }
    }
    
    // MARK: New messages
    func addNewMessage(_ message: YjiChatMessage) {
        messages += [message]
        tableView.reloadData()
        self.scrollToBottom()
        self.delegate?.chatController?(self, didAddNewMessage: message)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.chatInput.textView.resignFirstResponder()
        }
    }
    
    fileprivate func resizeChatInputHandle() {
        self.chatInput.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(curChatInputBottom)
            make.height.equalTo(curChatInputHeight)
        }
    }
}

extension YjiChatController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: msgCellId, for: indexPath) as! YjiChatMessageCell
        let message = self.messages[indexPath.row]
        cell.opponentImageView.image = message.sentBy == .Opponent ? self.opponentImage : nil
        cell.setupWithMessage(message)
        return cell;
    }
}

extension YjiChatController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let padding: CGFloat = 10.0
        sizingCell.bounds.size.width = self.view.bounds.width
        let height = self.sizingCell.getHeightWith(messages[indexPath.row]) + padding;
        return height
    }
}

extension YjiChatController: YjiChatInputDelegate {
    
    func chatInputDidResize(_ chatInput: YjiChatInput, with height: CGFloat) {
        curChatInputHeight = height
        resizeChatInputHandle()
        self.scrollToBottom()
    }
    
    func chatInput(_ chatInput: YjiChatInput, didSendMessage message: String) {
        let newMessage = YjiChatMessage(content: message, sentBy: .User)
        var shouldSendMessage = true
        if let value = self.delegate?.shouldChatController?(self, addMessage: newMessage) {
            shouldSendMessage = value
        }
        if shouldSendMessage {
            self.addNewMessage(newMessage)
        }
    }
}
