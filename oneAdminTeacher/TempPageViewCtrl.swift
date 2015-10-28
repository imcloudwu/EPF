//
//  TempPageViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/22/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class TempPageViewCtrl: UIViewController {
    
    var SubText : String!
    
    @IBOutlet weak var Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Label.text = SubText
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}