//
//  SwiftExampleViewController.swift
//  SimpleChat
//
//  Created by Logan Wright on 11/15/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//

import UIKit
import SnapKit

class SwiftExampleViewController: UIViewController, YjiChatControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let startBtn = UIButton()
        startBtn.setTitleColor(UIColor.black, for: .normal)
        startBtn.setTitle("start", for: UIControlState())
        startBtn.addTarget(self, action: #selector(self.launchChatController), for: .touchUpInside)
        self.view.addSubview(startBtn)
        startBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    

    // MARK: Launch Chat Controller
    
    func launchChatController() {
        let chatController = YjiChatController()
        chatController.opponentImage = UIImage(named: "User")
        chatController.title = "Simple Chat"
        let helloWorld = YjiChatMessage(content: "Hello World!", sentByString: YjiChatMessage.SentByUserString())
        chatController.messages = [helloWorld]
        chatController.delegate = self
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    // MARK: YjiChatControllerDelegate
    
    func chatController(_ chatController: YjiChatController, didAddNewMessage message: YjiChatMessage) {
        print("Did Add Message: \(message.content)")
    }
    
    func shouldChatController(_ chatController: YjiChatController, addMessage message: YjiChatMessage) -> Bool {
        /*
        Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
        */
        return true
    }

}
