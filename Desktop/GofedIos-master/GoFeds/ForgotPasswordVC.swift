//
//  ForgotPassword.swift
//  GoFeds
//
//  Created by Rohit Prajapati on 29/08/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendOTP(_ sender: Any) {
        forgotPassword()
    }
    
    
    func forgotPassword() {
        if isValidEmailAddress(emailAddressString: txtEmail.text ?? "") {
            weak var weakSelf = self
           
            Utility.showActivityIndicator()
            Alamofire.request("https://novos.in/munish/gofeeds/forget_password_otp.php",  method: .post, parameters: ["email":"\(txtEmail.text!)"]).responseJSON { response in
                let value = response.result.value as! [String:Any]?
                let apiSuccess = value?["success"] as! Bool
                    Utility.hideActivityIndicator()
                    if apiSuccess {
                        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VerifyOTPVC") as? VerifyOTPVC
                        vc?.email = self.txtEmail.text!
                        self.navigationController?.pushViewController(vc!, animated: true)
                    } else {
                        let okAction: AlertButtonWithAction = (.ok, nil)
                        weakSelf?.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                    }
                }
        } else {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Email address should be in correct format.")!, actions: okAction)
        }
        }
    }

