//
//  ComposerSettingsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 30/04/2025.
//

import Foundation
import UIKit
import CoreSpotlight
import IntentsUI
import MobileCoreServices

class ComposerSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var section3Titles: [String] = ["Keyboard Style", "Post Button Position"]
    
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
        navigationItem.title = "Post Composer"
        
        tableView.allowsFocus = true
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell1")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell2")
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 1
        } else {
            return section3Titles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell1", for: indexPath) as! SelectionCell
            
            cell.theTitle.text = section3Titles[indexPath.row]
            if GlobalStruct.keyboardStyle == 0 {
                cell.theTitle2.text = "Default"
            } else {
                cell.theTitle2.text = "Social"
            }
            
            var gestureActions: [UIAction] = []
            let op1 = UIAction(title: "Default", image: UIImage(systemName: "keyboard"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.keyboardStyle = 0
                UserDefaults.standard.set(GlobalStruct.keyboardStyle, forKey: "keyboardStyle")
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            if GlobalStruct.keyboardStyle == 0 {
                op1.state = .on
            }
            gestureActions.append(op1)
            let op2 = UIAction(title: "Social", image: UIImage(systemName: "at"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.keyboardStyle = 1
                UserDefaults.standard.set(GlobalStruct.keyboardStyle, forKey: "keyboardStyle")
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            if GlobalStruct.keyboardStyle == 1 {
                op2.state = .on
            }
            gestureActions.append(op2)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell2", for: indexPath) as! SelectionCell
            
            cell.theTitle.text = section3Titles[indexPath.row]
            if GlobalStruct.startLocation == 0 {
                cell.theTitle2.text = "Navigation Bar"
            } else if GlobalStruct.startLocation == 1 {
                cell.theTitle2.text = "Bottom Left"
            } else if GlobalStruct.startLocation == 2 {
                cell.theTitle2.text = "Bottom Middle"
            } else {
                cell.theTitle2.text = "Bottom Right"
            }
            
            var gestureActions: [UIAction] = []
            let op1 = UIAction(title: "Navigation Bar", image: UIImage(systemName: "square.grid.3x3.topright.filled"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.startLocation = 0
                UserDefaults.standard.set(GlobalStruct.startLocation, forKey: "startLocation")
                tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateNewPostPosition"), object: nil)
            }
            if GlobalStruct.startLocation == 0 {
                op1.state = .on
            }
            gestureActions.append(op1)
            let op2 = UIAction(title: "Bottom Left", image: UIImage(systemName: "square.grid.3x3.bottomleft.filled"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.startLocation = 1
                UserDefaults.standard.set(GlobalStruct.startLocation, forKey: "startLocation")
                tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateNewPostPosition"), object: nil)
            }
            if GlobalStruct.startLocation == 1 {
                op2.state = .on
            }
            gestureActions.append(op2)
            let op3 = UIAction(title: "Bottom Middle", image: UIImage(systemName: "square.grid.3x3.bottommiddle.filled"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.startLocation = 2
                UserDefaults.standard.set(GlobalStruct.startLocation, forKey: "startLocation")
                tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateNewPostPosition"), object: nil)
            }
            if GlobalStruct.startLocation == 2 {
                op3.state = .on
            }
            gestureActions.append(op3)
            let op4 = UIAction(title: "Bottom Right", image: UIImage(systemName: "square.grid.3x3.bottomright.filled"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.startLocation = 3
                UserDefaults.standard.set(GlobalStruct.startLocation, forKey: "startLocation")
                tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateNewPostPosition"), object: nil)
            }
            if GlobalStruct.startLocation == 3 {
                op4.state = .on
            }
            gestureActions.append(op4)
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return nil
        } else {
            return "\nYou can also drag the post button to set its position."
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
