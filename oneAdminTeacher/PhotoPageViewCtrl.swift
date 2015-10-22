//
//  PhotoPageViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/16/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class PhotoPageViewCtrl: UIViewController,UIScrollViewDelegate
{
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var Base : PreviewData!
    var Index = 0
    
    var TeacherMode = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        scrView.delegate = self
        scrView.maximumZoomScale = 4.0
        scrView.minimumZoomScale = 1.0
        scrView.showsHorizontalScrollIndicator = false
        scrView.showsVerticalScrollIndicator = false
        
        let scrViewDoubleTap = UITapGestureRecognizer(target: self, action: "DoubleTap")
        scrViewDoubleTap.numberOfTapsRequired = 2
        
        scrView.addGestureRecognizer(scrViewDoubleTap)
        
        var longPress = UILongPressGestureRecognizer(target: self, action: "LongPress")
        longPress.minimumPressDuration = 0.5
        
        imgView.addGestureRecognizer(longPress)

        if let detail = PhotoCoreData.LoadDetailData(Base){
            
            self.imgView.image = detail
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                var value = self.GetDetailData(true)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.SetTextView(value.0)
                })
            })
        }
        else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                var value = self.GetDetailData(false)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.SetTextView(value.0)
                    self.imgView.image = value.1
                    
                    PhotoCoreData.UpdateCatchData(self.Base, detail: value.1)
                })
            })
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func DoubleTap(){
        if scrView.zoomScale < 4.0{
            scrView.zoomScale = 4.0
        }
        else{
            scrView.zoomScale = 1.0
        }
    }
    
    func SetTextView(text:String){
        self.textView.text = text
        self.textView.textColor = UIColor.whiteColor()
        self.textView.font = UIFont.systemFontOfSize(16)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView){
        textView.hidden = scrollView.zoomScale == 1 ? false : true
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?{
        return self.imgView
    }
    
    func GetDetailData(commentOnly:Bool) -> (String,UIImage){
        
        var fields = commentOnly ? "<Field><Comment></Comment></Field>" : "<Field><Comment></Comment><DetailData></DetailData></Field>"
        
        var retVal = ("",UIImage())
        
        var con = GetCommonConnect(Base.Dsns, Global.TeacherContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("main.GetDetailData", bodyContent: "<Request>\(fields)<Uid>\(Base.Uid)</Uid></Request>", &err)
        
        if rsp.isEmpty{
            return retVal
        }
        
        var nserr : NSError?
        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if nserr != nil{
            return retVal
        }
        
        if let comment = xml?.root["Response"]["Epf.data"]["Comment"].stringValue{
            retVal.0 = comment
        }
        
        if let detailData = xml?.root["Response"]["Epf.data"]["DetailData"].stringValue{
            retVal.1 =  GetImageFromBase64(detailData)
        }
        
        return retVal
    }
    
    func DeletePhoto(){
        
        Global.PhotoNeedReload = true
        
        var con = GetCommonConnect(Base.Dsns, Global.TeacherContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("main.DeletePhoto", bodyContent: "<Request><epf.data><Uid>\(Base.Uid)</Uid><RefGroupId>\(Base.Group)</RefGroupId></epf.data></Request>", &err)
        
        rsp = con.SendRequest("main.UpdateTag", bodyContent: "<Request><DeleteOnly>true</DeleteOnly><RefDataId>\(Base.Uid)</RefDataId></Request>", &err)
        
        Global.MyToast.ToastMessage(self.view, msg: "刪除完成...") { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func SavePhoto(){
        //儲存圖片到本機相簿
        UIImageWriteToSavedPhotosAlbum(self.imgView.image, self, nil, nil)
        Global.MyToast.ToastMessage(self.view, msg: "下載完成...",callback : nil)
    }
    
    func EditPhoto(){
        
        let editor = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoEditViewCtrl") as! PhotoEditViewCtrl
        editor.Base = Base
        editor.Comment = textView.text
        
        self.navigationController?.pushViewController(editor, animated: true)
    }
    
    func LongPress(){
        
        let menu = UIAlertController(title: "要做什麼呢？", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        menu.addAction(UIAlertAction(title: "下載圖片", style: UIAlertActionStyle.Default, handler: { (ACTION) -> Void in
           self.SavePhoto()
        }))
        
        //老師模式才有的功能
        if TeacherMode{
            
            menu.addAction(UIAlertAction(title: "刪除圖片", style: UIAlertActionStyle.Default, handler: { (ACTION) -> Void in
                //刪除圖片
                self.DeletePhoto()
            }))
            
            menu.addAction(UIAlertAction(title: "編輯註解", style: UIAlertActionStyle.Default, handler: { (ACTION) -> Void in
                //編輯註解
                self.EditPhoto()
            }))
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
    }
}
