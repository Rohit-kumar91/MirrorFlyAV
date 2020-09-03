//
//  CreateNewPasswordVC.swift
//  GoFeds
//
//  Created by Rohit Prajapati on 29/08/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire

class CreateNewPasswordVC: UIViewController {
    
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    var email = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        
       
        
        guard let newPassword  = txtNewPassword.text else { return }
        guard let confirmPassword  = txtConfirmPassword.text else { return }
        
        changePassword(newPassword: newPassword, confirmPassword: confirmPassword)
    }
    
    
    func changePassword(newPassword: String, confirmPassword: String) {
        if newPassword == confirmPassword {
            chnagePasswordAPICall(newPassword: newPassword, confirmPassword: confirmPassword)
        } else {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Your confirm password should match with your new password."), actions: okAction)

        }
    }
    
    
    func chnagePasswordAPICall(newPassword: String, confirmPassword: String ) {
        weak var weakSelf = self
              Utility.showActivityIndicator()
              Alamofire.request("https://novos.in/munish/gofeeds/forget_password_change.php",  method: .post, parameters: ["password":"\(newPassword)", "email": email]).responseJSON { response in
                   let value = response.result.value as! [String:Any]?
                   let apiSuccess = value?["success"] as! Bool
                       Utility.hideActivityIndicator()
                       if apiSuccess {
                            let okAction: AlertButtonWithAction = (.ok, nil)
                            weakSelf?.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                        weakSelf?.navigationController?.popToViewController(LoginVC(), animated: true)
                        
                       } else {
                           let okAction: AlertButtonWithAction = (.ok, nil)
                           weakSelf?.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                       }
                   }
    }
    
}



extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    } else {
        self.popViewController(animated: true)
    }
  }
}
