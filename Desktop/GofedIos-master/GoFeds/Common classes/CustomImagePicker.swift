//
//  CustomImagePicker.swift
//  POSAPP
//
//  Created by osx on 30/05/19.
//  Copyright © 2019 intersoft-parminder. All rights reserved.
//

import Foundation
import UIKit

public protocol ImagePickerDelegate: class
{
    func didSelect(image: UIImage?)
    func didSelectUrl(urlStr: String?)
    func didCancelActionSheet()
}

open class CustomImagePicker: NSObject
{
    private let pickerController: UIImagePickerController
    weak private var presentationController: UIViewController?
    weak private var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate)
    {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction?
    {
        guard UIImagePickerController.isSourceTypeAvailable(type) else
        {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func presentOnlyCamera(from sourceView: UIView)
    {
        self.pickerController.sourceType = .camera
        self.presentationController?.present(self.pickerController, animated: true)
//        SnackBarHandler.shared.snackBarWithBottomMargin(LocalizedText.shared.scanExceptionStep2, .middle, {
//            print("")
//        })
    }
    
    public func present(from sourceView: UIView)
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo")
        {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library")
        {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.delegate?.didCancelActionSheet()
        }))
        
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?)
    {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
}

extension CustomImagePicker: UIImagePickerControllerDelegate
{
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
//        guard let url = info[.imageURL] as? String else {
//            return (self.delegate?.didSelectUrl(urlStr: ""))!
//        }
//        self.delegate?.didSelectUrl(urlStr: url )
        guard let image = info[.editedImage] as? UIImage else
        {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension CustomImagePicker: UINavigationControllerDelegate
{
}
