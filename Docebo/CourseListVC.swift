//
//  CourseListVC.swift
//  UITextFieldDropDownList
//
//  Created by Ans Riaz on 04/11/2017.
//  Copyright © 2017 LawrenceM. All rights reserved.
//

import UIKit
import Kingfisher

class CourseListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var objects = [AnyObject]()
    var count: Int = 0
    var pickerData: [[String]] = [["A to Z", "Z to A"], ["Type", "Price"]]
    var pickerFilterData: [String] = ["Type", "Price"]
    var headerTitles = ["Sort by", "Filter by"]
    var sortingParameters: [String] = [String]()
    
    var httpServiceRequest = HttpServiceRequest()
    
    @IBOutlet weak var responseTable: UITableView!
    var itemName = ""
    var courseName = ""
    
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var pickerTable: UITableView!
    
    @IBOutlet weak var picker: UIPickerView!
    
    let cellReuseIdentifier = "CourseDetailCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(itemName)
        print(courseName)
        
        let url = "https://demomobile.docebosaas.com/learn/v1/catalog?type[]=\(courseName)&search_text=\(itemName)"
        
        httpServiceRequest.getData(url: url) { response in
            print("data received")
            let data = try? JSONSerialization.jsonObject(with: response, options: []) as! [String:AnyObject]
//            print(data)
            if(data!["data"] != nil) {
                if let itemsCount = data!["data"]!["count"] as? Int {
                    self.count = itemsCount
                    self.objects = data!["data"]!["items"] as! [AnyObject]
                    
                    DispatchQueue.main.async {
                        self.responseTable.reloadData()
                    }
                }
            }
            if(data!["status"] != nil && data!["status"] as! Int != 400) {
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filters", style: .plain, target: self, action: #selector(performFilters))
        
        // self.responseTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.responseTable.delegate = self
        self.responseTable.dataSource = self
        
        // picker
        pickerTable.dataSource = self
        pickerTable.delegate = self
        pickerTable.register(UITableViewCell.self, forCellReuseIdentifier: "pickerCell")
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        responseTable.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == responseTable {
            return 1
        }
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerData[section].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var c: Int?
        if tableView == responseTable {
            c = count
        }
        
        if tableView == pickerTable {
            c = pickerData.count
        }
        
        return c!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == responseTable {
            let cell = responseTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CourseCell
            
            let rowData = objects[indexPath.row] as! [String:Any]
            // "Detail test"
            cell.cellDetail?.text = (rowData["item_description"] as! String).html2String
            // "Title"
            cell.cellTitle?.text = rowData["item_name"] as? String
            // "Type | Price"
            let type = rowData["item_type"] as! String
            let price = rowData["item_price"] as! String
            cell.cellTypePrice?.text = "\(type) | \(price)"
            
            //https://d36spl5w3z9i0o.cloudfront.net/files/assets/courselogo/original/074ff9e102e8c71cbea541c55f48d71e.jpg
            if(String(describing: rowData["item_type"]) != "") {
                let url = URL(string: String(describing: rowData["item_thumbnail"]))
                cell.cellImage?.kf.setImage(with: url, placeholder:UIImage(named:"placeholder"))
            }
            
            return cell
        }
     
        var cell:UITableViewCell?
        
        if tableView == pickerTable {
            cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell") as UITableViewCell!
            
            let cellText = pickerData[indexPath.section][indexPath.row]
            
            cell!.textLabel?.text = cellText
            cell!.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var string = "\(count) items"
        if tableView == pickerTable {
            if section < headerTitles.count {
                string = headerTitles[section]
            }
        }
        return string
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if tableView == pickerTable {
            (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.white
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == pickerTable {
            return 30.0
        }
        return 72.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == pickerTable {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            let val = pickerData[indexPath.section][indexPath.row]
            if !sortingParameters.contains(val) {
                sortingParameters.append(val)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView == pickerTable {
            for vcip in tableView.indexPathsForVisibleRows ?? [] {
                if vcip.section == indexPath.section {
                    //&& vcip.item != indexPath.item
                    tableView.deselectRow(at: vcip, animated: false)
                    tableView.cellForRow(at: vcip)?.accessoryType = .none
                    let val = pickerData[vcip.section][vcip.row]
                    if let index = sortingParameters.index(where: {$0 == val}) {
                        sortingParameters.remove(at: index)
                    }
                }
            }
        }
        return indexPath
    }
    
    // Filters
    @objc func performFilters() {
        if(pickerView.isHidden) {
            pickerView.isHidden = false
        } else {
            pickerView.isHidden = true
        }
        sortData()
        DispatchQueue.main.async{
            self.responseTable.reloadData()
        }
    }
   
    @IBAction func clearFilters(_ sender: UIButton) {
        sortingParameters = []
        DispatchQueue.main.async{
            self.pickerTable.reloadData()
            self.responseTable.reloadData()
        }
        pickerView.isHidden = true
    }
    
    func sortData() {
        for sort in sortingParameters {
            objects = objects.sorted(by: { (dictOne, dictTwo) -> Bool in
                let d1 = dictOne["item_name"] as! String
                let d2 = dictTwo["item_name"] as! String
                if sort == "A to Z" {
                    return d1 < d2
                }
                return d1 > d2
            })
            if sort == "Type" {
                objects = objects.sorted(by: { (dictOne, dictTwo) -> Bool in
                    let d1 = dictOne["item_type"] as! String
                    let d2 = dictTwo["item_type"] as! String
                    return d1 < d2
                })
            }
            if sort == "Price" {
                objects = objects.sorted(by: { (dictOne, dictTwo) -> Bool in
                    let d1 = dictOne["item_price"] as! Float
                    let d2 = dictTwo["item_price"] as! Float
                    return d1 < d2
                })
            }
        }
        self.responseTable.reloadData()
    }
    
    // MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerFilterData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerFilterData[row]
    }
}


