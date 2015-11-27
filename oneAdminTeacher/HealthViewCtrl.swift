//
//  HealthViewCtrl.swift
//  EPF
//
//  Created by Cloud on 11/24/15.
//  Copyright © 2015 ischool. All rights reserved.
//

import UIKit

class HealthViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var StudentData : Student!
    
    let Green = UIColor(red: 2/255, green: 195/255, blue: 154/255, alpha: 1.0)
    let Pink = UIColor(red: 1, green: 72/255, blue: 94/255, alpha: 0.8)
    
    var Datas = [HealthItem]()
    
    var _dateTimeFormate = NSDateFormatter()
    var _dateFormate = NSDateFormatter()
    
    let _bodyImg = UIImage(named: "Body Scan-50.png")
    let _clinicImg = UIImage(named: "Clinic-50.png")
    let _visibleImg = UIImage(named: "Visible-50.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _dateTimeFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        _dateFormate.dateFormat = "yyyy/MM/dd"
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        tableView.estimatedRowHeight = 92
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        Datas = GetData()
        
        Datas.sortInPlace({ $0.Date > $1.Date })
        
        self.tableView.reloadData()
    }
    
    func GetData() -> [HealthItem]{
        
        var retVal = [HealthItem]()
        
        let con = GetCommonConnect(StudentData.DSNS, contract: Global.BasicContractName)
        
        var err : DSFault!
        
        let rsp = con.SendRequest("health.GetHistory", bodyContent: "<Request><StudentId>\(StudentData.ID)</StudentId></Request>", &err)
       
        if rsp.isEmpty{
            return retVal
        }
        
        var xml: AEXMLDocument?
        
        do{
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        }
        catch{
            return retVal
        }
        
        if let records = xml?.root["Response"]["Record"].all{
            
            for r in records{
                
                let date = r["Date"].stringValue
                let type = r["Type"].stringValue
                let dateTime = _dateTimeFormate.dateFromString(date)
                
                switch type{
                    
                    case "Injury":
                        
                        let injuryLocation = r["InjuryLocation"].stringValue
                        let injuryPart = r["InjuryPart"].stringValue
                        let injuryHandle = r["Handle"].stringValue
                        
                        let hi = HealthItem(InjuryLocation: injuryLocation, InjuryPart: injuryPart, InjuryHandle: injuryHandle, Date: dateTime!)
                        
                        retVal.append(hi)
                    
                    case "Sight":
                        
                        let leftEye = r["LeftEye"].stringValue
                        let rightEye = r["RightEye"].stringValue
                        
                        let hi = HealthItem(Vision: [leftEye,rightEye], Date: dateTime!)
                        
                        retVal.append(hi)
                    
                    default:
                        
                        let bmi = r["BMI"].stringValue
                        let height = r["Height"].stringValue
                        let weight = r["Weight"].stringValue
                        
                        let hi = HealthItem(BMI: bmi, Height: height, Weight: weight, Date: dateTime!)
                        
                        retVal.append(hi)
                    
                }
                
            }
            
        }
        
        retVal.sortInPlace({ $0.Date > $1.Date })
        
        return retVal
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Datas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = Datas[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HealthCell") as! HealthCell
        
        cell.Date.text = _dateFormate.stringFromDate(data.Date)
        
        if data.Type == "Grow"{
            
            cell.IconFrame.backgroundColor = Green
            cell.Icon.image = _bodyImg
            
            cell.Title.text = "身高 : \(data.Height) / 體重 : \(data.Weight)\nBMI : \(data.BMI)"
            
            return cell
        }
        else if data.Type == "Sight"{
            
            cell.IconFrame.backgroundColor = Green
            cell.Icon.image = _visibleImg
            
            if data.Vision.count == 2{
                cell.Title.text = "左眼視力 : \(data.Vision[0])\n右眼視力 : \(data.Vision[1])"
            }
            
        }
        else{
            
            cell.IconFrame.backgroundColor = Pink
            cell.Icon.image = _clinicImg
            cell.Title.text = "受傷部位 : \(data.InjuryPart)\n處置方法 : \(data.InjuryHandle)"
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        var gotoChart = false
        
        let data = Datas[indexPath.row]
        
        var tmpDatas = Datas.filter({ return $0.Type == data.Type})
        tmpDatas.sortInPlace({ $0.Date < $1.Date })
        
        var dataTitle : [String]!
        
        var dateArr = [String]()
        var datas1 = [Double]()
        var datas2 = [Double]()
        var datas3 = [Double]()
        
        switch data.Type{
            
            case "Grow" :
                
                gotoChart = true
            
                dataTitle = ["身高","體重","BMI"]
                
                for t in tmpDatas{
                    
                    let date = _dateFormate.stringFromDate(t.Date)
                    
                    if !dateArr.contains(date){
                        
                        dateArr.append(date)
                        
                        datas1.append(t.Height.doubleValue)
                        datas2.append(t.Weight.doubleValue)
                        datas3.append(t.BMI.doubleValue)
                    }
                    
                }
            
            case "Sight" :
                
                gotoChart = true
            
                dataTitle = ["左眼視力","右眼視力"]
                
                for t in tmpDatas{
                    
                    let date = _dateFormate.stringFromDate(t.Date)
                    
                    if !dateArr.contains(date){
                        
                        dateArr.append(date)
                        
                        datas1.append(t.Vision[0].doubleValue)
                        datas2.append(t.Vision[1].doubleValue)
                    }
                    
            }
            
            default :
            //...
            break
            
        }
        
        if gotoChart{
            
            let chart = self.storyboard?.instantiateViewControllerWithIdentifier("TempPageViewCtrl") as! TempPageViewCtrl
            
            chart.Xaxis = dateArr
            chart.Datas1 = datas1
            chart.Datas2 = datas2
            chart.Datas3 = datas3
            
            chart.DataTitles = dataTitle
            
            self.navigationController?.pushViewController(chart, animated: true)
        }
        
    }
}

struct HealthItem{
    
    var Type : String
    var BMI : String
    var Height : String
    var Weight : String
    var Vision : [String]
    var InjuryLocation : String
    var InjuryPart : String
    var InjuryHandle : String
    var Date : NSDate
    
    init(BMI:String,Height:String,Weight:String,Date:NSDate){
        
        self.Type = "Grow"
        self.BMI = BMI
        self.Height = Height
        self.Weight = Weight
        self.Vision = ["",""]
        self.InjuryLocation = ""
        self.InjuryPart = ""
        self.InjuryHandle = ""
        self.Date = Date
        
    }
    
    init(Vision:[String],Date:NSDate){
        
        self.Type = "Sight"
        self.BMI = ""
        self.Height = ""
        self.Weight = ""
        self.Vision = Vision
        self.InjuryLocation = ""
        self.InjuryPart = ""
        self.InjuryHandle = ""
        self.Date = Date
    }
    
    init(InjuryLocation:String,InjuryPart:String,InjuryHandle:String,Date:NSDate){
        
        self.Type = "Injury"
        self.BMI = ""
        self.Height = ""
        self.Weight = ""
        self.Vision = ["",""]
        self.InjuryLocation = InjuryLocation
        self.InjuryPart = InjuryPart
        self.InjuryHandle = InjuryHandle
        self.Date = Date
    }
}