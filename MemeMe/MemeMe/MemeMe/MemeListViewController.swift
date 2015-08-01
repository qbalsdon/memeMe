//
//  MemeListViewController.swift
//  MemeMe
//
//  Created by Quintin Balsdon on 2015/08/01.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import UIKit

class MemeListViewController: DisplayViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var memeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.memeTableView!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! UITableViewCell
        let meme = self.dataSource[indexPath.row]
        
        // Set the name and image
        cell.textLabel?.text = meme.topText
        cell.imageView?.image = meme.memeImage
        
        // If the cell has a detail label, we will put the evil scheme in.
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = meme.bottomText
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let meme = self.dataSource[indexPath.row] as Meme
        showMeme(meme)
    }

}
