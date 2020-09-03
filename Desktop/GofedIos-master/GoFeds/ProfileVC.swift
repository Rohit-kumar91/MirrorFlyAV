//
//  ProfileVC.swift
//  GoFeds
//
//  Created by Novos on 30/04/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var selectRankBtn: UIButton!
    @IBOutlet weak var rankTextfld: UITextField!
    @IBOutlet weak var selectAgencyBtn: UIButton!
    @IBOutlet weak var agencyTextfld: UITextField!
    @IBOutlet weak var selectOfficeBtn: UIButton!
    @IBOutlet weak var officeTextfld: UITextField!
    @IBOutlet weak var btnSave: GradientButton!
    @IBOutlet weak var currentPortTextFld: UITextField!
    @IBOutlet weak var currentPortBtn: UIButton!
    @IBOutlet weak var desiredPortTextfld: UITextField!
    @IBOutlet weak var desiredPortBtn: UIButton!
    // @IBOutlet weak var logoutBtn: GradientButton!
    
    //MARK:- Variables
    var rankPicker  = UIPickerView()
    var agencyPicker  = UIPickerView()
    var officePicker = UIPickerView()
    var currentPortPicker = UIPickerView()
    var toolBar = UIToolbar()
    
    let Ranks = ["GS-5","GS-7","GS-9","GS-11","GS-12","Other"]
    let Agencies = ["CBP"]
    let Officies = ["OFO","BP"]
    let currentPort = "AZ San Ysidrdo"
    
    private var imageToUpload: UIImage?
    private var imageToUploadURL: String?
    private var imagePicker: CustomImagePicker!
    private var showSaveBtn = false
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        apiCall()
        
        userImage.layer.cornerRadius = 50
        userName.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDesiredPort),
                                               name: .updateDesiredPorts,
                                               object: nil)
        
        userName.text = LoginSession.getValueOf(key: SessionKeys.userName)
        rankTextfld.text = LoginSession.getValueOf(key: SessionKeys.rank)
        agencyTextfld.text = LoginSession.getValueOf(key: SessionKeys.agency)
        officeTextfld.text = LoginSession.getValueOf(key: SessionKeys.office)
        currentPortTextFld.text = LoginSession.getValueOf(key: SessionKeys.currentPort)
        desiredPortTextfld.text = LoginSession.getValueOf(key: SessionKeys.desiredPort)
                
        self.imagePicker = CustomImagePicker(presentationController: self, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.userImage.sd_setImage(with: URL(string: LoginSession.getValueOf(key: SessionKeys.image)), placeholderImage: UIImage(named: "user"))
    }
    
    //MARK:- Button Actions
    
    @IBAction func imageSelectBtn(_ sender: Any) {
        
        imagePicker.present(from: self.view)
    }
    
    @IBAction func selectRankBtn(_ sender: Any) {
        removeFromSuper()
        rankPicker = UIPickerView.init()
        rankPicker.delegate = self
        rankPicker.backgroundColor = UIColor.white
        rankPicker.setValue(UIColor.black, forKey: "textColor")
        rankPicker.autoresizingMask = .flexibleWidth
        rankPicker.contentMode = .center
        rankPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 230)
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubview(rankPicker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
    }
    
    @IBAction func selectAgencyBtn(_ sender: Any) {
        removeFromSuper()
        agencyPicker = UIPickerView.init()
        agencyPicker.delegate = self
        agencyPicker.backgroundColor = UIColor.white
        agencyPicker.setValue(UIColor.black, forKey: "textColor")
        agencyPicker.autoresizingMask = .flexibleWidth
        agencyPicker.contentMode = .center
        agencyPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 230)
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubview(agencyPicker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
        
    }
    
    @IBAction func selectOfficeBtn(_ sender: Any) {
        removeFromSuper()
        officePicker = UIPickerView.init()
        officePicker.delegate = self
        officePicker.backgroundColor = UIColor.white
        officePicker.setValue(UIColor.black, forKey: "textColor")
        officePicker.autoresizingMask = .flexibleWidth
        officePicker.contentMode = .center
        officePicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 230)
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubview(officePicker)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
        
    }
    
    @IBAction func selectDesiredBtn(_ sender: Any) {
        // Handling Current Port & Desired Port in Same func
        
        let port : UIButton = sender as! UIButton
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "multiSelectionPopUpVC") as? multiSelectionPopUpVC
        btnSave.isHidden = false
        switch port.tag {
        case 10:
            portType = "current"
            selectedType = .current
        default:
            selectedType = .desired
            portType = "desired"
        }
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.present(vc!, animated: true, completion: nil)
        
    }
    
    @objc func onDoneButtonTapped() {
        print("Done Button Clicked")
        self.tabBarController?.tabBar.isHidden = false
        removeFromSuper()
    }
    
    func removeFromSuper(){
        toolBar.removeFromSuperview()
        rankPicker.removeFromSuperview()
        officePicker.removeFromSuperview()
        agencyPicker.removeFromSuperview()
    }
    
    func apiCall(){
        let url = MyProfileUrl
        //let myID = UserDefaults.standard.integer(forKey: "showID")
        let myID = LoginSession.getValueOf(key: SessionKeys.showId)
        
        Alamofire.request(url,  method: .post, parameters: ["user_id": myID]).responseJSON { response in
            let value = response.result.value as! [String:Any]?
            let BoolValue = value?["success"] as! Bool
            if(BoolValue == true) {
                let agency = value?["agency"] as! String
                let current_port = value?["current_port"] as! String
                let desire_port = value?["desire_port"] as! String
                let rank = value?["rank"] as! String
                let myName = "\(value?["username"] as! String)"
                self.userName.text = myName
                self.rankTextfld.text = rank
                self.currentPortTextFld.text = current_port
                self.desiredPortTextfld.text = desire_port
                self.officeTextfld.text = agency
            }else {
                let okAction: AlertButtonWithAction = (.ok, nil)
                self.showAlertWith(message: .custom("\(value?["message"] ?? "")")!, actions: okAction)
            }
        }
    }
    
    
    @IBAction func logoutBtnAction(_ sender: Any) {
        LoginSession.destroy()
        //        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        //        self.navigationController?.isNavigationBarHidden = true
        if let rootNavigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
            rootNavigationController.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        weak var weakSelf = self
        
        let rank = weakSelf!.rankTextfld.text!
        let office = weakSelf!.officeTextfld.text!
        let agency = weakSelf!.agencyTextfld.text!
        let currentPort = weakSelf!.currentPortTextFld.text!
        let desiredPort = weakSelf!.desiredPortTextfld.text!
        
        Utility.showActivityIndicator()
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            if let data = self.imageToUpload?.pngData() {
                multipartFormData.append(data, withName: "image", fileName: "image", mimeType: "")
            }
            
            multipartFormData.append("hello".data(using: .utf8, allowLossyConversion: false)!, withName: "firstname")
            multipartFormData.append("\(rank)".data(using: .utf8, allowLossyConversion: false)!, withName: "rank")
            multipartFormData.append("\(office)".data(using: .utf8, allowLossyConversion: false)!, withName: "office")
            multipartFormData.append("\(agency)".data(using: .utf8, allowLossyConversion: false)!, withName: "agency")
            multipartFormData.append("\(currentPort)".data(using: .utf8, allowLossyConversion: false)!, withName: "current_port")
            multipartFormData.append("\(desiredPort)".data(using: .utf8, allowLossyConversion: false)!, withName: "desire_port")
            multipartFormData.append(LoginSession.getValueOf(key: SessionKeys.showId).data(using: .utf8, allowLossyConversion: false)!, withName: "id")
        }, to: UpdateProfileUrl) { (encodingResult) in
            
            DispatchQueue.main.async {
                
                
                print("Encoding Result >>>>", encodingResult)
                
                Utility.hideActivityIndicator()
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response.result.value ?? [:])
                        self.btnSave.isHidden = true
                        let responseValue = response.result.value as! [String:Any]?
                        
                        LoginSession.saveValue(value: self.rankTextfld.text!, key: SessionKeys.rank)
                        LoginSession.saveValue(value: self.agencyTextfld.text!, key: SessionKeys.agency)
                        LoginSession.saveValue(value: self.officeTextfld.text!, key: SessionKeys.office)
                        LoginSession.saveValue(value: self.currentPortTextFld.text!, key: SessionKeys.currentPort)
                        LoginSession.saveValue(value: self.desiredPortTextfld.text!, key: SessionKeys.desiredPort)
                        
                        if(responseValue != nil) {
                            
                            let okAction: AlertButtonWithAction = (.ok, nil)
                            self.showAlertWith(message: .custom("\(responseValue?["message"] ?? "")")!, actions: okAction)
                            
                            let userDataArr:[[String: Any]] = responseValue?["userdata"] as? [[String : Any]] ?? []
                            let userData: [String : Any] = userDataArr[0] as? [String : Any] ?? [:]
                            LoginSession.saveValue(value: userData["image"] as! String, key: SessionKeys.image)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        }
    }
    
    //MARK:- Notification handler
    @objc func updateDesiredPort(notification: Notification) {
        let desiredPortVC = notification.object as! multiSelectionPopUpVC
        
        //for port in seletedDesiredPorts
        btnSave.isHidden = false
        if portType == "current"{
            self.currentPortTextFld.text = selectedCurrentPort
            return
        }
        
        var ports = ""
        var portsArray :[String] = []
        if selectedMultiPortIndexes.count > 0 {
            
            for index in selectedMultiPortIndexes {
                var desired = desiredPorts[index]
                portsArray.append(desired)
            }
            
            ports = portsArray.joined(separator: ",")
        }
        
        self.desiredPortTextfld.text = ports
    }
}

