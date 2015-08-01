//
//  MemeManagerViewController.swift
//  MemeMe
//
//  Created by Quintin Balsdon on 2015/08/01.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class MemeManagerViewController: UIViewController {
    internal var leftShareBarButtonItem: UIBarButtonItem!
    internal var currentMeme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelTapped:")
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem], animated: true)
        
        leftShareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "actionTapped:")
        leftShareBarButtonItem.enabled = false
        self.navigationItem.setLeftBarButtonItems([leftShareBarButtonItem], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func actionTapped(sender: AnyObject) {
        
        let objectsToShare = [currentMeme.memeImage]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.completionWithItemsHandler = actionCompleted
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func actionCompleted(activityType: String!, completed: Bool, returnedItems: [AnyObject]!, error: NSError!) {
        // Return if cancelled
        if (!completed) {
            return
        }
        close()
    }
    
    func cancelTapped(sender: UIBarButtonItem){
        close()
    }
    
    func close(){
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
}
