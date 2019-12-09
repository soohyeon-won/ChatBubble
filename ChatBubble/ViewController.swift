//
//  ViewController.swift
//  ChatBubble
//
//  Created by Eric JI on 2019/12/09.
//  Copyright © 2019 ericji. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Public Properties
    
    var messages = [Message]()
    
    // MARK: Private Properties
    // UI
    private let sizingCell = MessageCell()
    private let tableView: UITableView = UITableView()
    private let chatSentView = ChatSentView(frame: .zero)
    private var bottomChatSentViewConstraint: NSLayoutConstraint!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
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
    
    // MARK: Setup
       
    private func setup() {
        
        self.navigationItem.title = "Let's Chat!"
        
        self.view.backgroundColor = UIColor.background
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onTapChatView))
        self.view.addGestureRecognizer(gesture)
        
        self.setupTableView()
        self.setupChatSentView()
        self.setupLayoutConstraints()
    }
   
    private func setupTableView() {
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.frame = self.view.bounds
        tableView.register(MessageCell.classForCoder(), forCellReuseIdentifier: Constants.messageCellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.view.addSubview(tableView)
    }
       
    private func setupChatSentView() {
        chatSentView.delegate = self
        self.view.addSubview(chatSentView)
    }
       
    private func setupLayoutConstraints() {
        chatSentView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let guide = view.safeAreaLayoutGuide
        bottomChatSentViewConstraint = chatSentView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)

        NSLayoutConstraint.activate([
            chatSentView.leftAnchor.constraint(equalTo: guide.leftAnchor),
            chatSentView.rightAnchor.constraint(equalTo: guide.rightAnchor),
            bottomChatSentViewConstraint
        ])
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: guide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: guide.rightAnchor),
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: chatSentView.topAnchor)
        ])
        
    }
    
    // MARK: Keyboard Notifications
    
    private func listenForKeyboardChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(note:)),name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func unregisterKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillChangeFrame(note: NSNotification) {
        let keyboardAnimationDetail = note.userInfo!
        let duration = keyboardAnimationDetail[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        var keyboardFrame = (keyboardAnimationDetail[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if let window = self.view.window {
            keyboardFrame = window.convert(keyboardFrame, to: self.view)
        }
        let animationCurve = keyboardAnimationDetail[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        self.tableView.isScrollEnabled = false
        self.tableView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.view.layoutIfNeeded()
        var chatSentViewOffset = -((self.view.bounds.height - self.view.safeAreaInsets.bottom) - keyboardFrame.minY)
        if chatSentViewOffset > 0 {
            chatSentViewOffset = 0
        }
        self.bottomChatSentViewConstraint.constant = chatSentViewOffset
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue:animationCurve), animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.scrollToBottom()
            }, completion: {(finished) -> () in
                self.tableView.isScrollEnabled = true
                self.tableView.decelerationRate = UIScrollView.DecelerationRate.normal
        })
    }
    
    // MARK: Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.tableView.reloadData()
        }) { (_) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut,animations: { () -> Void in
                    self.scrollToBottom()
                }, completion: nil)
        }
    }
    
    
    // MARK: Scrolling
    
    private func scrollToBottom() {
        if messages.count > 0 {
            var lastItemIdx = self.tableView.numberOfRows(inSection: Constants.messageSection) - 1
            if lastItemIdx < 0 {
                lastItemIdx = 0
            }
            let lastIndexPath = IndexPath(row: lastItemIdx, section: Constants.messageSection)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        }
    }
    
    // MARK: New messages
    
    private func addNewMessage(message: Message) {
        
        messages += [message]
        tableView.reloadData()
        self.scrollToBottom()
        
        // mock data from friends after 2 seconds
        getFriendMessageCopy(from: message)
    }
    
    private func getFriendMessageCopy(from message: Message) {
        // Mock friends message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let receivedMsg = Message(content: message.content, messageType: .received, time: Date().timeString)
            self.messages += [receivedMsg]
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    // MARK: -Action
    @objc private func onTapChatView() {
        chatSentView.reset()
    }

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.messageCellID, for: indexPath) as! MessageCell
        let message = self.messages[indexPath.row]
        cell.set(message: message)
        return cell
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let padding: CGFloat = 10.0
        sizingCell.bounds.size.width = self.view.bounds.width
        let height = self.sizingCell.set(message: messages[indexPath.row]).height + padding
        return height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.chatSentView.textView.resignFirstResponder()
        }
    }
}

extension ViewController: ChatSentViewDelegate {
    
    func ChatSentDidResize(chatSentView: ChatSentView) {
        self.scrollToBottom()
    }
    
    func ChatSent(chatSentView: ChatSentView, didSendMessage message: String) {
        let newMessage = Message(content: message, messageType: .sent, time: Date().timeString)
        self.addNewMessage(message: newMessage)
    }
    
}

fileprivate struct Constants {
    static let messageSection: Int = 0
    static let messageCellID: String = "messageCellID"
}

fileprivate extension UIColor {
    static let background = UIColor(red: 240/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)
}


