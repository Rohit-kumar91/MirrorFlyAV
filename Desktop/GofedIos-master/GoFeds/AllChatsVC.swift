//
//  AllChatsVC.swift
//  GoFeds
//
//  Created by Rohit Prajapati on 31/08/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AllChatsVC: UIViewController {
    
    
    @IBOutlet weak var tblChat: UITableView!
    
    var allchatArr = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         getChatId()
    }
    
    
    func getChatId() {
        let dataBase = Database.database().reference(fromURL: GoFedsFirebase.realTimeDatabaseURL).child("messages")
        dataBase.observeSingleEvent(of: .value) { (snapShot) in
            if snapShot.exists() {
                for child in snapShot.children {
                   let key = (child as AnyObject).key as String
                   if key.contains(LoginSession.currentUserFToken) {
                     
                    //Fetching the last value from the message key...
                    let dataref = Database.database().reference(fromURL: GoFedsFirebase.realTimeDatabaseURL).child("messages/\(key)")
                    dataref.queryLimited(toLast: 1).observeSingleEvent(of: .childAdded) { (snapshot) in
                        let value = snapshot.value! as! [String:Any]
                        let chatDict = [
                            "message": value["text"] as? String ?? "",
                            "date" : Date.dateFromTimeInterval(NSNumber(value:(value["timestamp"] as! NSString).floatValue)),
                            "senderId": value["senderid"] as? String ?? "",
                            "receiverid": value["receiverid"] as? String ?? "",
                            "receiverPhoto": value["receiverphoto"] as? String ?? "",
                            "receivername": value["receivername"] as? String ?? "",
                            "sendername": value["sendername"] as? String ?? "",
                            "chatKeyID": key
                        ]
                        self.allchatArr.append(chatDict)
                        
                        DispatchQueue.main.async {
                            self.tblChat.reloadData()
                        }
                     }
                   }
                }
            } else{
                print("snap not exist...")
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AllChatsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allchatArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllChatCell", for: indexPath) as! AllChatCell
        
        if LoginSession.currentUserFToken == allchatArr[indexPath.row]["receiverid"] {
            cell.lblUsername.text = allchatArr[indexPath.row]["sendername"]
            cell.lblLastName.text = allchatArr[indexPath.row]["message"]
        } else {
            cell.lblUsername.text = allchatArr[indexPath.row]["receivername"]
            cell.lblLastName.text = allchatArr[indexPath.row]["message"]
        }
        
        
        
        if let url = URL(string: allchatArr[indexPath.row]["image"] ?? "") {
            cell.imgUser.sd_setImage(with: url, placeholderImage: UIImage(named: "user"))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "NewChatVC") as? NewChatVC
        vc?.customId = allchatArr[indexPath.row]["chatKeyID"]
        vc?.receiverName = allchatArr[indexPath.row]["receivername"] ?? ""
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    
}
