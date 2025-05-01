//
//  TintSettingsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 29/04/2025.
//

import Foundation
import UIKit

class TintSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIColorPickerViewControllerDelegate, UISheetPresentationControllerDelegate {
    
    var tableView = UITableView()
    var section0: [String] = ["Blue", "Indigo", "Purple", "Green", "Yellow", "Orange", "Cerise", "Red", "Pink", "Negative"]
    var section0Cols: [UIColor] = [UIColor(named: "baseTint")!, UIColor.systemIndigo, UIColor.systemPurple, UIColor.systemGreen, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemPink, UIColor.systemRed, UIColor(red: 255/255, green: 146/255, blue: 241/255, alpha: 1), UIColor.label]
    var currentSelection: Int = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let op1 = UIKeyCommand(title: "Close", image: UIImage(systemName: "xmark", withConfiguration: symbolConfig)?.withTintColor(UIColor.label, renderingMode: .alwaysOriginal), action: #selector(dismissTap), input: "w", modifierFlags: [.command], propertyList: nil, alternates: [], discoverabilityTitle: "Close", attributes: [], state: .on)
        return [op1]
    }
    
    @objc func updateTint() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            tableView.backgroundColor = GlobalStruct.groupBG
            let appearance = UINavigationBarAppearance()
            view.backgroundColor = GlobalStruct.backgroundTint
            appearance.backgroundColor = view.backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            for x in tableView.visibleCells {
                if let y = x as? PlainCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                x.backgroundColor = GlobalStruct.backgroundTint
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "App Tint"
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        currentSelection = UserDefaults.standard.value(forKey: "currentColSelection") as? Int ?? 0
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell1")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell")
        tableView.alpha = 1
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = GlobalStruct.groupBG
        tableView.layer.masksToBounds = true
        tableView.estimatedRowHeight = 89
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
    }
    
    @objc func dismissTap() {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section0.count
        } else if section == 1 {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.textLabel?.text = "\(section0[indexPath.row])"
            cell.imageView?.image = UIImage(systemName: "circle.fill")
            cell.imageView?.tintColor = section0Cols[indexPath.row]
            if indexPath.row == currentSelection {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.accessoryView = nil
            cell.textLabel?.textColor = UIColor.label
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell1", for: indexPath)
            cell.textLabel?.text = "Custom Tint"
            cell.imageView?.image = UIImage(systemName: "circle.fill")
            if currentSelection == 100 {
                cell.imageView?.tintColor = GlobalStruct.baseTint
            } else {
                cell.imageView?.tintColor = UIColor.label
            }
            if currentSelection == 100 {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.accessoryView = nil
            cell.textLabel?.textColor = UIColor.label
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! PlainCell
            
            cell.theTitle.text = "True-Black Dark Mode"
            
            let switchView = UISwitch(frame: .zero)
            if GlobalStruct.fullBlackBG {
                switchView.setOn(true, animated: false)
            } else {
                switchView.setOn(false, animated: false)
            }
            switchView.onTintColor = GlobalStruct.baseTint
            switchView.tintColor = GlobalStruct.baseTint
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(switchFullBlack(_:)), for: .valueChanged)
            cell.accessoryView = switchView
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
        if indexPath.section == 0 || indexPath.section == 1 {
            defaultHaptics()
        }
        if indexPath.section == 0 {
            GlobalStruct.baseTint = section0Cols[indexPath.row]
            UserDefaults.standard.setColor(color: GlobalStruct.baseTint, forKey: "baseTint")
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.tintColor = section0Cols[indexPath.row]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTintMain"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "sendToWatch"), object: nil)
            
            currentSelection = indexPath.row
            UserDefaults.standard.set(currentSelection, forKey: "currentColSelection")
            tableView.reloadData()
        }
        if indexPath.section == 1 {
            let picker = UIColorPickerViewController()
            picker.supportsAlpha = false
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        GlobalStruct.baseTint = viewController.selectedColor
        UserDefaults.standard.setColor(color: GlobalStruct.baseTint, forKey: "baseTint")
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.tintColor = viewController.selectedColor
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTintMain"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "sendToWatch"), object: nil)
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) {
            cell.imageView?.tintColor = viewController.selectedColor
            cell.accessoryType = .checkmark
        }
        currentSelection = 100
        UserDefaults.standard.set(100, forKey: "currentColSelection")
        tableView.reloadData()
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        
    }
    
    @objc func switchFullBlack(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.fullBlackBG = true
            UserDefaults.standard.setValue(GlobalStruct.fullBlackBG, forKey: "fullBlackBG")
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTintFullBlack"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
        } else {
            GlobalStruct.fullBlackBG = false
            UserDefaults.standard.setValue(GlobalStruct.fullBlackBG, forKey: "fullBlackBG")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTintFullBlack"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
        }
    }
    
}