extension ProfileVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case rankPicker:
            return Ranks.count
        case agencyPicker:
            return Agencies.count
        case officePicker:
            return Officies.count
            
        default:
            return 0
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case rankPicker:
            return Ranks[row]
        case agencyPicker:
            return Agencies[row]
        case officePicker:
            return Officies[row]
            
        default:
            return "Invalid Request"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        btnSave.isHidden = false
        switch pickerView {
        case rankPicker:
            rankTextfld.text = Ranks[row]
            //removeFromSuper()
        case agencyPicker:
            agencyTextfld.text = Agencies[row]
            //removeFromSuper()
        case officePicker:
            officeTextfld.text = Officies[row]
            //removeFromSuper()
        default:
            print("Invalid Request")
        }
    }
}

extension ProfileVC: ImagePickerDelegate {
    
    /*
     Delegate Function, Called when User Clicked the Image
     If image Captured, we need to show the List of tickets to Choose
     else ...
     */
    func didSelect(image: UIImage?)
    {
        print("picked image")
        // self.removeStepsView()
        if image != nil
        {
            self.imageToUpload = image
            self.userImage.image = self.imageToUpload
        }
    }
    
    func didSelectUrl(urlStr: String?)
    {
        print("picked image url")
        // self.removeStepsView()
        if urlStr != nil
        {
            self.imageToUploadURL = urlStr
            
            // Create URL
            let url = URL(string: urlStr ?? "")
            
            // Fetch Image Data
            if let data = try? Data(contentsOf: url!) {
                // Create Image and Update Image View
                self.userImage.image = UIImage(data: data)
            }
        }
        
    }
    
    func didCancelActionSheet()
    {
        print("cancelled")
        //self.removeStepsView()
        //        self.scannerController().startScanningMetaData()
    }
}
