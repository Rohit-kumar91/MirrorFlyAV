//
//  AddQuestionVC.swift
//  GoFeds
//
//  Created by Tarun Sachdeva on 07/05/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol QuestionSubmittedDelegate: class {
    func newQuestionAdded(question: String)
}

class AddQuestionVC: UIViewController , UITextViewDelegate {

    @IBOutlet weak var txtQuestion : UITextView!
    weak var delegate: QuestionSubmittedDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtQuestion.text = "Add your question here"
        txtQuestion.textColor = UIColor.black
        
        txtQuestion.layer.cornerRadius = 4.0
        txtQuestion.layer.borderColor = UIColor.black.cgColor
        txtQuestion.layer.borderWidth = 1.0
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add your question here"{
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add your question here"
            textView.textColor = UIColor.black
        }
    }
    
    @IBAction func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onClickSubmit() {
        if (txtQuestion.text == "Add your question here" || txtQuestion.text == "") {
           
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Please enter your question"), actions: okAction)
            
        }
        else {
            self.delegate?.newQuestionAdded(question: self.txtQuestion.text!)
            //addForumQuestion()
        }
    }
    
    func addForumQuestion() {
        Utility.showActivityIndicator()
        //let userID = UserDefaults.standard.value(forKey: "showID")
        let userID = LoginSession.getValueOf(key: SessionKeys.showId)
        let url = AddFAQUrl
        
        Alamofire.request(url,  method: .post, parameters: ["user_id": LoginSession.currentUserId, "question": "\(txtQuestion.text!)"]).responseJSON { response in
            Utility.hideActivityIndicator()
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            print(value!)
            if(BoolValue == true) {
                
                self.dismiss(animated: true) {
                    
                    self.delegate?.newQuestionAdded(question: self.txtQuestion.text!)
                }
                
            }else {
                Utility.hideActivityIndicator()
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
}
