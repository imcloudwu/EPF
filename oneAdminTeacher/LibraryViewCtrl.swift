//
//  LibraryViewCtrl.swift
//  EPF
//
//  Created by Cloud on 11/25/15.
//  Copyright © 2015 ischool. All rights reserved.
//

import UIKit

class LibraryViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var StudentData : Student!
    
    var Datas = [BorrowItem]()
    
    var _dateFormat = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _dateFormat.dateFormat = "yyyy/MM/dd"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Datas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = Datas[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BorrowCell") as! BorrowCell
        
        let type = data.Category.isEmpty ? "" : " \(data.Category) \u{200c}"
        
        cell.Date.text = _dateFormat.stringFromDate(data.BorrowDate)
        cell.Type.text = type
        cell.Name.text = data.BookName
        
        //cell.Type.translatesAutoresizingMaskIntoConstraints = true
        
        //cell.Type.hidden = data.Category.isEmpty
        
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        Datas = GetData()
        self.tableView.reloadData()
    }
    
    func GetData() -> [BorrowItem]{
        
        var retVal = [BorrowItem]()
        
        let con = GetCommonConnect(StudentData.DSNS, contract: Global.BasicContractName)
        
        var err : DSFault!
        
        let rsp = con.SendRequest("library.GetBorrowInfo", bodyContent: "<Request><StudentId>\(StudentData.ID)</StudentId></Request>", &err)
        
        var xml: AEXMLDocument?
        
        do{
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        }
        catch{
            return retVal
        }
        
        let dtFormat1 = NSDateFormatter()
        dtFormat1.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS Z"
        
        if let borrows = xml?.root["Response"]["Borrow"].all{
            
            for b in borrows{
                
                let bookName = b["BookName"].stringValue
                let category = b["Category"].stringValue
                let borrowDate = b["BorrowDate"].stringValue
                
                if let nd1 = dtFormat1.dateFromString(borrowDate){
                    
                    let bi = BorrowItem(Category: category, BookName: bookName, BorrowDate: nd1)
                    
                    retVal.append(bi)
                }
                
            }
        }
        
        retVal.sortInPlace({ $0.BorrowDate > $1.BorrowDate})
        
        return retVal
        
    }
}

struct BorrowItem{
    var Category : String
    var BookName : String
    var BorrowDate : NSDate
}
