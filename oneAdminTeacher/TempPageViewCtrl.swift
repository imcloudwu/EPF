//
//  TempPageViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/22/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import Charts

class TempPageViewCtrl: UIViewController,ChartViewDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var StudentData : Student!
    
    //var BC : BarChartView!
    var LineChart1 : LineChartView!
    var LineChart2 : LineChartView!
    var LineChart3 : LineChartView!
    
    var Xaxis : [String]!
    
    var DataTitles : [String]!
    
    var Datas1 : [Double]!
    var Datas2 : [Double]!
    var Datas3 : [Double]!
    
    //var _currentIndex : CGFloat!
    
    var Format : NSNumberFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        Format = NSNumberFormatter()
        Format.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        //let height = Global.ScreenSize.width * 0.75
        
        let xPostiton = CGFloat(0)
        var yPostiton = CGFloat(10)
        
        //BC = BarChartView(frame: CGRect(x: 0, y: yPostiton, width: Global.ScreenSize.width, height: Global.ScreenSize.width))
        //yPostiton += Global.ScreenSize.width
        
        if DataTitles.count > 0{
            
            LineChart1 = LineChartView(frame: CGRect(x: xPostiton, y: yPostiton, width: Global.ScreenSize.width, height: Global.ScreenSize.width))
            //yPostiton += Global.ScreenSize.width
            //xPostiton += Global.ScreenSize.width
            
            scrollView.addSubview(LineChart1)
            
            SetChartDefault(LineChart1)
            
            yPostiton += Global.ScreenSize.width + 10
        }
        
        if DataTitles.count > 1{
            
            LineChart2 = LineChartView(frame: CGRect(x: xPostiton, y: yPostiton, width: Global.ScreenSize.width, height: Global.ScreenSize.width))
            //yPostiton += Global.ScreenSize.width
            //xPostiton += Global.ScreenSize.width
            
            scrollView.addSubview(LineChart2)
            
            SetChartDefault(LineChart2)
            
            yPostiton += Global.ScreenSize.width + 10
        }
        
        if DataTitles.count > 2{
            
            LineChart3 = LineChartView(frame: CGRect(x: xPostiton, y: yPostiton, width: Global.ScreenSize.width, height: Global.ScreenSize.width))
            //yPostiton += Global.ScreenSize.width
            //xPostiton += Global.ScreenSize.width
            
            scrollView.addSubview(LineChart3)
            
            SetChartDefault(LineChart3)
            
            yPostiton += Global.ScreenSize.width + 10
        }
        
//        if StudentData.Name == "黃小翔"{
//            
//            let a = UIImageView(image: UIImage(named: "ScreenHunter.jpg"))
//            a.frame.size = CGSizeMake(Global.ScreenSize.width, height)
//            a.frame.origin.x = 0
//            a.frame.origin.y = yPostiton
//            a.contentMode = UIViewContentMode.ScaleToFill
//            yPostiton += a.frame.size.height + 10
//            
//            let b = UIImageView(image: UIImage(named: "黃小翔健康資料.jpg"))
//            b.frame.size = CGSizeMake(Global.ScreenSize.width, height)
//            b.frame.origin.x = 0
//            b.frame.origin.y = yPostiton
//            b.contentMode = UIViewContentMode.ScaleToFill
//            yPostiton += b.frame.size.height + 10
//            
//            let c = UIImageView(image: UIImage(named: "黃小翔身高曲線圖.jpg"))
//            c.frame.size = CGSizeMake(Global.ScreenSize.width, Global.ScreenSize.width)
//            c.frame.origin.x = 0
//            c.frame.origin.y = yPostiton
//            c.contentMode = UIViewContentMode.ScaleToFill
//            yPostiton += c.frame.size.height + 10
//            
//            let d = UIImageView(image: UIImage(named: "黃小翔體重曲線圖.jpg"))
//            d.frame.size = CGSizeMake(Global.ScreenSize.width, Global.ScreenSize.width)
//            d.frame.origin.x = 0
//            d.frame.origin.y = yPostiton
//            d.contentMode = UIViewContentMode.ScaleToFill
//            yPostiton += d.frame.size.height + 10
//            
//            scrollView.contentSize = CGSizeMake(Global.ScreenSize.width, yPostiton)
//            
//            scrollView.addSubview(a)
//            scrollView.addSubview(b)
//            scrollView.addSubview(c)
//            scrollView.addSubview(d)
//        }
//        else{
//            
//            let a = UIImageView(image: UIImage(named: "ScreenHunter.jpg"))
//            a.frame.size = CGSizeMake(Global.ScreenSize.width, height)
//            a.frame.origin.x = 0
//            a.frame.origin.y = yPostiton
//            a.contentMode = UIViewContentMode.ScaleToFill
//            yPostiton += a.frame.size.height + 10
//            
//            let b = UIImageView(image: UIImage(named: "黃小悅健康資料.jpg"))
//            b.frame.size = CGSizeMake(Global.ScreenSize.width, height)
//            b.frame.origin.x = 0
//            b.frame.origin.y = yPostiton
//            b.contentMode = UIViewContentMode.ScaleToFill
//            yPostiton += b.frame.size.height + 10
//            
//            let c = UIImageView(image: UIImage(named: "黃小悅身高曲線圖.jpg"))
//            c.frame.size = CGSizeMake(Global.ScreenSize.width, Global.ScreenSize.width)
//            c.frame.origin.x = 0
//            c.frame.origin.y = yPostiton
//            c.contentMode = UIViewContentMode.ScaleToFill
//            yPostiton += c.frame.size.height + 10
//            
//            let d = UIImageView(image: UIImage(named: "黃小悅體重曲線圖.jpg"))
//            d.frame.size = CGSizeMake(Global.ScreenSize.width, Global.ScreenSize.width)
//            d.frame.origin.x = 0
//            d.frame.origin.y = yPostiton
//            d.contentMode = UIViewContentMode.ScaleToFill
//            yPostiton += d.frame.size.height + 10
//            
//            scrollView.contentSize = CGSizeMake(Global.ScreenSize.width, yPostiton)
//            
//            scrollView.addSubview(a)
//            scrollView.addSubview(b)
//            scrollView.addSubview(c)
//            scrollView.addSubview(d)
//
//        }
        
        scrollView.contentSize = CGSizeMake(xPostiton, yPostiton)
        //scrollView.pagingEnabled = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if DataTitles.count > 0{
           SetLineChart1(Xaxis, values1: Datas1)
        }
        
        if DataTitles.count > 1{
            SetLineChart2(Xaxis, values1: Datas2)
        }
        
        if DataTitles.count > 2{
            SetLineChart3(Xaxis, values1: Datas3)
        }
    }
    
