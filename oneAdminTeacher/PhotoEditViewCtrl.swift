//
//  PhotoEditViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import AssetsLibrary

class PhotoEditViewCtrl: UIViewController,UIImagePickerControllerDelegate,ELCImagePickerControllerDelegate,UITextViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var CloseBtn: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var TextViewHeight: NSLayoutConstraint!
    
    var ManualyBtn : UIButton!
    var AutoBtn : UIButton!
    
    var _TagSelector = TagSelector()
    
    var Base : PreviewData!
    var Comment : String!
    var _tmpComment : String!
    
    var _selectedImg = [UIImage]()
    
    var GroupData : GroupItem!
    
    var _photoCount = 0
    
    var _defaultText = "寫下您的照片註解吧..."
    
    
    var KeyBoardHeight : CGFloat = 0
    
    @IBAction func ManualyTag(sender: AnyObject) {
        
        let selector = self.storyboard?.instantiateViewControllerWithIdentifier("StudentTagViewCtrl") as! StudentTagViewCtrl
        
        selector._TagSelector = _TagSelector
        
        self.navigationController?.pushViewController(selector, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CloseBtn.hidden = true
        
        textView.delegate = self
        
        self.navigationItem.title = "新增照片"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "SavePhoto")
        
        ManualyBtn = self.view.viewWithTag(100) as! UIButton
        AutoBtn = self.view.viewWithTag(200) as! UIButton
        
        ManualyBtn.enabled = false
        AutoBtn.enabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillDisappear(animated: Bool) {
        _tmpComment = textView.text
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.SetTagLabel()
        
        if !ManualyBtn.enabled{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
               var members = self.GetGroupMembers()
               var selected = self.GetDataTags()
                
                dispatch_async(dispatch_get_main_queue(), {
                    self._TagSelector.List = members
                    self._TagSelector.Selected = selected
                    self.ManualyBtn.enabled = true
                    self.SetTagLabel()
                })
            })
        }
        
        if let base = Base{
            
            if let img = PhotoCoreData.LoadDetailData(base){
                _selectedImg = [img]
            }
            
            if let tmpComment = _tmpComment where tmpComment != _defaultText{
                textView.text = tmpComment
            }
            else if let comment = Comment{
                textView.text = comment.isEmpty ? _defaultText : comment
                textView.textColor = comment.isEmpty ? UIColor.lightGrayColor() : UIColor.blackColor()
            }
            
        }
        
        RegisterForKeyboardNotifications(self)
        
        if _photoCount == 0 || _photoCount != _selectedImg.count{
            ResetScrollView()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView){
        
        if textView.text == _defaultText {
            textView.textColor = UIColor.blackColor()
            textView.text = ""
        }
        
        CloseBtn.hidden = false
        
        TextViewHeight.constant = KeyBoardHeight > 200 ? KeyBoardHeight - 200 : 0
    }
    
    func textViewDidEndEditing(textView: UITextView){
        
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = _defaultText
        }
        
        CloseBtn.hidden = true
        
        TextViewHeight.constant = 0
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func AddPhoto() {
        
        let select = UIAlertController(title: "要從何處選擇照片？", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        select.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        select.addAction(UIAlertAction(title: "從相簿選取", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                
                let customPicker = ELCImagePickerController(imagePicker: ())
                customPicker.maximumImagesCount = 10 //Set the maximum number of images to select, defaults to 4
                customPicker.returnsOriginalImage = false //Only return the fullScreenImage, not the fullResolutionImage
                customPicker.returnsImage = true //Return UIimage if YES. If NO, only return asset location information
                customPicker.onOrder = true //For multiple image selection, display and return selected order of images
                customPicker.imagePickerDelegate = self
                
                self.presentViewController(customPicker, animated: true, completion: nil)
            }
            
        }))
        
        select.addAction(UIAlertAction(title: "從相機拍攝", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                
                let picker: UIImagePickerController = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = .Camera
                //_picker.showsCameraControls = false
                
                self.presentViewController(picker, animated: true, completion: nil)
            }
            
        }))
        
        self.presentViewController(select, animated: true, completion: nil)
    }
    
    //相機使用
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        
        let choseImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //縮小一半尺寸
        //var shrinkedImage = choseImage.GetResizeImage(0.5)
        
        _selectedImg.append(choseImage.GetResizeImage(0.5))
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //相簿使用
    func elcImagePickerController(picker:ELCImagePickerController, didFinishPickingMediaWithInfo info:[AnyObject]) -> (){
        
        for each in info{
            
            let img = each[UIImagePickerControllerOriginalImage] as! UIImage
            //縮小尺寸
            //var shrinkedImage = img.GetResizeImage(0.8)
            
            _selectedImg.append(img.GetResizeImage(0.8))
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func elcImagePickerControllerDidCancel(picker:ELCImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func ResetScrollView(){
        
        _photoCount = _selectedImg.count
        
        for ss in self.scrollView.subviews as! [UIView]{
            ss.removeFromSuperview()
        }
        
        for child in self.childViewControllers{
            child.removeFromParentViewController()
        }
        
        var xPoint = CGFloat(10)
        
        var index = 0
        
        for img in self._selectedImg{
            
            let sub = self.storyboard?.instantiateViewControllerWithIdentifier("UploadPhotoFrame") as! UploadPhotoFrame
            
            sub.img = img
            sub.Index = index
            
            sub.deleteFromParent = {
                
                self._selectedImg.removeAtIndex(sub.Index)
                
                self.ResetScrollView()
            }
            
            sub.view.frame = CGRectMake(xPoint, 0, 140, 140)
            
            self.scrollView.addSubview(sub.view)
            self.addChildViewController(sub)
            
            xPoint += 150
            
            index++
        }
        
        if Base == nil{
            //Add function view
            let function = self.storyboard?.instantiateViewControllerWithIdentifier("UploadPhotoFunc") as! UploadPhotoFunc
            
            function.Delegate = {
                self.AddPhoto()
            }
            
            function.view.frame = CGRectMake(xPoint, 0, 140, 140)
            
            self.scrollView.addSubview(function.view)
            self.addChildViewController(function)
            
            xPoint += 150
        }
        
        self.scrollView.contentSize = CGSize(width: xPoint, height: self.scrollView.bounds.size.height)
    }
    
    func SavePhoto(){
        
        self.view.endEditing(true)
        
        //insert
        if Base == nil{
            InsertPhoto()
        }
        else{
            //update
            UpdatePhoto()
        }
        
        Global.MyToast.ToastMessage(self.view, msg: "儲存完成...") { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func InsertPhoto(){
        
        Global.PhotoNeedReload = true
        
        let comment = textView.text == _defaultText ? "" : textView.text
        
        var con = GetCommonConnect(GroupData.DSNS, Global.TeacherContractName)
        
        for img in _selectedImg{
            
            var err : DSFault!
            
            let previewBase64 = GetBase64FromImage(img.GetResizeImage(0.33),0.5)
            let detailBase64 = GetBase64FromImage(img,0.8)
            
            var rsp = con.SendRequest("main.InsertPhoto", bodyContent: "<Request><Epf.data><DetailData>\(detailBase64)</DetailData><PreviewData>\(previewBase64)</PreviewData><RefGroupId>\(GroupData.GroupId)</RefGroupId><Comment>\(comment)</Comment></Epf.data></Request>", &err)
            
            var error : NSError?
            var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &error)
            
            if let newId = xml?.root["Result"]["NewID"].stringValue{
                SaveTags(newId)
            }
        }
    }
    
    func UpdatePhoto(){
        
        let comment = textView.text == _defaultText ? "" : textView.text
        
        var con = GetCommonConnect(Base.Dsns, Global.TeacherContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("main.UpdatePhoto", bodyContent: "<Request><Epf.data><Field><Comment>\(comment)</Comment></Field><UID>\(Base.Uid)</UID></Epf.data></Request>", &err)
        
        if rsp.isEmpty{
            println(err.message)
        }
        
        SaveTags(Base.Uid)
    }
    
    func SaveTags(refDataId:String){
        
        if _TagSelector.Selected.count == 0{
            return
        }
        
        var studentIds = ""
        
        for s in _TagSelector.Selected{
            studentIds += "<StudentId>" + s.StudentId + "</StudentId>"
        }
        
        let dsns = Base != nil ? Base.Dsns : GroupData.DSNS
        
        var con = GetCommonConnect(dsns, Global.TeacherContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("main.UpdateTag", bodyContent: "<Request><RefDataId>\(refDataId)</RefDataId><Students>\(studentIds)</Students></Request>", &err)
        
        if rsp.isEmpty{
            println(err.message)
        }
    }
    
    func GetGroupMembers() -> [TagStudent]{
        
        var retVal = [TagStudent]()
        
        let dsns = Base == nil ? GroupData.DSNS : Base.Dsns
        let groupId = Base == nil ? GroupData.GroupId : Base.Group
        
        var rsp = HttpClient.Get("https://dsns.1campus.net/\(dsns)/sakura/GetGroupMember?stt=PassportAccessToken&AccessToken=\(Global.AccessToken)&parser=spliter&content=GroupId:\(groupId)")
        
        if rsp == nil{
            return retVal
        }
        
        var nserr : NSError?
        var xml = AEXMLDocument(xmlData: rsp!, error: &nserr)
        
        if nserr != nil{
            return retVal
        }
        
        if let students = xml?.root["Group"]["Student"].all{
            
            for student in students{
                
                let studentId = student["StudentId"].stringValue
                let studentName = student["StudentName"].stringValue
                let seatNo = student["SeatNo"].intValue
                
                var ts = TagStudent(StudentId: studentId, StudentName: studentName, SeatNo: seatNo)
                
                retVal.append(ts)
            }
        }
        
        retVal.sort({ $0.SeatNo < $1.SeatNo})
        
        return retVal
    }
    
    func GetDataTags() -> [TagStudent]{
        
        var retVal = [TagStudent]()
        
        if Base == nil{
            return retVal
        }
        
        var con = GetCommonConnect(Base.Dsns, Global.TeacherContractName)
        
        var err : DSFault!
        
        var rsp = con.SendRequest("main.GetPhotoTag", bodyContent: "<Request><RefDataId>\(Base.Uid)</RefDataId></Request>", &err)
        
        if rsp.isEmpty{
            println(err.message)
            return retVal
        }
        
        var nserr : NSError?
        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if nserr != nil{
            return retVal
        }
        
        if let tags = xml?.root["Response"]["Epf.data.tag"].all{
            
            for tag in tags{
                
                let refStudentId = tag["RefStudentId"].stringValue
                let studentName = tag["StudentName"].stringValue
                
                retVal.append(TagStudent(StudentId: refStudentId, StudentName: studentName, SeatNo: 0))
            }
        }
        
        return retVal
    }
    
    @IBAction func CloseKeyboard(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWillBeShown(sender: NSNotification) {
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        
        KeyBoardHeight = keyboardSize.height > 252 ? keyboardSize.height : 252
    }
    
    func SetTagLabel(){
        
        if _TagSelector.Selected.count > 0 {
            tagLabel.text = "標記了: \(_TagSelector.Selected[0].StudentName)...等\(_TagSelector.Selected.count)人"
        }
        else{
            tagLabel.text = "尚未進行任何標記"
        }
    }

}

struct TagStudent:Equatable{
    var StudentId : String
    var StudentName : String
    var SeatNo : Int
}

func ==(lhs: TagStudent, rhs: TagStudent) -> Bool {
    return lhs.StudentId == rhs.StudentId
}

class TagSelector{
    
    var List = [TagStudent]()
    var Selected = [TagStudent]()
    
    func IndexOf(student:TagStudent) -> Int{
        
        var index = 0
        
        for s in Selected{
            if s == student{
                return index
            }
            
            index++
        }
        
        return -1
    }
}
