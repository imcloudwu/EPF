//
//  TempPageViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/22/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class TempPageViewCtrl: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var StudentData : Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height = Global.ScreenSize.width * 0.75
        
        if StudentData.Name == "黃小翔"{
            
            var yPostiton = CGFloat(0)
            
            let a = UIImageView(image: UIImage(named: "ScreenHunter.jpg"))
            a.frame.size = CGSizeMake(Global.ScreenSize.width, height)
            a.frame.origin.x = 0
            a.frame.origin.y = 0
            a.contentMode = UIViewContentMode.ScaleToFill
            yPostiton += a.frame.size.height + 10
            
            let b = UIImageView(image: UIImage(named: "黃小翔健康資料.jpg"))
            b.frame.size = CGSizeMake(Global.ScreenSize.width, height)
            b.frame.origin.x = 0
            b.frame.origin.y = yPostiton
            b.contentMode = UIViewContentMode.ScaleToFill
            yPostiton += b.frame.size.height + 10
            
            let c = UIImageView(image: UIImage(named: "黃小翔身高曲線圖.jpg"))
            c.frame.size = CGSizeMake(Global.ScreenSize.width, Global.ScreenSize.width)
            c.frame.origin.x = 0
            c.frame.origin.y = yPostiton
            c.contentMode = UIViewContentMode.ScaleToFill
            yPostiton += c.frame.size.height + 10
            
            let d = UIImageView(image: UIImage(named: "黃小翔體重曲線圖.jpg"))
            d.frame.size = CGSizeMake(Global.ScreenSize.width, Global.ScreenSize.width)
            d.frame.origin.x = 0
            d.frame.origin.y = yPostiton
            d.contentMode = UIViewContentMode.ScaleToFill
            yPostiton += d.frame.size.height + 10
            
            scrollView.contentSize = CGSizeMake(Global.ScreenSize.width, yPostiton)
            
            scrollView.addSubview(a)
            scrollView.addSubview(b)
            scrollView.addSubview(c)
            scrollView.addSubview(d)
        }
        else{
            
            var yPostiton = CGFloat(0)
            
            let a = UIImageView(image: UIImage(named: "ScreenHunter.jpg"))
            a.frame.size = CGSizeMake(Global.ScreenSize.width, height)
            a.frame.origin.x = 0
            a.frame.origin.y = 0
            a.contentMode = UIViewContentMode.ScaleToFill
            yPostiton += a.frame.size.height + 10
            
            let b = UIImageView(image: UIImage(named: "黃小悅健康資料.jpg"))
            b.frame.size = CGSizeMake(Global.ScreenSize.width, height)
            b.frame.origin.x = 0
            b.frame.origin.y = yPostiton
            b.contentMode = UIViewContentMode.ScaleToFill
            yPostiton += b.frame.size.height + 10
            
            let c = UIImageView(image: UIImage(named: "黃小悅身高曲線圖.jpg"))
            c.frame.size = CGSizeMake(Global.ScreenSize.width, Global.ScreenSize.width)
            c.frame.origin.x = 0
            c.frame.origin.y = yPostiton
            c.contentMode = UIViewContentMode.ScaleToFill
            yPostiton += c.frame.size.height + 10
            
            let d = UIImageView(image: UIImage(named: "黃小悅體重曲線圖.jpg"))
            d.frame.size = CGSizeMake(Global.ScreenSize.width, Global.ScreenSize.width)
            d.frame.origin.x = 0
            d.frame.origin.y = yPostiton
            d.contentMode = UIViewContentMode.ScaleToFill
            yPostiton += d.frame.size.height + 10
            
            scrollView.contentSize = CGSizeMake(Global.ScreenSize.width, yPostiton)
            
            scrollView.addSubview(a)
            scrollView.addSubview(b)
            scrollView.addSubview(c)
            scrollView.addSubview(d)

        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}