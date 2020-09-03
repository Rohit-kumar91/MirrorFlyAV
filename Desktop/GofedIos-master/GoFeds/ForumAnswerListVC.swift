//
//  ForumAnswerListVC.swift
//  GoFeds
//
//  Created by Tarun Sachdeva on 07/05/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class ForumAnswerListVC: UIViewController, SubmitAnswerDelegate {
    
    
    
    @IBOutlet weak var txtQuestion: UITextView!
    @IBOutlet weak var forumTable: UITableView!
    @IBOutlet weak var startChatBtn: UIButton!
    
    
    var listArray = NSArray()
    var questionData = NSDictionary()
    var refreshControl = UIRefreshControl()
    var pullToRefresh = false
    var keyToChat = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        forumTable.addSubview(refreshControl)
        
        txtQuestion.text = (questionData["question"] as! String)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAnswers),
                                               name: .updateDesiredPorts,
                                               object: nil)
        getChatId()
        getAllAnswerList()
        
    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.isNavigationBarHidden = false
//    }
    override func viewWillAppear(_ animated: Bool) {
        //navigationController?.isNavigationBarHidden = true
        
    }
    
    //MARK:- Notification handler
    @objc func updateAnswers(notification: Notification){
        getAllAnswerList()
    }
    
    
    func getChatId() {
        
        print("Key value", questionData["ftoken"] as! String)
         print("Key value", LoginSession.currentUserFToken)
        
        let dataBase = Database.database().reference(fromURL: GoFedsFirebase.realTimeDatabaseURL).child("messages")
        dataBase.observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.exists() {
                for child in snapShot.children {
                   let key = (child as AnyObject).key as String
                   print("Key", key)
                    if key.contains(LoginSession.currentUserFToken) &&  key.contains(self.questionData["ftoken"] as! String){
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

    
    
    @objc func refresh(_ sender: AnyObject) {
          // Code to refresh table view
           pullToRefresh = true
          
    }
    
    func submitAnswer() {
        getAllAnswerList()
    }
    
    func getAllAnswerList() {
        
        if !pullToRefresh {
            Utility.showActivityIndicator()
        }
        
        let url = ViewAllAnswerOfQuestionUrl
        Alamofire.request(url,  method: .post, parameters: ["question_id" : (questionData["question_id"] as! String)]).responseJSON { response in
            self.pullToRefresh = false
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            print(value!)
            self.refreshControl.endRefreshing()
            if(BoolValue == true) {
                Utility.hideActivityIndicator()
                self.listArray = value?["answers"] as! NSArray
                self.forumTable.reloadData()
            }else {
                Utility.hideActivityIndicator()
                let okAction: AlertButtonWithAction = (.ok, nil)
                let msg = value!["message"] as! String
                if msg == "No Questions Found"{
                    self.showAlertWith(message: .custom("No answer found")!, actions: okAction)
                }
                else{
                    self.showAlertWith(message: .custom(msg)!, actions: okAction)
                }
                
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
    @IBAction func onClickBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickStartChat() {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewChatVC") as? NewChatVC
        
        let userdata: NSDictionary = [
            "ftoken" : questionData["ftoken"] as! String,
            "username": questionData["user_name"] as! String
        ]
        
        vc?.userData =  userdata
        vc?.customId = keyToChat
        vc?.userImage = questionData["image"] as! String
        vc?.receiverName = questionData["user_name"] as! String
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func onClickSubmitAnswerAcn() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SubmitAnswerVC") as? SubmitAnswerVC
        vc!.questionData = questionData
        vc!.delegate = self
        self.present(vc!, animated: true, completion: nil)
        Utility.hideActivityIndicator()
    }
    
    func openChatController() {
//        let chatController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
//        
//        let id = questionData["user_id"] as! String
//        chatController.recieverUID = id
//        chatController.recieverName = questionData["user_name"] as? String
//        chatController.recieverImgUrl = ""
//        chatController.reciever_ftoken = ""
//        
//        chatController.currentConversation = ConversationManager.shared.getConversationForUser(id.nsnumValue() )
//        
//        if chatController.currentConversation == nil
//        {
//            ConversationManager.shared.checkAndCreateNewConversation(id.nsnumValue(), chatController.recieverName ?? "") { () in
//                
//                chatController.currentConversation = ConversationManager.shared.getConversationForUser(id.nsnumValue())
//                
//                self.navigationController?.pushViewController(chatController, animated: true)
//            }
//        }
//        else
//        {
//            self.navigationController?.pushViewController(chatController, animated: true)
//        }
    }
}

//MARK:- TableView Delegates & DataSource
extension ForumAnswerListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommonTableViewCell
        let data = listArray.object(at: indexPath.row) as! NSDictionary
        cell.lblAnswer.text  = (data["answer"] as! String)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = listArray.object(at: indexPath.row) as! NSDictionary
        let answer =   (data["answer"] as! String)
        let setFont =  UIFont(name: "Helvetica", size: 20)
        return heightForView(text: answer, font: setFont!, width: view.frame.width - 140) + 60
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: "Helvetica", size: 16)
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
