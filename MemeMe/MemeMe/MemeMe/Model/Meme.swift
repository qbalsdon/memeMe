//
//  Meme.swift
//  MemeMe
//
//  Created by Quintin Balsdon on 2015/08/01.
//  Copyright (c) 2015 Quintin Balsdon. All rights reserved.
//

import Foundation
import UIKit

class Meme{
    var topText: String!
    var bottomText: String!
    
    var originalImage: UIImage!
    var memeImage: UIImage!
    
    init(topText: String!, bottomText: String!, originalImage: UIImage!, memeImage: UIImage!){
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memeImage = memeImage
    }
}