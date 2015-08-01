//
//  ViewController.swift
//  MemeMe
//
//  Created by Quintin Balsdon on 2015/08/01.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class MemeEditorViewController: MemeManagerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet weak var takePictureButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    var activeTextField: UITextField!
    
    //MARK: ViewController overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        topText.delegate = self
        bottomText.delegate = self
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSStrokeWidthAttributeName : NSNumber(float: -5.0),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        ]
        
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        
        topText.textAlignment = .Center
        bottomText.textAlignment = .Center
        self.navigationController?.setToolbarHidden(false, animated: false)
        if (UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera) == nil){
            takePictureButton.enabled = false
        }
        
        if (currentMeme != nil){
            topText.text = currentMeme.topText
            bottomText.text = currentMeme.bottomText
            
            imageToEdit.image = currentMeme.originalImage
            leftShareBarButtonItem.enabled = true
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.subscribeToKeyBoardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.unsubscribeToKeyBoardNotifications()
    }
    
    override func actionTapped(sender: AnyObject) {
        saveMeme()
        super.actionTapped(sender)
    }
    
    //MARK: Model Methods
    func saveMeme() {
        //Create the meme
        currentMeme = Meme( topText: topText.text, bottomText: bottomText.text, originalImage: imageToEdit.image, memeImage: generateMemedImage())
        (UIApplication.sharedApplication().delegate as! AppDelegate).memeData.append(currentMeme)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        return memedImage
    }
    
    //MARK: UIImagePickerController delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        imageToEdit.image = image
        leftShareBarButtonItem.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getPicture(sourceType: UIImagePickerControllerSourceType){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK:UITextFieldDelegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Keyboard Handler Methods
    func subscribeToKeyBoardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyBoardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        if (activeTextField == bottomText){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
            self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    //MARK: IBActions
    @IBAction func pickImagePressed(sender: AnyObject) {
        getPicture(UIImagePickerControllerSourceType.PhotoLibrary)
    }

    @IBAction func takePicturePressed(sender: AnyObject) {
        getPicture(UIImagePickerControllerSourceType.Camera)
    }
    
}