//    func setChart(dataPoints: [String], values: [Double]) {
//        
//        var dataEntries: [BarChartDataEntry] = []
//        
//        for i in 0..<dataPoints.count {
//            if i < values.count{
//                let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
//                dataEntries.append(dataEntry)
//            }
//        }
//        
//        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "公分")
//        chartDataSet.valueFormatter = Format
//        
//        let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
//        
//        BC.data = chartData
//        
//        BC.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
//        
//        BC.descriptionText = "2015"
//        
//        //BC.descriptionTextColor = UIColor.blueColor()
//        
//        BC.descriptionFont = UIFont.systemFontOfSize(16.0)
//    }
    
    func SetLineChart1(dataPoints: [String], values1: [Double]){
        
        var dataEntries1: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            if i < values1.count{
                let dataEntry = ChartDataEntry(value: values1[i], xIndex: i)
                dataEntries1.append(dataEntry)
            }
        }
        
        let label = DataTitles.count > 0 ? DataTitles[0] : ""
        
        let chartDataSet1 = LineChartDataSet(yVals: dataEntries1, label: label)
        chartDataSet1.colors = [UIColor.orangeColor()]
        
        chartDataSet1.valueFormatter = Format
        
        let chartData = LineChartData(xVals: dataPoints, dataSet: chartDataSet1)
        LineChart1.data = chartData
        
        LineChart1.animate(xAxisDuration: 2.0)
    }
    
    func SetLineChart2(dataPoints: [String], values1: [Double]){
        
        var dataEntries1: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            if i < values1.count{
                let dataEntry = ChartDataEntry(value: values1[i], xIndex: i)
                dataEntries1.append(dataEntry)
            }
        }
        
        let label = DataTitles.count > 1 ? DataTitles[1] : ""
        
        let chartDataSet1 = LineChartDataSet(yVals: dataEntries1, label: label)
        chartDataSet1.colors = [UIColor.orangeColor()]
        
        chartDataSet1.valueFormatter = Format
        
        let chartData = LineChartData(xVals: dataPoints, dataSet: chartDataSet1)
        LineChart2.data = chartData
        
        
        LineChart2.animate(xAxisDuration: 2.0)
    }
    
    func SetLineChart3(dataPoints: [String], values1: [Double]){
        
        var dataEntries1: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            if i < values1.count{
                let dataEntry = ChartDataEntry(value: values1[i], xIndex: i)
                dataEntries1.append(dataEntry)
            }
        }
        
        let label = DataTitles.count > 2 ? DataTitles[2] : ""
        
        let chartDataSet1 = LineChartDataSet(yVals: dataEntries1, label: label)
        chartDataSet1.colors = [UIColor.orangeColor()]
        
        chartDataSet1.valueFormatter = Format
        
        let chartData = LineChartData(xVals: dataPoints, dataSet: chartDataSet1)
        LineChart3.data = chartData
        
        LineChart3.animate(xAxisDuration: 2.0)
    }
    
    func SetChartDefault(lcv:LineChartView){
        
        let left = lcv.getAxis(ChartYAxis.AxisDependency.Left)
        left.startAtZeroEnabled = false
        let right = lcv.getAxis(ChartYAxis.AxisDependency.Right)
        right.startAtZeroEnabled = false
        
        left.valueFormatter = Format
        right.valueFormatter = Format
        
        lcv.descriptionText = "2015"
        lcv.descriptionTextColor = UIColor.darkGrayColor()
        lcv.descriptionFont = UIFont.systemFontOfSize(16.0)
        
        lcv.rightAxis.drawAxisLineEnabled = false
        lcv.rightAxis.drawLabelsEnabled = false
        lcv.xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
    }

    
//    func scrollViewDidScroll(scrollView: UIScrollView){
//        
//        let index = scrollView.contentOffset.x / Global.ScreenSize.width
//        let mod = scrollView.contentOffset.x % Global.ScreenSize.width
//        
//        if mod == 0{
//            
//            if _currentIndex != index{
//                
//                _currentIndex = index
//                
//                switch index{
//                case 0:
//                    SetHeightLineChart(_months, values1: _heightDatas)
//                    break
//                case 1:
//                    SetWeightLineChart(_months, values1: _weightDatas)
//                    break
//                default:
//                    SetBMILineChart(_months, heights: _heightDatas, weights: _weightDatas)
//                    break
//                }
//            }
//        }
//        
//    }

    
}