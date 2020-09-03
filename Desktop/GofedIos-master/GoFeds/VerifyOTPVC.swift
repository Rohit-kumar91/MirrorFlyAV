//
//  VerifyOTPVC.swift
//  GoFeds
//
//  Created by Rohit Prajapati on 29/08/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire

class VerifyOTPVC: UIViewController {
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    @IBOutlet weak var txtFieldFirstDigit: UITextField!
    @IBOutlet weak var txtFieldSecondDigit: UITextField!
    @IBOutlet weak var txtFieldThirdDigit: UITextField!
    @IBOutlet weak var txtFieldFourthDigit: UITextField!
    @IBOutlet weak var txtEmail: UILabel!
    
    var otpTyped = ""
    var email = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtEmail.text = email
        view1.layer.cornerRadius = 4
        view1.layer.borderColor = #colorLiteral(red: 0.01855918206, green: 0.2434426546, blue: 0.6259476542, alpha: 1)
        view1.layer.borderWidth = 1
        
        view2.layer.cornerRadius = 4
        view2.layer.borderColor = #colorLiteral(red: 0.01855918206, green: 0.2434426546, blue: 0.6259476542, alpha: 1)
        view2.layer.borderWidth = 1
        
        view3.layer.cornerRadius = 4
        view3.layer.borderColor = #colorLiteral(red: 0.01855918206, green: 0.2434426546, blue: 0.6259476542, alpha: 1)
        view3.layer.borderWidth = 1
        
        view4.layer.cornerRadius = 4
        view4.layer.borderColor = #colorLiteral(red: 0.01855918206, green: 0.2434426546, blue: 0.6259476542, alpha: 1)
        view4.layer.borderWidth = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtFieldFirstDigit.becomeFirstResponder()
        txtFieldFirstDigit.text = ""
        txtFieldSecondDigit.text = ""
        txtFieldThirdDigit.text = ""
        txtFieldFourthDigit.text = ""
        
        txtFieldFirstDigit.delegate = self
        txtFieldSecondDigit.delegate = self
        txtFieldThirdDigit.delegate = self
        txtFieldFourthDigit.delegate = self
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnVerifyNowAction(_ sender: Any) {
        
        guard let txf1 = txtFieldFirstDigit.text else { return }
        guard let txf2 = txtFieldSecondDigit.text else { return }
        guard let txf3 = txtFieldThirdDigit.text else { return }
        guard let txf4 = txtFieldFourthDigit.text else { return }
        
        
        otpTyped = "\(txf1)\(txf2)\(txf3)\(txf4)"
        
        if otpTyped.count < 4 {
            let okAction: AlertButtonWithAction = (.ok, nil)
            self.showAlertWith(message: .custom("Enter 4 digit correct OTP.")!, actions: okAction)
        } else {
            verifyHelperOTP(otpString: otpTyped)
        }
        
    }
    
    
    func verifyHelperOTP(otpString: String) {
        weak var weakSelf = self
        Utility.showActivityIndicator()
        Alamofire.request("https://novos.in/munish/gofeeds/forget_passwod_opt_verify.php",  method: .post, parameters: ["otp":"\(otpString)", "email": email]).responseJSON { response in
             let value = response.result.value as! [String:Any]?
             let apiSuccess = value?["success"] as! Bool
                 Utility.hideActivityIndicator()
                 if apiSuccess {
                     let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateNewPasswordVC") as? CreateNewPasswordVC
                    vc?.email = self.email
                     self.navigationController?.pushViewController(vc!, animated: true)
                 } else {
                     let okAction: AlertButtonWithAction = (.ok, nil)
                     weakSelf?.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
                 }
             }

    }
       
}


extension VerifyOTPVC: UITextFieldDelegate {
    //MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var shouldProcess = false //default to reject
        var shouldMoveToNextField = false //default to remaining on the current field
        let  insertStrLength = string.count
        
        if insertStrLength == 0 {
            
            shouldProcess = true //Process if the backspace character was pressed
            
        } else {
            if textField.text?.count ?? 0 <= 1 {
                shouldProcess = true //Process if there is only 1 character right now
            }
        }
        
        if shouldProcess {
            
            var mString = ""
            if mString.count == 0 {
                
                mString = string
                shouldMoveToNextField = true
                
            } else {
                //adding a char or deleting?
                if(insertStrLength > 0){
                    mString = string
                    
                } else {
                    //delete case - the length of replacement string is zero for a delete
                    mString = ""
                }
            }
            
            //set the text now
            textField.text = mString
            
    
            if (shouldMoveToNextField&&textField.text?.count == 1) {
                
                if (textField == txtFieldFirstDigit) {
                    txtFieldSecondDigit.becomeFirstResponder()
                    
                } else if (textField == txtFieldSecondDigit){
                    txtFieldThirdDigit.becomeFirstResponder()
                    
                } else if (textField == txtFieldThirdDigit){
                    txtFieldFourthDigit.becomeFirstResponder()
                    
                } else {
                    txtFieldFourthDigit.resignFirstResponder()
                }
            }
            else{
                self.textFieldDidDelete()
            }
        }
        return false
    }
    
    //MARK: - MyTextField Delegate
    func textFieldDidDelete() {
        
        
        if txtFieldSecondDigit.isFirstResponder{
            txtFieldFirstDigit.becomeFirstResponder()
        }
        
        if txtFieldThirdDigit.isFirstResponder{
            txtFieldSecondDigit.becomeFirstResponder()
        }
        
        if txtFieldFourthDigit.isFirstResponder{
            txtFieldThirdDigit.becomeFirstResponder()
        }
        
    }
}
