//
//  AlarmEditAddViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 12/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer


class AlarmEditAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var segueInfo: SegueInfo!
    var snoozeEnabled: Bool = false
    var enabled: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.gray
        datePicker.becomeFirstResponder()
        datePicker.tintColor = #colorLiteral(red: 0.9440181851, green: 0.6341474056, blue: 0.2346394956, alpha: 1)
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            datePicker.preferredDatePickerStyle = .compact // Replace .inline with .compact
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        alarmModel=Alarms()
        tableView.reloadData()
        snoozeEnabled = segueInfo.snoozeEnabled
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveEditAlarm(_ sender: AnyObject) {
        let date = Scheduler.correctSecondComponent(date: datePicker.date)
        let index = segueInfo.curCellIndex
        var tempAlarm = Alarm()
        tempAlarm.date = date
        tempAlarm.label = segueInfo.label
        tempAlarm.enabled = true
        tempAlarm.mediaLabel = segueInfo.mediaLabel
        tempAlarm.mediaID = segueInfo.mediaID
        tempAlarm.snoozeEnabled = snoozeEnabled
        tempAlarm.repeatWeekdays = segueInfo.repeatWeekdays
        tempAlarm.uuid = UUID().uuidString
        tempAlarm.onSnooze = false
        if segueInfo.isEditMode {
            alarmModel.alarms[index] = tempAlarm
        }
        else {
            alarmModel.alarms.append(tempAlarm)
        }
        self.performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
        NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)

    }
    
 
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        if segueInfo.isEditMode {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        else {
            return 1
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: Id.settingIdentifier)
       
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: Id.settingIdentifier)
        }
        cell!.backgroundColor = #colorLiteral(red: 0.1725008786, green: 0.1724130809, blue: 0.1806807518, alpha: 1)
        cell!.selectedBackgroundView?.backgroundColor = .gray
        let image = UIImage(systemName: "chevron.right")
        let accessory  = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width)!, height:(image?.size.height)!))
        accessory.image = image

        // set the color here
        accessory.tintColor = UIColor.gray
        cell!.accessoryView = accessory
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                cell?.tintColor = .white
                cell!.textLabel!.text = "Repeat"
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .gray
                cell!.detailTextLabel!.text = WeekdaysViewController.repeatText(weekdays: segueInfo.repeatWeekdays)
                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            else if indexPath.row == 1 {
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .gray
                cell!.textLabel!.text = "Title"
                cell!.detailTextLabel!.text = segueInfo.label
                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            else if indexPath.row == 2 {
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .gray
                cell!.textLabel!.text = "Sound"
                cell!.detailTextLabel!.text = segueInfo.mediaLabel
                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            else if indexPath.row == 3 {
                cell!.textLabel?.textColor = .white
                cell!.detailTextLabel?.textColor = .gray
                
                cell!.textLabel!.text = "Snooze"
                let sw = UISwitch(frame: CGRect())
                sw.addTarget(self, action: #selector(AlarmEditAddViewController.snoozeSwitchTapped(_:)), for: UIControl.Event.touchUpInside)
                
                if snoozeEnabled {
                   sw.setOn(true, animated: false)
                }
                
                cell!.accessoryView = sw
            }
        }
        else if indexPath.section == 1 {
            cell = UITableViewCell(
                style: UITableViewCell.CellStyle.default, reuseIdentifier: Id.settingIdentifier)
            cell!.selectedBackgroundView?.backgroundColor = .gray
            cell!.backgroundColor = #colorLiteral(red: 0.1725008786, green: 0.1724130809, blue: 0.1806807518, alpha: 1)
            cell!.textLabel!.text = "Delete Alarm"
            cell!.textLabel!.textAlignment = .center
            cell!.textLabel!.textColor = UIColor.red
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            switch indexPath.row{
            case 0:
                performSegue(withIdentifier: Id.weekdaysSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            case 1:
                performSegue(withIdentifier: Id.labelSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            case 2:
                performSegue(withIdentifier: Id.soundSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            default:
                break
            }
        }
        else if indexPath.section == 1 {
            //delete alarm
            alarmModel.alarms.remove(at: segueInfo.curCellIndex)
            performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
            NotificationCenter.default.post(name: .didReceiveData, object: self, userInfo: nil)
        }
            
    }
   
    @IBAction func snoozeSwitchTapped (_ sender: UISwitch) {
        snoozeEnabled = sender.isOn
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Id.saveSegueIdentifier {
            let dist = segue.destination as! HomeTableViewController
            let cells = dist.tableView.visibleCells
            for cell in cells {
                let sw = cell.accessoryView as! UISwitch
                if sw.tag > segueInfo.curCellIndex
                {
                    sw.tag -= 1
                }
            }
            alarmScheduler.reSchedule()
        }
        else if segue.identifier == Id.soundSegueIdentifier {
            //TODO
            let dist = segue.destination as! MediaViewController
            dist.mediaID = segueInfo.mediaID
            dist.mediaLabel = segueInfo.mediaLabel
        }
        else if segue.identifier == Id.labelSegueIdentifier {
            let dist = segue.destination as! TitleEditViewController
            dist.label = segueInfo.label
        }
        else if segue.identifier == Id.weekdaysSegueIdentifier {
            let dist = segue.destination as! WeekdaysViewController
            dist.weekdays = segueInfo.repeatWeekdays
        }
    }
    
    @IBAction func unwindFromLabelEditView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! TitleEditViewController
        segueInfo.label = src.label
    }
    
    @IBAction func unwindFromWeekdaysView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! WeekdaysViewController
        segueInfo.repeatWeekdays = src.weekdays
    }
    
    @IBAction func unwindFromMediaView(_ segue: UIStoryboardSegue) {
//        let src = segue.source as! MediaViewController
//        segueInfo.mediaLabel = src.mediaLabel
//        segueInfo.mediaID = src.mediaID
    }
    
    
}


extension UIView {
   var allSubviews: [UIView] {
      return subviews.flatMap { [$0] + $0.allSubviews }
   }
}
