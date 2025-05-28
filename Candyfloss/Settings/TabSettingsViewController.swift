//
//  TabSettingsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 16/05/2025.
//

import Foundation
import UIKit
import CoreSpotlight
import IntentsUI
import MobileCoreServices

class TabSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var section3Titles: [String] = ["Tab 3 Shows...", "Tab 4 Shows...", "Tab 5 Shows..."]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
        
    @objc func dismissTap() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.modalBackground
        navigationItem.title = "Tabs"
        
        tableView.allowsFocus = true
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell1")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell2")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell3")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = GlobalStruct.modalBackground
        tableView.layer.masksToBounds = true
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        tableView.reloadData()
    }
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section3Titles.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell1", for: indexPath) as! SelectionCell
                
                cell.theTitle.text = section3Titles[indexPath.row]
                cell.theTitle2.text = GlobalStruct.currentSwitchableViewAtSpot3.title
                
                var gestureActions: [UIAction] = []
                for switchableView in GlobalStruct.switchableViews {
                    let op1 = UIAction(title: switchableView.title, image: UIImage(systemName: switchableView.icon), identifier: nil) { [weak self] action in
                        guard let self else { return }
                        GlobalStruct.currentSwitchableViewAtSpot3 = SwitchableViews(title: switchableView.title, icon: switchableView.icon, iconSelected: switchableView.iconSelected, view: switchableView.view)
                        GlobalStruct.switchableView = switchableView
                        GlobalStruct.switchableIndex = 2
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSwitchableView"), object: nil)
                        self.tableView.reloadData()
                    }
                    if GlobalStruct.currentSwitchableViewAtSpot3.title == switchableView.title {
                        op1.state = .on
                    }
                    gestureActions.append(op1)
                }
                cell.bgButton.showsMenuAsPrimaryAction = true
                cell.bgButton.menu = UIMenu(title: "", options: [.displayInline], children: gestureActions)
                cell.accessoryView = .none
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.spoilerBG
                cell.hoverStyle = .none
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell2", for: indexPath) as! SelectionCell
                
                cell.theTitle.text = section3Titles[indexPath.row]
                cell.theTitle2.text = GlobalStruct.currentSwitchableViewAtSpot4.title
                
                var gestureActions: [UIAction] = []
                for switchableView in GlobalStruct.switchableViews {
                    let op1 = UIAction(title: switchableView.title, image: UIImage(systemName: switchableView.icon), identifier: nil) { [weak self] action in
                        guard let self else { return }
                        GlobalStruct.currentSwitchableViewAtSpot4 = SwitchableViews(title: switchableView.title, icon: switchableView.icon, iconSelected: switchableView.iconSelected, view: switchableView.view)
                        GlobalStruct.switchableView = switchableView
                        GlobalStruct.switchableIndex = 3
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSwitchableView"), object: nil)
                        self.tableView.reloadData()
                    }
                    if GlobalStruct.currentSwitchableViewAtSpot4.title == switchableView.title {
                        op1.state = .on
                    }
                    gestureActions.append(op1)
                }
                cell.bgButton.showsMenuAsPrimaryAction = true
                cell.bgButton.menu = UIMenu(title: "", options: [.displayInline], children: gestureActions)
                cell.accessoryView = .none
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.spoilerBG
                cell.hoverStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell3", for: indexPath) as! SelectionCell
                
                cell.theTitle.text = section3Titles[indexPath.row]
                cell.theTitle2.text = GlobalStruct.currentSwitchableViewAtSpot5.title
                
                var gestureActions: [UIAction] = []
                for switchableView in GlobalStruct.switchableViews {
                    let op1 = UIAction(title: switchableView.title, image: UIImage(systemName: switchableView.icon), identifier: nil) { [weak self] action in
                        guard let self else { return }
                        GlobalStruct.currentSwitchableViewAtSpot5 = SwitchableViews(title: switchableView.title, icon: switchableView.icon, iconSelected: switchableView.iconSelected, view: switchableView.view)
                        GlobalStruct.switchableView = switchableView
                        GlobalStruct.switchableIndex = 4
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateSwitchableView"), object: nil)
                        self.tableView.reloadData()
                    }
                    if GlobalStruct.currentSwitchableViewAtSpot5.title == switchableView.title {
                        op1.state = .on
                    }
                    gestureActions.append(op1)
                }
                cell.bgButton.showsMenuAsPrimaryAction = true
                cell.bgButton.menu = UIMenu(title: "", options: [.displayInline], children: gestureActions)
                cell.accessoryView = .none
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.spoilerBG
                cell.hoverStyle = .none
                return cell
            }
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell = UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "Animate Tab Selection"
            let switchView = UISwitch(frame: .zero)
            if UserDefaults.standard.value(forKey: "animateTabSelection") as? Bool != nil {
                if UserDefaults.standard.value(forKey: "animateTabSelection") as? Bool == false {
                    switchView.setOn(false, animated: false)
                } else {
                    switchView.setOn(true, animated: false)
                }
            } else {
                switchView.setOn(true, animated: false)
            }
            switchView.onTintColor = GlobalStruct.baseTint
            switchView.tintColor = GlobalStruct.baseTint
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(switchAnimateTabSelection(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            cell.backgroundColor = GlobalStruct.spoilerBG
            cell.focusEffect = UIFocusHaloEffect()
            return cell
        }
    }
    
    @objc func switchAnimateTabSelection(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.animateTabSelection = true
            UserDefaults.standard.set(true, forKey: "animateTabSelection")
        } else {
            GlobalStruct.animateTabSelection = false
            UserDefaults.standard.set(false, forKey: "animateTabSelection")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "\nYou can also long-press the tabs themselves to switch views."
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
