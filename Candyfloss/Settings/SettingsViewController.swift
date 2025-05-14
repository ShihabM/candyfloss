//
//  SettingsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 29/04/2025.
//

import UIKit
import SDWebImage
import AVFoundation
import AVKit
import MessageUI
import SafariServices

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVPlayerViewControllerDelegate, MFMailComposeViewControllerDelegate, UISheetPresentationControllerDelegate {
    
    var tableView = UITableView()
    var section1Titles: [String] = ["App Icon", "App Tint", "Open Links", "Reader Mode", "Haptics"]
    var section2Titles: [String] = ["Timelines", "Posts", "Post Details", "Post Composer"]
    var section3Titles: [String] = ["Bluesky Service Status"]
    var section4Titles: [String] = ["Reset App Data"]
    var fromNavigationStack: Bool = true
    let button = CustomButton(type: .system)
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    @objc func updateTintMain() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if fromNavigationStack == false {
                tableView.reloadData()
                let button = CustomButton(type: .system)
                button.setTitle("Close", for: .normal)
                button.setTitleColor(GlobalStruct.baseTint, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
                let barButtonItem = UIBarButtonItem(customView: button)
                barButtonItem.accessibilityLabel = "Dismiss"
                navigationItem.leftBarButtonItem = barButtonItem
            }
        }
    }
    
    @objc func updateTint() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            tableView.backgroundColor = GlobalStruct.modalBackground
            let appearance = UINavigationBarAppearance()
            view.backgroundColor = GlobalStruct.modalBackground
            appearance.backgroundColor = GlobalStruct.backgroundTint
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            for x in tableView.visibleCells {
                if let y = x as? PlainCell {
                    y.backgroundColor = GlobalStruct.detailQuoteCell
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                if let y = x as? SelectionCell {
                    y.backgroundColor = GlobalStruct.detailQuoteCell
                    y.bgButton.backgroundColor = GlobalStruct.detailQuoteCell
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theTitle2.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                if let y = x as? TextSizeCell {
                    y.backgroundColor = GlobalStruct.detailQuoteCell
                }
            }
        }
    }
    
    @objc func overrideTheme() {
        if GlobalStruct.overrideTheme == 1 {
            navigationController?.overrideUserInterfaceStyle = .light
        } else if GlobalStruct.overrideTheme == 2 {
            navigationController?.overrideUserInterfaceStyle = .dark
        } else {
            navigationController?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.modalBackground
        navigationItem.title = "Settings"
        
        NotificationCenter.default.addObserver(self, selector: #selector(overrideTheme), name: NSNotification.Name(rawValue: "overrideTheme"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTintMain), name: NSNotification.Name(rawValue: "updateTintMain"), object: nil)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = GlobalStruct.backgroundTint
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        if fromNavigationStack == false {
            let button = CustomButton(type: .system)
            button.setTitle("Close", for: .normal)
            button.setTitleColor(GlobalStruct.baseTint, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            barButtonItem.accessibilityLabel = "Dismiss"
            navigationItem.leftBarButtonItem = barButtonItem
        }
        
        setUpTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func dismissView() {
        defaultHaptics()
        dismiss(animated: true)
    }
    
    //
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell1")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell2")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell3")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell4")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell5")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell6")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = GlobalStruct.modalBackground
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView()
        view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section1Titles.count
        } else if section == 1 {
            return section2Titles.count
        } else if section == 2 {
            return section3Titles.count
        } else {
            return section4Titles.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! PlainCell
                
                cell.theTitle.text = section1Titles[indexPath.row]
                
                cell.accessoryType = .disclosureIndicator
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell1", for: indexPath) as! PlainCell
                
                cell.theTitle.text = section1Titles[indexPath.row]
                
                cell.accessoryType = .disclosureIndicator
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
                
                cell.theTitle.text = section1Titles[indexPath.row]
                if GlobalStruct.openLinksInApp {
                    cell.theTitle2.text = "In-App"
                } else {
                    cell.theTitle2.text = "In the Browser"
                }
                
                var gestureActions: [UIAction] = []
                let op1 = UIAction(title: "In-App", image: UIImage(systemName: "arrow.down.left.topright.rectangle"), identifier: nil) { [weak self] action in
                guard let self else { return }
                    GlobalStruct.openLinksInApp = true
                    UserDefaults.standard.set(GlobalStruct.openLinksInApp, forKey: "openLinksInApp")
                    tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                }
                if GlobalStruct.openLinksInApp {
                    op1.state = .on
                }
                gestureActions.append(op1)
                let op2 = UIAction(title: "In the Browser", image: UIImage(systemName: "macwindow.on.rectangle"), identifier: nil) { [weak self] action in
                guard let self else { return }
                    GlobalStruct.openLinksInApp = false
                    UserDefaults.standard.set(GlobalStruct.openLinksInApp, forKey: "openLinksInApp")
                    tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                }
                if GlobalStruct.openLinksInApp == false {
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
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell2", for: indexPath) as! PlainCell
                
                cell.theTitle.text = section1Titles[indexPath.row]
                
                let switchView = UISwitch(frame: .zero)
                if GlobalStruct.readerMode {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
                switchView.onTintColor = GlobalStruct.baseTint
                switchView.tintColor = GlobalStruct.baseTint
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(switchReaderMode(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell3", for: indexPath) as! PlainCell
                
                cell.theTitle.text = section1Titles[indexPath.row]
                let switchView = UISwitch(frame: .zero)
                if GlobalStruct.switchHaptics {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
                switchView.onTintColor = GlobalStruct.baseTint
                switchView.tintColor = GlobalStruct.baseTint
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(switchHaptics(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell4", for: indexPath) as! PlainCell
            
            cell.theTitle.text = section2Titles[indexPath.row]
            
            cell.accessoryType = .disclosureIndicator
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.detailQuoteCell
            cell.hoverStyle = .none
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell5", for: indexPath) as! PlainCell
            
            cell.theTitle.text = section3Titles[indexPath.row]
            
            cell.accessoryView = .none
            cell.selectionStyle = .none
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.detailQuoteCell
            cell.hoverStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell6", for: indexPath) as! PlainCell
            
            cell.theTitle.textColor = .systemRed
            cell.theTitle.text = section4Titles[indexPath.row]
            
            cell.accessoryView = .none
            cell.selectionStyle = .none
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.detailQuoteCell
            cell.hoverStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            showAlert()
//            let vc = IconSettingsViewController()
//            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            let vc = TintSettingsViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            showAlert()
//            let vc = TimelineSettingsViewController()
//            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            let vc = PostsSettingsViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            let vc = DetailsSettingsViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 1 && indexPath.row == 3 {
            let vc = ComposerSettingsViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            if let link = URL(string: "https://status.bsky.app") {
                if GlobalStruct.openLinksInApp {
                    let safariVC = SFSafariViewController(url: link)
                    safariVC.modalPresentationStyle = .pageSheet
                    getTopMostViewController()?.present(safariVC, animated: true, completion: nil)
                } else {
                    UIApplication.shared.open(link, options: [:], completionHandler: nil)
                }
            }
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            showCacheAlert()
        }
    }
    
    func showCacheAlert() {
        let alert = UIAlertController(title: "Are you sure?", message: "This will remove all cached data from the app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (UIAlertAction) in
            if GlobalStruct.switchHaptics {
                let haptics = UINotificationFeedbackGenerator()
                haptics.notificationOccurred(.success)
            }
            do {
                try Disk.clear(.documents)
            } catch {
                print("error removing cached data - \(error)")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = getTopMostViewController()?.view
            presenter.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
        }
        getTopMostViewController()?.present(alert, animated: true, completion: nil)
    }
    
    @objc func switchReaderMode(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.readerMode = true
            UserDefaults.standard.setValue(GlobalStruct.readerMode, forKey: "readerMode")
            GlobalStruct.showActionButtons = false
            UserDefaults.standard.setValue(GlobalStruct.showActionButtons, forKey: "showActionButtons")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideNewPostButton"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateNavBarPositions"), object: nil)
        } else {
            GlobalStruct.readerMode = false
            UserDefaults.standard.setValue(GlobalStruct.readerMode, forKey: "readerMode")
            GlobalStruct.showActionButtons = true
            UserDefaults.standard.setValue(GlobalStruct.showActionButtons, forKey: "showActionButtons")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showNewPostButton"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateNavBarPositions"), object: nil)
        }
    }
    
    @objc func switchHaptics(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.switchHaptics = true
            UserDefaults.standard.setValue(GlobalStruct.switchHaptics, forKey: "switchHaptics")
        } else {
            GlobalStruct.switchHaptics = false
            UserDefaults.standard.setValue(GlobalStruct.switchHaptics, forKey: "switchHaptics")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "General"
        } else if section == 1 {
            return "Sections"
        } else if section == 2 {
            return "Extras"
        } else {
            return "Danger Zone"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "\nCheck up on how Bluesky services (including the API) are performing."
        } else if section == 3 {
            return "\nPlease note that resetting app data is an irreversible action and will remove all cached data from the app. This may also help in freeing up device memory."
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Coming Soon", message: "This settings section hasn't been implemented yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = getTopMostViewController()?.view
            presenter.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
        }
        getTopMostViewController()?.present(alert, animated: true, completion: nil)
    }
    
}



