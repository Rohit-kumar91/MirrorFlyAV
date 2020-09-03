//
//  NewChatVC.swift
//  GoFeds
//
//  Created by Rohit Prajapati on 30/08/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import IQKeyboardManagerSwift

class NewChatVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var imgReciver: UIImageView!
    @IBOutlet weak var lvlReciverName: UILabel!
    @IBOutlet weak var txtViewBox: UITextView!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblName: UILabel!
    
    
    //MARK:- Properties
    var userData = NSDictionary()
    var receiverName = String()
    let textViewMaxHeight: CGFloat = 100
    var customId: String?
    var userImage = String()
    var taken = false
    
    var chatArray = [[String: String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtViewBox.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        chatTable.delegate = self
        chatTable.dataSource = self
        chatTable.reloadData()
        scrollToBottom()
        chatTable.register(UINib(nibName: "ReceiverCell", bundle: nil), forCellReuseIdentifier: "ReceiverCell")
        chatTable.register(UINib(nibName: "SenderCell", bundle: nil), forCellReuseIdentifier: "SenderCell")
        imgReciver.layer.cornerRadius = 20
        imgReciver.clipsToBounds = true
        
        
        if receiverName != "" {
            lblName.text = receiverName
        } else {
            lblName.text = userData["username"] as? String
        }
        
        
        if let url = URL(string: userImage) {
            imgReciver.sd_setImage(with: url, placeholderImage: UIImage(named: "user"))
        }
        
        
        if customId == "" {
            guard let reciverId = userData["ftoken"] as? String else {return}
            customId = "\(reciverId)-\(LoginSession.currentUserFToken)"
        }
    
        
        guard let customChatId = customId else { return }
        let dataBase = Database.database().reference(fromURL: GoFedsFirebase.realTimeDatabaseURL).child("messages/\(customChatId)")
                
        dataBase.observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String: Any] {
                
               let chatDict = [
                    "message": value["text"] as? String ?? "",
                    "date" : Date.dateFromTimeInterval(NSNumber(value:(value["timestamp"] as! NSString).floatValue)),
                    "senderId": value["senderid"] as? String ?? "",
                    "receiverid": value["receiverid"] as? String ?? ""
                ]
                self.chatArray.append(chatDict)
                self.chatTable.beginUpdates()
                self.chatTable.insertRows(at: [IndexPath.init(row: self.chatArray.count-1, section: 0)], with: .none)
                self.chatTable.endUpdates()
                self.scrollToBottom()
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(true)
       IQKeyboardManager.shared.enableAutoToolbar = true
       IQKeyboardManager.shared.enable = true
        
       NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
       NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popToViewController(ofClass: ConnectionVC.self)
    }
    
    @IBAction func btnSendAction(_ sender: Any) {
        guard let customChatId = customId else { return }
        guard let reciverId = userData["ftoken"] as? String else {return}
        guard let recivername = userData["username"] as? String else {return}
        guard let message = txtViewBox.text else { return }
        
      
        if message != "" {
          let dataBase = Database.database().reference(fromURL: GoFedsFirebase.realTimeDatabaseURL).child("messages").child(customChatId).childByAutoId()
            dataBase.setValue(["text": message,
                               "receiverid": reciverId,
                               "receivername": recivername,
                               "receiverphoto": userData["image"] as? String ?? "",
                               "senderid": LoginSession.currentUserFToken,
                               "sendername": LoginSession.currentUsername,
                               "senderphoto": "",
                               "timestamp": String(Date.currentTimerIntervalGMT()),
                               "isread": false])
                    }
        
        
                    
        txtViewBox.text = ""
        print("success")
           
        
    }
    
    
    
       @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                txtViewBox.delegate = self
                scrollToBottom()
                if #available(iOS 11.0, *) {
                    let bottomInset = view.safeAreaInsets.bottom
                    self.bottomConstraint.constant = (keyboardSize.height) - bottomInset

                } else {
                    self.bottomConstraint.constant = keyboardSize.height
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        @objc func keyboardWillHide(notification: NSNotification) {
            self.bottomConstraint.constant = 0
        }
}


extension NewChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if chatArray[indexPath.row]["senderId"] == LoginSession.currentUserFToken {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
            cell.lblMsg.text = chatArray[indexPath.row]["message"]
            cell.lblTime.text = chatArray[indexPath.row]["date"]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
            cell.lblMessage.text = chatArray[indexPath.row]["message"]
             cell.lblTime.text = chatArray[indexPath.row]["date"]
            return cell
        }
        
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            if self.chatArray.count != 0 {
                let indexPath = IndexPath(row: self.chatArray.count-1, section: 0)
                self.chatTable.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 {
            // swipes from top to bottom of screen -> down
            self.bottomConstraint.constant = 0
        } else {
            // swipes from bottom to top of screen -> up
        }
    }
    
    
}



//MARK:- UITextViewDelegate
extension NewChatVC : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
           
           //self.tblChat.scrollToBottom(animated: false)
           if txtViewBox.textColor == #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) {
               txtViewBox.text = nil
               txtViewBox.textColor = UIColor.black
           }
       }
       
       func textViewDidEndEditing(_ textView: UITextView) {
           if txtViewBox.text.isEmpty {
               txtViewBox.text = "Write a message"
               txtViewBox.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
           }
       }
       
       
       func textViewDidChange(_ textView: UITextView)
       {
           if textView.contentSize.height >= self.textViewMaxHeight {
              
               textView.isScrollEnabled = true
               //textView.frame.size.height = 100
           }
           else
           {
               if textView.contentSize.height >= 33 {
                   textView.frame.size.height = textView.contentSize.height
                   textView.isScrollEnabled = false
               }
           }
       }
        
       
       func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
          
           let updatedString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
           if updatedString?.count ?? 0 > 0 {
              
           } else {
               
           }
           
           return true
       }
       
       func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
          
           if txtViewBox.text.isEmpty {
               txtViewBox.text = "Write a message"
               txtViewBox.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
           }
           return true
       }
}


