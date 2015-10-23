//
//  Functions.swift
//  EPF
//
//  Created by Cloud on 10/23/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation

func GetMyChildren(con:Connection) -> [Student]{
    
    var err : DSFault!
    var nserr : NSError?
    
    var retVal = [Student]()
    
    var rsp = con.sendRequest("main.GetMyChildren", bodyContent: "", &err)
    
    //println(rsp)
    
    if err != nil{
        //ShowErrorAlert(self,"取得資料發生錯誤",err.message)
        return retVal
    }
    
    let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
    
    if let students = xml?.root["Student"].all {
        for stu in students{
            //println(stu.xmlString)
            let studentID = stu["StudentId"].stringValue
            let className = stu["ClassName"].stringValue
            let studentName = stu["StudentName"].stringValue
            let seatNo = stu["SeatNo"].stringValue
            let studentNumber = stu["StudentNumber"].stringValue
            let gender = stu["Gender"].stringValue
            let mailingAddress = stu["MailingAddress"].xmlString
            let permanentAddress = stu["PermanentAddress"].xmlString
            let contactPhone = stu["ContactPhone"].stringValue
            let permanentPhone = stu["PermanentPhone"].stringValue
            let custodianName = stu["CustodianName"].stringValue
            let fatherName = stu["FatherName"].stringValue
            let motherName = stu["MotherName"].stringValue
            let freshmanPhoto = GetImageFromBase64String(stu["StudentPhoto"].stringValue, UIImage(named: "User-100.png"))
            
            let stuItem = Student(DSNS: con.accessPoint,ID: studentID, ClassID: "", ClassName: className, Name: studentName, SeatNo: seatNo, StudentNumber: studentNumber, Gender: gender, MailingAddress: mailingAddress, PermanentAddress: permanentAddress, ContactPhone: contactPhone, PermanentPhone: permanentPhone, CustodianName: custodianName, FatherName: fatherName, MotherName: motherName, Photo: freshmanPhoto)
            
            retVal.append(stuItem)
        }
    }
    
    retVal.sort{ $0.SeatNo.toInt() < $1.SeatNo.toInt() }
    
    if retVal.count > 0{
        
        let schoolName = GetSchoolName(con)
        
        retVal.insert(Student(DSNS: "header", ID: "", ClassID: "", ClassName: schoolName, Name: "", SeatNo: "", StudentNumber: "", Gender: "", MailingAddress: "", PermanentAddress: "", ContactPhone: "", PermanentPhone: "", CustodianName: "", FatherName: "", MotherName: "", Photo: nil), atIndex: 0)
    }
    
    return retVal
}

func GetMyChildGroup(StudentData:Student) -> [GroupItem]{
    
    var retVal = [GroupItem]()
    
    var rsp = HttpClient.Get("https://dsns.1campus.net/\(StudentData.DSNS)/sakura/GetMyChild?stt=PassportAccessToken&AccessToken=\(Global.AccessToken)")
    
    if rsp == nil{
        return retVal
    }
    
    var nserr : NSError?
    var xml = AEXMLDocument(xmlData: rsp!, error: &nserr)
    
    if nserr != nil{
        return retVal
    }
    
    if let children = xml?.root["Child"].all{
        
        for child in children{
            
            if child["ChildId"].stringValue != StudentData.ID{
                continue
            }
            
            if let groups = child["Group"].all{
                
                for group in groups{
                    
                    let groupId = group["GroupId"].stringValue
                    let groupName = group["GroupName"].stringValue
                    let groupOriginal = group["GroupOriginal"].stringValue
                    
                    var gi = GroupItem(DSNS: StudentData.DSNS, GroupId: groupId, GroupName: groupName, IsTeacher: false)
                    retVal.append(gi)
                }
            }
        }
    }
    
    return retVal
}

func GetMyChildGroup(dsns:DsnsItem) -> [GroupItem]{
    
    var retVal = [GroupItem]()
    
    var rsp = HttpClient.Get("https://dsns.1campus.net/\(dsns.AccessPoint)/sakura/GetMyChild?stt=PassportAccessToken&AccessToken=\(Global.AccessToken)")
    
    if rsp == nil{
        return retVal
    }
    
    var nserr : NSError?
    var xml = AEXMLDocument(xmlData: rsp!, error: &nserr)
    
    if nserr != nil{
        return retVal
    }
    
    if let children = xml?.root["Child"].all{
        
        for child in children{
            
            if let groups = child["Group"].all{
                
                for group in groups{
                    
                    let groupId = group["GroupId"].stringValue
                    let groupName = group["GroupName"].stringValue
                    let groupOriginal = group["GroupOriginal"].stringValue
                    
                    var gi = GroupItem(DSNS: dsns.AccessPoint, GroupId: groupId, GroupName: groupName, IsTeacher: false)
                    retVal.append(gi)
                }
            }
        }
    }
    
    return retVal
}

func UpdatePreviewData(data:PreviewData) -> Bool {
    
    var con = GetCommonConnect(data.Dsns, Global.BasicContractName)
    
    var err : DSFault!
    
    var rsp = con.SendRequest("album.GetPreviewData", bodyContent: "<Request><Uid>\(data.Uid)</Uid></Request>", &err)
    
    if rsp.isEmpty{
        return false
    }
    
    var nserr : NSError?
    var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
    
    if nserr != nil{
        return false
    }
    
    if let previewData = xml?.root["Response"]["Epf.data"]["PreviewData"].stringValue{
        data.Photo = GetImageFromBase64(previewData)
        return true
    }
    
    return false
}


