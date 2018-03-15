//
//  ViewController.swift
//  Day1 Clock(swift)
//
//  Created by 杨警 on 2018/3/5.
//  Copyright © 2018年 杨警. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mainTimerLabel: UILabel!
    var startBtn: UIButton!
    var resetBtn: UIButton!
    var timer: DispatchSourceTimer?
    var timerCount: Int64 = 0
    var tableView: UITableView!
    var dataArray: Array<Int64> = []
    var currentCount: Int64 = 0
    var maxCount: Int64 = 0
    var minCount: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configNavigationBar();
        self.configSubview();
    }
    
    //MARK: - timer
    @objc func timerStart() {
        startBtn.setTitle("停止", for: UIControlState.normal);
        startBtn.backgroundColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.3);
        startBtn.setTitleColor(UIColor.red, for: UIControlState.normal);
        startBtn.removeTarget(self, action: #selector(timerStart), for: UIControlEvents.touchUpInside);
        
        startBtn.addTarget(self, action: #selector(timerStop), for: UIControlEvents.touchUpInside);
        
        resetBtn.isEnabled = true;
        resetBtn.setTitle("计次", for: UIControlState.normal);
        resetBtn.backgroundColor = UIColor.init(white: 1, alpha: 0.6);
        resetBtn.setTitleColor(UIColor.white, for: UIControlState.normal);
        resetBtn.removeTarget(self, action: #selector(timerReset), for: UIControlEvents.touchUpInside);
        
        resetBtn.addTarget(self, action: #selector(timerRecord), for: UIControlEvents.touchUpInside);
        
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global());
        timer?.schedule(wallDeadline: DispatchWallTime.now(), repeating: 0.01);
        timer?.setEventHandler(handler: {
            self.timerCount += 1;
            self.currentCount += 1;
            
            DispatchQueue.main.async {
                self.mainTimerLabel.text = String.init(format: "%.2ld:%.2ld.%.2ld", self.timerCount/100/60, self.timerCount/100%60, self.timerCount%100);
            }
        });
        timer?.resume();
    }
    
    @objc func timerStop() {
        if (timer?.isCancelled) == false {
            timer?.cancel();
        }
        
        startBtn.setTitle("开始", for: UIControlState.normal);
        startBtn.backgroundColor = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.3);
        startBtn.setTitleColor(UIColor.green, for: UIControlState.normal);
        startBtn.removeTarget(self, action: #selector(timerStop), for: UIControlEvents.touchUpInside);
        
        startBtn.addTarget(self, action: #selector(timerStart), for: UIControlEvents.touchUpInside);
        
        if timerCount > 0 {
            resetBtn.setTitle("复位", for: UIControlState.normal);
            resetBtn.backgroundColor = UIColor.init(white: 1, alpha: 0.6);
            resetBtn.setTitleColor(UIColor.white, for: UIControlState.normal);
            resetBtn.removeTarget(self, action: #selector(timerRecord), for: UIControlEvents.touchUpInside);
            resetBtn.addTarget(self, action: #selector(timerReset), for: UIControlEvents.touchUpInside);
        }
    }
    
    @objc func timerReset() {
        timerCount = 0;
        mainTimerLabel.text = "00:00.00";
        currentCount = 0;
        maxCount = 0;
        minCount = 0;
        dataArray.removeAll();
        
        resetBtn.isEnabled = false;
        resetBtn.setTitle("计次", for: UIControlState.disabled);
        resetBtn.backgroundColor = UIColor.init(white: 1, alpha: 0.3);
        resetBtn.setTitleColor(UIColor.gray, for: UIControlState.disabled);
        resetBtn.removeTarget(self, action: #selector(timerReset), for: UIControlEvents.touchUpInside);
        resetBtn.addTarget(self, action: #selector(timerRecord), for: UIControlEvents.touchUpInside);
        
        tableView.reloadData();
    }
    
    @objc func timerRecord() {
        if currentCount > maxCount || maxCount == 0 {
            maxCount = currentCount;
        }
        
        if currentCount < minCount || minCount == 0 {
            minCount = currentCount;
        }
        
        dataArray.insert(currentCount, at: 0);
        currentCount = 0;
        
        tableView.reloadData();
    }
    
    //MARK: - tableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "CellId");
        if cell == nil {
            cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: "CellId");
            cell?.backgroundColor = UIColor.black;
        }
        
        let count = dataArray[indexPath.row];
        
        cell!.textLabel?.text = "计次 \(dataArray.count-indexPath.row)";
        cell!.detailTextLabel?.text = String.init(format: "%.2ld:%.2ld.%.2ld", count/100/60, count/100%60, count%100);
        
        if count >= maxCount {
            cell?.textLabel?.textColor = UIColor.green;
            cell?.detailTextLabel?.textColor = UIColor.green;
            
        } else if count <= minCount {
            cell?.textLabel?.textColor = UIColor.red;
            cell?.detailTextLabel?.textColor = UIColor.red;
            
        } else {
            cell?.textLabel?.textColor = UIColor.white;
            cell?.detailTextLabel?.textColor = UIColor.white;
        }
        return cell!;
    }
    
    //MARK: - tableView delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    //MARK: - view
    func configNavigationBar() {
        navigationItem.title = "秒表";
        
        navigationController?.navigationBar.barTintColor = UIColor.black;
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white];
    }
    
    func configSubview() {
        view.backgroundColor = UIColor.black;
        
        //mainTimerLabel
        mainTimerLabel = UILabel.init(frame: CGRect.init(x: 15, y: 100, width: UIScreen.main.bounds.size.width-30, height:UIFont.init(name:"Arial Hebrew", size:68)!.lineHeight));
        mainTimerLabel.font = UIFont.init(name:"Arial Hebrew", size:68);
        mainTimerLabel.textAlignment = NSTextAlignment.center;
        mainTimerLabel.textColor = UIColor.white;
        mainTimerLabel.text = "00:00.00";
        mainTimerLabel.adjustsFontSizeToFitWidth = true;
        view.addSubview(mainTimerLabel);
        
        //resetBtn
        resetBtn = UIButton.init(type: UIButtonType.custom);
        resetBtn.layer.cornerRadius = 40;
        resetBtn.clipsToBounds = true;
        resetBtn.backgroundColor = UIColor.init(white: 1, alpha: 0.3);
        resetBtn.setTitle("计次", for: UIControlState.normal);
        resetBtn.setTitleColor(UIColor.gray, for: UIControlState.normal);
        resetBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17);
        resetBtn.addTarget(self, action:#selector(timerRecord) , for: UIControlEvents.touchUpInside);
        view.addSubview(resetBtn);
        resetBtn.frame = CGRect.init(x: UIScreen.main.bounds.size.width/4-80/2, y: 250, width: 80, height: 80);
        resetBtn.isEnabled = false;
        
        //startBtn
        startBtn = UIButton.init(type: UIButtonType.custom);
        startBtn.layer.cornerRadius = 40;
        startBtn.clipsToBounds = true;
        startBtn.setTitle("开始", for: UIControlState.normal);
        startBtn.backgroundColor = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.3);
        startBtn.setTitleColor(UIColor.green, for: UIControlState.normal);
        startBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17);
        startBtn.addTarget(self, action: #selector(timerStart), for: UIControlEvents.touchUpInside);
        view.addSubview(startBtn);
        startBtn.frame = CGRect.init(x: UIScreen.main.bounds.size.width/4*3-80/2, y: 250, width: 80, height: 80);
        
        //tableView
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 250+80+30, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-(250+80+30)), style: UITableViewStyle.plain);
        tableView.separatorColor = UIColor.gray;
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = UIColor.black;
        view.addSubview(tableView);
    }
    
}

