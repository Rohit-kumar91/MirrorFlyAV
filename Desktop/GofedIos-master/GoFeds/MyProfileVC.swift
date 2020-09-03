//
//  MyProfileVC.swift
//  GoFeds
//
//  Created by Novos on 17/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class MyProfileVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var chooseProfilePicBtn: UIButton!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var profilePicImgVW: UIImageView!
    @IBOutlet weak var rankTextfield: UITextField!
    @IBOutlet weak var agencyTextfield: UITextField!
    @IBOutlet weak var officeTextfield: UITextField!
    @IBOutlet weak var currentPortTextfield: UITextField!
    @IBOutlet weak var desiredPortTectfield: UITextField!
    @IBOutlet weak var startChatBtn: UIButton!
    
    //MARK:- Variables
    var userData = NSDictionary()
    var keyToChat = String()
    var userChat_fromId : [String] = []
    var userChat_text : [String] = []
    var userChat_timeStamp : [NSNumber] = []
    var userChat_toId : [String] = []
    
    var chat_fromId : [String] = []
    var chat_text : [String] = []
    var chat_timeStamp : [NSNumber] = []
    var chat_toId : [String] = []
    var chatArray = [[String: String]]()
    let operationQueue: OperationQueue = OperationQueue()
    var customId = String()
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicImgVW.layer.cornerRadius = 40
        profilePicImgVW.clipsToBounds = true

        currentPortTextfield.isUserInteractionEnabled = false
        desiredPortTectfield.isUserInteractionEnabled = false
        print(userData)
        //print(CurrentUserInfo.showID!)
        setProfileData() 
        //getPerticularChatData()
       // observeMessages()
        getChatId()
    }
    
    
    func getChatId() {
        
        print("Key value", userData["ftoken"] as! String)
         print("Key value", LoginSession.currentUserFToken)
        
        let dataBase = Database.database().reference(fromURL: GoFedsFirebase.realTimeDatabaseURL).child("messages")
        dataBase.observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.exists() {
                for child in snapShot.children {
                   let key = (child as AnyObject).key as String
                   print("Key", key)
                    if key.contains(LoginSession.currentUserFToken) &&  key.contains(self.userData["ftoken"] as! String){
                        print("Inner Key", key)
                        self.keyToChat = key
                        //self.getPerticularChatData(keyValue: key)
                   }
                }
                
            } else{
                print("snap not exist...")
            }
        }
    }
    
    
    func getPerticularChatData(keyValue: String) {
//        guard let reciverId = userData["ftoken"] as? String else {return}
//        let customId = "\(reciverId)-\(LoginSession.currentUserFToken)"
        

        if LoginSession.chatId != "" {
          let dataBase = Database.database().reference(fromURL: GoFedsFirebase.realTimeDatabaseURL).child("messages/\(keyValue)")
               dataBase.observeSingleEvent(of: .value) { (snapShot) in
                   if snapShot.exists() {
                       for child in snapShot.children {
                           let data = child as! DataSnapshot
                           let value = data.value! as! [String:Any]
                          
                            let chatDict = [
                               "message": value["text"] as? String ?? "",
                               "date" : Date.dateFromTimeInterval(NSNumber(value:(value["timestamp"] as! NSString).floatValue)),
                               "senderId": value["senderid"] as? String ?? "",
                               "receiverid": value["receiverid"] as? String ?? ""
                           ]
                           self.chatArray.append(chatDict)
                       }
                       
                   } else{
                       print("snap not exist...")
                   }
               }
          }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setProfileData() {
        
        guard let username = userData["username"] as? String else { return }
        guard let rank = userData["rank"] as? String else { return }
        guard let agency = userData["agency"] as? String else { return }
        guard let office = userData["office"] as? String else { return }
        guard let desire_port = userData["desire_port"] as? String else { return }
        guard let current_port = userData["current_port"] as? String else { return }
        
        if let url = URL(string: userData["image"] as? String ?? "") {
            profilePicImgVW.sd_setImage(with: url, placeholderImage: UIImage(named: "user"))
        }
        
        lblUserName.text = username
        rankTextfield.text = rank
        agencyTextfield.text = agency
        officeTextfield.text = office
        currentPortTextfield.text = current_port
        desiredPortTectfield.text = desire_port
    }
    
    func setProfileInfo(){
        
        if UserDefaults.standard.value(forKey: "userName") != nil {
        
        let name = UserDefaults.standard.value(forKey: "userName") as! String
        let rank = UserDefaults.standard.value(forKey: "rank") as! String
        let agency = UserDefaults.standard.value(forKey: "agency") as! String
       // let office = UserDefaults.standard.value(forKey: "office") as! String
        let current_port = UserDefaults.standard.value(forKey: "showName") as! String
        let desired_port = UserDefaults.standard.value(forKey: "desiredPort") as! String
        
        lblUserName.text = name
        rankTextfield.text = rank
        agencyTextfield.text = agency
        officeTextfield.text = ""//office
        currentPortTextfield.text = current_port
        desiredPortTectfield.text = desired_port
        }
    }
    
    //MARK:- Button Actions
    @IBAction func startChatBtn(_ sender: Any) {
       let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewChatVC") as? NewChatVC
        vc?.userData = userData
        vc?.customId = keyToChat
        //vc?.chatArray = self.chatArray
        self.navigationController?.pushViewController(vc!, animated: true)
                
    }
    
    
    
    
    
    func openChatController(){
//        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
//
//        let id = userData["user_id"] as! String
//        chatController.recieverUID = id
//        chatController.recieverName = userData["username"] as? String
//        chatController.recieverImgUrl = ""
//        chatController.reciever_ftoken = userData["ftoken"] as? String
//
//
//        navigationController?.pushViewController(chatController, animated: true)
        
        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        let id = userData["user_id"] as! String
        chatController.recieverUID = id
        chatController.recieverName = userData["username"] as? String
        chatController.recieverImgUrl = ""
        chatController.reciever_ftoken = userData["ftoken"] as? String
        
        chatController.currentConversation = ConversationManager.shared.getConversationForUser(id.nsnumValue() )
        
        if chatController.currentConversation == nil
        {
            ConversationManager.shared.checkAndCreateNewConversation(id.nsnumValue(), chatController.recieverName ?? "") { () in
                
                chatController.currentConversation = ConversationManager.shared.getConversationForUser(id.nsnumValue())
                
                self.navigationController?.pushViewController(chatController, animated: true)
            }
        }
        else
        {
            self.navigationController?.pushViewController(chatController, animated: true)
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    let message = MessageModel()
    
//    func observeMessages(){
//
//          let db = Database.database().reference()
//          let ref = db.child("messages")
//
//          ref.observe(.childAdded, with: { (snapshot) in
//
//              if let dic = snapshot.value as? [String: AnyObject] {
//                  print(dic)
//
//               // DispatchQueue.main.async {
//                 // let message = MessageModel()
//                    self.message.fromId = dic["fromId"] as? String
//                    self.message.text = dic["text"] as? String
//                    self.message.timeStamp = dic["timeStamp"] as? NSNumber
//                    self.message.toId = dic["toId"] as? String
//
//                    self.chat_fromId.append(self.message.fromId!)
//                    self.chat_text.append(self.message.text!)
//                    self.chat_timeStamp.append(self.message.timeStamp!)
//                    self.chat_toId.append(self.message.toId!)
//
//               // }
//                  //self.messages.append(message)
//
//
//                  }
//
//              }, withCancel: nil)
//
//        print(self.chat_text)
//
//    }
          
//    func openChatController(sender: String, receiver: String,name : String){
//
//              let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
//
//              var id = receiver
//
//              if receiver == sender {
//                  id = sender
//              }
//
//
//        // update user array
//
//                 userChat_fromId = []
//                 userChat_text = []
//                 userChat_timeStamp = []
//                 userChat_toId = []
//
//               // let message = messages[0]
//                //let currentUser_fToken = UserDefaults.standard.value(forKey: "ftoken") as! String
//
//                for index in 0..<(chat_toId.count) {
//
////                            print("chat_toid & ftoken")
////                            print(chat_toId[index],message.toId!)
////                            print("chat_fromid & message-from id ")
////                            print(chat_fromId[index],currentUser_fToken)
////                            print("chat_toid & currentUser_fToken")
////                            print(chat_toId[index],message.fromId)
////                            print("chat_fromid & current ftoken")
////                            print(chat_fromId[index],currentUser_fToken)
//        //
//        //                    print(self.messageDictionary)
//        //                    print(message.text,message.toId,message.fromId)
//
//                    if (chat_toId[index] == id && chat_fromId[index] == LoginSession.currentUserFToken) || (chat_toId[index] == LoginSession.currentUserFToken && chat_fromId[index] == id) {
//
//                        userChat_text.append(chat_text[index])
//                        userChat_fromId.append(chat_fromId[index])
//                        userChat_toId.append(chat_toId[index])
//                        userChat_timeStamp.append(chat_timeStamp[index])
//
//                    }
//
//        }
//                    print(userChat_text)
//
//
//              chatController.userChat_timeStamp = userChat_timeStamp
//              chatController.userChat_toId = userChat_toId
//              chatController.userChat_fromId = userChat_fromId
//              chatController.userChat_text = userChat_text
//      //
//              chatController.recieverUID = id
//              chatController.recieverName = name
//              chatController.recieverImgUrl = ""
//              chatController.reciever_ftoken = id
//              navigationController?.isNavigationBarHidden = false
//              navigationController?.pushViewController(chatController, animated: true)
//          }
      
    
}
