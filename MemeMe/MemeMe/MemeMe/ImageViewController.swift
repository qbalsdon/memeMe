//
//  ImageViewController.swift
//  MemeMe
//
//  Created by Quintin Balsdon on 2015/08/01.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class ImageViewController: MemeManagerViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var editBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editTapped:")
        leftShareBarButtonItem.enabled = false
        self.navigationItem.setLeftBarButtonItems([editBarButtonItem], animated: true)
        
        imageView.image = currentMeme.memeImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func editTapped(button: UIBarButtonItem!){
        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditorNav") as! MemeEditorViewController
        secondViewController.currentMeme = currentMeme
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}
