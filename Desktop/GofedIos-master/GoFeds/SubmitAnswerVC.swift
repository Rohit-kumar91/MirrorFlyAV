//
//  SubmitAnswerVC.swift
//  GoFeds
//
//  Created by Tarun Sachdeva on 12/05/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol SubmitAnswerDelegate: class {
    func submitAnswer()
}

class SubmitAnswerVC: UIViewController {
    
    @IBOutlet weak var txtAnswer : UITextView!
    var questionData = NSDictionary()
     weak var delegate: SubmitAnswerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtAnswer.layer.cornerRadius = 8
        txtAnswer.clipsToBounds = true
        // txtAnswer.becomeFirstResponder()
    }
    
    func submitAnswer() {
        Utility.showActivityIndicator()
        let url = SubmitFAQAnswerUrl
        Alamofire.request(url,  method: .post, parameters: ["question_id" : (questionData["question_id"] as! String),"user_id":(questionData["user_id"] as! String),"answer":txtAnswer.text!]).responseJSON { response in
            
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            print(value!)
            if(BoolValue == true) {
                
                let msg = value!["message"] as! String
                //                if msg == "Answer already submitted for this Question."{
                Utility.hideActivityIndicator()
                self.dismiss(animated: true) {
                     self.delegate?.submitAnswer()
                }
                
                
                //                    NotificationCenter.default.post(name: .updateDesiredPorts, object: self)
                //                   // self.dismiss(animated: true, completion: nil)
                //                    let okAction: AlertButtonWithAction = (.ok, nil)
                //                                   self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                //                }
            }else {
                Utility.hideActivityIndicator()
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
    @IBAction func onClickClose() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onClickSubmit() {
        if txtAnswer.text == "" {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("\("Enter your answer")"), actions: okAction)
        }
        else {
            submitAnswer()
        }
    }
    
}
