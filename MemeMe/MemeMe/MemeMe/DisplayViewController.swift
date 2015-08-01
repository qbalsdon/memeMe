//
//  DisplayViewController.swift
//  MemeMe
//
//  Created by Quintin Balsdon on 2015/08/01.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class DisplayViewController: UIViewController {
    
    internal var dataSource: [Meme]!
    var secondViewController: MemeManagerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTapped:")
        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem], animated: true)
    }
    

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        dataSource = (UIApplication.sharedApplication().delegate as! AppDelegate).memeData;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func addTapped(sender:UIButton) {
        showMeme(nil)
    }

    internal func showMeme(memeToShow: Meme!){
        secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MemeViewNav") as! ImageViewController

        if (memeToShow == nil){
            secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorNav") as! MemeEditorViewController
        }
        
        secondViewController.currentMeme = memeToShow
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
}
