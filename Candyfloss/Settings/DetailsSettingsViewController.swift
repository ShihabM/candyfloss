//
//  DetailsSettingsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 30/04/2025.
//

import Foundation
import UIKit
import CoreSpotlight
import IntentsUI
import MobileCoreServices

class DetailsSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    let firstSection = ["Show Next Reply Button", "Long-Press to..."]
    
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
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Post Details"
        
        tableView.allowsFocus = true
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell1")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = GlobalStruct.groupBG
        tableView.layer.masksToBounds = true
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        tableView.reloadData()
    }
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firstSection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
            cell = UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = firstSection[indexPath.row]
            let switchView = UISwitch(frame: .zero)
            if UserDefaults.standard.value(forKey: "showNextReplyButton") as? Bool != nil {
                if UserDefaults.standard.value(forKey: "showNextReplyButton") as? Bool == false {
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
            switchView.addTarget(self, action: #selector(switchShowNextReplyButton(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            cell.backgroundColor = GlobalStruct.backgroundTint
            cell.focusEffect = UIFocusHaloEffect()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell1", for: indexPath) as! SelectionCell
            
            cell.theTitle.text = firstSection[indexPath.row]
            if GlobalStruct.nextReplyButtonState == 0 {
                cell.theTitle2.text = "Scroll One Up"
            } else if GlobalStruct.nextReplyButtonState == 1 {
                cell.theTitle2.text = "Scroll to Top"
            } else {
                cell.theTitle2.text = "Jump to Bottom"
            }
            
            var gestureActions: [UIAction] = []
            let op1 = UIAction(title: "Scroll One Up", image: UIImage(systemName: "arrow.up"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.nextReplyButtonState = 0
                UserDefaults.standard.set(GlobalStruct.nextReplyButtonState, forKey: "nextReplyButtonState")
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            if GlobalStruct.nextReplyButtonState == 0 {
                op1.state = .on
            }
            gestureActions.append(op1)
            let op2 = UIAction(title: "Jump to Top", image: UIImage(systemName: "arrow.up.to.line"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.nextReplyButtonState = 1
                UserDefaults.standard.set(GlobalStruct.nextReplyButtonState, forKey: "nextReplyButtonState")
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            if GlobalStruct.nextReplyButtonState == 1 {
                op2.state = .on
            }
            gestureActions.append(op2)
            let op3 = UIAction(title: "Jump to Bottom", image: UIImage(systemName: "arrow.down.to.line"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.nextReplyButtonState = 2
                UserDefaults.standard.set(GlobalStruct.nextReplyButtonState, forKey: "nextReplyButtonState")
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            if GlobalStruct.nextReplyButtonState == 2 {
                op3.state = .on
            }
            gestureActions.append(op3)
            cell.bgButton.showsMenuAsPrimaryAction = true
            cell.bgButton.menu = UIMenu(title: "", options: [.displayInline], children: gestureActions)
            cell.accessoryView = .none
            cell.selectionStyle = .none
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            cell.hoverStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func switchShowNextReplyButton(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.showNextReplyButton = true
            UserDefaults.standard.set(true, forKey: "showNextReplyButton")
        } else {
            GlobalStruct.showNextReplyButton = false
            UserDefaults.standard.set(false, forKey: "showNextReplyButton")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "\nTap the Next Reply button to easily navigate through conversations that have more than three replies."
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
