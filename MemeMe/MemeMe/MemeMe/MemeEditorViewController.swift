//
//  ViewController.swift
//  MemeMe
//
//  Created by Quintin Balsdon on 2015/08/01.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let EXTRAS = "url_m"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"

class MemeEditorViewController: MemeManagerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet weak var takePictureButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
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
        navigationController?.setToolbarHidden(false, animated: false)
        if (UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera) == nil){
            takePictureButton.enabled = false
        }
        
        if (currentMeme != nil){
            topText.text = currentMeme.topText
            bottomText.text = currentMeme.bottomText
            
            imageToEdit.image = currentMeme.originalImage
            leftShareBarButtonItem.enabled = true
        }
        stopLoadingAnimation()
    }

    override func viewWillAppear(animated: Bool) {
        subscribeToKeyBoardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyBoardNotifications()
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
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        return memedImage
    }
    
    //MARK: UIImagePickerController delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        dismissViewControllerAnimated(true, completion: nil)
        imageToEdit.image = image
        leftShareBarButtonItem.enabled = true
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getPicture(sourceType: UIImagePickerControllerSourceType){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        presentViewController(imagePickerController, animated: true, completion: nil)
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
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
            view.frame.origin.y = 0
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
    
    @IBAction func pickFlickImagePressed(sender: AnyObject) {
        var searchTextField: UITextField?
        let alertController = UIAlertController(title: "Find Flick", message: "Search for a random Flickr image", preferredStyle: .Alert)
        
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let text = (alertController.textFields?.first as! UITextField).text
            if (text.isEmpty){
                self.showMessage("Error", message: "Cannot search for nothing")
                return
            }
            self.findImage(text)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            println("Cancel Button Pressed")
        }
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            // Enter the textfiled customization code here.
            searchTextField = textField
            searchTextField?.delegate = self
            searchTextField?.placeholder = "Enter your search terms"
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: FlickR find image
    func findImage(searchText: String!){
        loadingActivityIndicator.hidden = false
        loadingActivityIndicator.startAnimating();
        var keys: NSDictionary?
        var apiKey: String!
        
        if let path = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            apiKey = keys?["FLICKR_PUBLIC_KEY"] as? String
        }
        
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": apiKey,
            "text":searchText,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "per_page": "500",
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
                self.showMessage("Error", message: "Could not complete the request \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                println(parsedResult)
                if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                    
                    if let photoCount = photosDictionary["total"] as? String{
                        let count = (photoCount as NSString).integerValue
                        if (count <= 0){
                            self.showMessage("Error", message: "No photos found")
                            println("No photos found")
                            return
                        }
                    }
                    
                    if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                        
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                        
                        let photoTitle = photoDictionary["title"] as? String
                        let imageUrlString = photoDictionary["url_m"] as? String
                        let imageURL = NSURL(string: imageUrlString!)
                        
                        if let imageData = NSData(contentsOfURL: imageURL!) {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.imageToEdit.image = UIImage(data: imageData)
                                self.stopLoadingAnimation()
                            })
                        } else {
                            self.showMessage("Error", message: "Image does not exist at \(imageURL)")
                            println("Image does not exist at \(imageURL)")
                            self.stopLoadingAnimation()
                        }
                    } else {
                        self.showMessage("Error", message: "Cant find key 'photo' in \(photosDictionary)")
                        println("Cant find key 'photo' in \(photosDictionary)")
                        self.stopLoadingAnimation()
                    }
                } else {
                    self.showMessage("Error", message: "Cant find key 'photos' in \(parsedResult)")
                    println("Cant find key 'photos' in \(parsedResult)")
                    self.stopLoadingAnimation()
                }
            }
        }
        task.resume()
    }
    
    //MARK: Helper Methods
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    func stopLoadingAnimation() {
        loadingActivityIndicator.hidden = true
        loadingActivityIndicator.stopAnimating();
    }
    
    func showMessage(title: String!, message: String!){
        var searchTextField: UITextField?
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Ok", style: .Cancel) { (action) -> Void in
        }
        
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)

    }
}

