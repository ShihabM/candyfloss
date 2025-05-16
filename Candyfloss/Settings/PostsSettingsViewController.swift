//
//  PostsSettingsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 30/04/2025.
//

import Foundation
import UIKit
import CoreSpotlight
import IntentsUI
import MobileCoreServices
import ATProtoKit

class PostsSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var section1Titles: [String] = ["Font Size", "Font Size"]
    var section1bTitles: [String] = ["Line Spacing", "Line Spacing"]
    var section2Titles: [String] = ["Date Format", "Maximum Lines", "Show Action Buttons", "Show Action Button Counts", "Show Quote Previews", "Show Link Previews", "Show Media", "Auto-play Videos"]
    var fontText: String = "System Size"
    var lineSpacingText: String = "System Size"
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    @objc func dismissTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GlobalStruct.modalBackground
        self.navigationItem.title = "Posts"
        
        if GlobalStruct.customTextSize == 0 {
            self.fontText = "\("System Size")"
        } else if GlobalStruct.customTextSize < 0 {
            self.fontText = "\("System Size") \(Int(GlobalStruct.customTextSize))"
        } else {
            self.fontText = "\("System Size") \("+\(Int(GlobalStruct.customTextSize))")"
        }
        
        if GlobalStruct.customLineSize == 0 {
            self.lineSpacingText = "\("System Size")"
        } else if GlobalStruct.customLineSize < 0 {
            self.lineSpacingText = "\("System Size") \(Int(GlobalStruct.customLineSize))"
        } else {
            self.lineSpacingText = "\("System Size") \("+\(Int(GlobalStruct.customLineSize))")"
        }
        
        self.tableView.allowsFocus = true
        self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell0")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell1")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell0")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell1")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCellRO")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell2")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell3")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell4")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell5")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCell2")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell6")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell7")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell8")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell9")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell10")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell11")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell12")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell13")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell14")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell15")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell16")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17p")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17q")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17r")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17s")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17t")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17u")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17v")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell17w")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell18")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell19")
        tableView.register(TextSizeCell.self, forCellReuseIdentifier: "TextSizeCell")
        tableView.register(TextSizeCell.self, forCellReuseIdentifier: "TextSizeCellb")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCellT")
        tableView.register(SelectionCell.self, forCellReuseIdentifier: "SelectionCellTb")
        tableView.register(PostsCell.self, forCellReuseIdentifier: "PostsCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = GlobalStruct.modalBackground
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.tableView)
        self.tableView.reloadData()
    }
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.section1Titles.count
        } else if section == 2 {
            return self.section1bTitles.count
        } else {
            return self.section2Titles.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            return 66
        } else if indexPath.section == 2 && indexPath.row == 1 {
            return 66
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
            
            cell.avatar.backgroundColor = GlobalStruct.baseTint
            cell.avatar.setImage(UIImage(), for: .normal)
            cell.username.text = GlobalStruct.currentUser?.displayName ?? ""
            if cell.username.text == "" {
                cell.username.text = " "
            }
            cell.usertag.text = "@\(GlobalStruct.currentUser?.actorHandle ?? "")"
            cell.text.text = "This is a preview of what the below settings options will look like for posts in various timelines across the app.\n\nHappy posting!"
            let timeSince = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = GlobalStruct.dateFormatter
            if GlobalStruct.dateFormat == 0 {
                cell.time.text = timeSince.toStringWithRelativeTime()
            } else {
                cell.time.text = timeSince.toString(dateStyle: .short, timeStyle: .short)
            }
            cell.configure(post: nil, showActionButtons: GlobalStruct.showActionButtons, isRepost: nil, isNestedQuote: false, isNestedReply: false, isPinned: false, fromPreview: true)
            cell.layoutIfNeeded()
            
            cell.isUserInteractionEnabled = false
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.detailQuoteCell
            cell.hoverStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCellT", for: indexPath) as! SelectionCell
                
                cell.theTitle.text = "Font Size"
                cell.theTitle2.text = self.fontText
                
                cell.accessoryView = .none
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextSizeCell", for: indexPath) as! TextSizeCell
                cell.textLabel?.numberOfLines = 0
                cell.configureSize(self.view.bounds.width)
                cell.slider.setValue(Float(GlobalStruct.customTextSize), animated: false)
                cell.slider.addTarget(self, action: #selector(self.valueChanged(_:)), for: .valueChanged)
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                
                cell.accessoryView = .none
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.focusEffect = UIFocusHaloEffect()
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCellTb", for: indexPath) as! SelectionCell
                
                cell.theTitle.text = "Line Spacing"
                cell.theTitle2.text = self.lineSpacingText
                
                cell.accessoryView = .none
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextSizeCellb", for: indexPath) as! TextSizeCell
                cell.textLabel?.numberOfLines = 0
                cell.configureSize(self.view.bounds.width)
                cell.slider.setValue(Float(GlobalStruct.customLineSize), animated: false)
                cell.slider.addTarget(self, action: #selector(self.valueChanged2(_:)), for: .valueChanged)
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                
                cell.accessoryView = .none
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.focusEffect = UIFocusHaloEffect()
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell0", for: indexPath) as! SelectionCell
                
                cell.theTitle.text = self.section2Titles[indexPath.row]
                if GlobalStruct.dateFormat == 0 {
                    cell.theTitle2.text = "Relative"
                } else {
                    cell.theTitle2.text = "Absolute"
                }
                
                var gestureActions: [UIAction] = []
                let op1 = UIAction(title: "Relative", image: UIImage(systemName: "clock.arrow.2.circlepath"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.dateFormat = 0
                    UserDefaults.standard.set(GlobalStruct.dateFormat, forKey: "dateFormat")
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
                }
                if GlobalStruct.dateFormat == 0 {
                    op1.state = .on
                }
                gestureActions.append(op1)
                let op2 = UIAction(title: "Absolute", image: UIImage(systemName: "clock"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.dateFormat = 1
                    UserDefaults.standard.set(GlobalStruct.dateFormat, forKey: "dateFormat")
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
                }
                if GlobalStruct.dateFormat == 1 {
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
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell1", for: indexPath) as! SelectionCell
                
                cell.theTitle.text = self.section2Titles[indexPath.row]
                if GlobalStruct.maxLines == 0 {
                    cell.theTitle2.text = "None"
                } else if GlobalStruct.maxLines == 2 {
                    cell.theTitle2.text = "2"
                } else if GlobalStruct.maxLines == 4 {
                    cell.theTitle2.text = "4"
                } else if GlobalStruct.maxLines == 6 {
                    cell.theTitle2.text = "6"
                } else if GlobalStruct.maxLines == 8 {
                    cell.theTitle2.text = "8"
                } else {
                    cell.theTitle2.text = "10"
                }
                
                var gestureActions: [UIAction] = []
                let op1 = UIAction(title: "None", image: UIImage(systemName: "rays"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.maxLines = 0
                    UserDefaults.standard.set(GlobalStruct.maxLines, forKey: "maxLines")
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
                }
                if GlobalStruct.maxLines == 0 {
                    op1.state = .on
                }
                gestureActions.append(op1)
                let op2 = UIAction(title: "2", image: UIImage(systemName: "2.circle"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.maxLines = 2
                    UserDefaults.standard.set(GlobalStruct.maxLines, forKey: "maxLines")
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
                }
                if GlobalStruct.maxLines == 2 {
                    op2.state = .on
                }
                gestureActions.append(op2)
                let op3 = UIAction(title: "4", image: UIImage(systemName: "4.circle"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.maxLines = 4
                    UserDefaults.standard.set(GlobalStruct.maxLines, forKey: "maxLines")
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
                }
                if GlobalStruct.maxLines == 4 {
                    op3.state = .on
                }
                gestureActions.append(op3)
                let op4 = UIAction(title: "6", image: UIImage(systemName: "6.circle"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.maxLines = 6
                    UserDefaults.standard.set(GlobalStruct.maxLines, forKey: "maxLines")
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
                }
                if GlobalStruct.maxLines == 6 {
                    op4.state = .on
                }
                gestureActions.append(op4)
                let op5 = UIAction(title: "8", image: UIImage(systemName: "8.circle"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.maxLines = 8
                    UserDefaults.standard.set(GlobalStruct.maxLines, forKey: "maxLines")
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
                }
                if GlobalStruct.maxLines == 8 {
                    op5.state = .on
                }
                gestureActions.append(op5)
                let op6 = UIAction(title: "10", image: UIImage(systemName: "10.circle"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.maxLines = 10
                    UserDefaults.standard.set(GlobalStruct.maxLines, forKey: "maxLines")
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
                }
                if GlobalStruct.maxLines == 10 {
                    op6.state = .on
                }
                gestureActions.append(op6)
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
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell3", for: indexPath) as! PlainCell
                
                cell.theTitle.text = self.section2Titles[indexPath.row]
                
                let switchView = UISwitch(frame: .zero)
                if GlobalStruct.showActionButtons {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
                switchView.onTintColor = GlobalStruct.baseTint
                switchView.tintColor = GlobalStruct.baseTint
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(self.switchActionButtons(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell17r", for: indexPath) as! PlainCell
                
                cell.theTitle.text = self.section2Titles[indexPath.row]
                
                let switchView = UISwitch(frame: .zero)
                if GlobalStruct.showActionButtonCounts {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
                switchView.onTintColor = GlobalStruct.baseTint
                switchView.tintColor = GlobalStruct.baseTint
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(self.switchActionButtonCounts(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell4", for: indexPath) as! PlainCell
                
                cell.theTitle.text = self.section2Titles[indexPath.row]
                
                let switchView = UISwitch(frame: .zero)
                if GlobalStruct.switchQuotePreviews {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
                switchView.onTintColor = GlobalStruct.baseTint
                switchView.tintColor = GlobalStruct.baseTint
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(self.switchQuotePreviews(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell5", for: indexPath) as! PlainCell
                
                cell.theTitle.text = self.section2Titles[indexPath.row]
                
                let switchView = UISwitch(frame: .zero)
                if GlobalStruct.switchLinkPreviews {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
                switchView.onTintColor = GlobalStruct.baseTint
                switchView.tintColor = GlobalStruct.baseTint
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(self.switchLinkPreviews(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else if indexPath.row == 6 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell6", for: indexPath) as! PlainCell
                
                cell.theTitle.text = self.section2Titles[indexPath.row]
                
                let switchView = UISwitch(frame: .zero)
                if GlobalStruct.switchMedia {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
                switchView.onTintColor = GlobalStruct.baseTint
                switchView.tintColor = GlobalStruct.baseTint
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(self.switchShowMedia(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell2", for: indexPath) as! PlainCell
                
                cell.theTitle.text = self.section2Titles[indexPath.row]
                
                let switchView = UISwitch(frame: .zero)
                if GlobalStruct.switchAutoplay {
                    switchView.setOn(true, animated: false)
                } else {
                    switchView.setOn(false, animated: false)
                }
                switchView.onTintColor = GlobalStruct.baseTint
                switchView.tintColor = GlobalStruct.baseTint
                switchView.tag = indexPath.row
                switchView.addTarget(self, action: #selector(self.switchAutoplay(_:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.selectionStyle = .none
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                cell.hoverStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func valueChanged(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SelectionCell {
            if sender.value == 0 {
                self.fontText = "\("System Size")"
                cell.theTitle2.text = "\("System Size")"
            } else if sender.value < 0 {
                self.fontText = "\("System Size") \(Int(sender.value))"
                cell.theTitle2.text = "\("System Size") \(Int(sender.value))"
            } else {
                self.fontText = "\("System Size") \("+\(Int(sender.value))")"
                cell.theTitle2.text = "\("System Size") \("+\(Int(sender.value))")"
            }
        }
        
        GlobalStruct.customTextSize = CGFloat(sender.value)
        UserDefaults.standard.set(GlobalStruct.customTextSize, forKey: "customTextSize")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
        
        self.tableView.reloadData()
    }
    
    @objc func valueChanged2(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? SelectionCell {
            if sender.value == 0 {
                self.lineSpacingText = "\("System Size")"
                cell.theTitle2.text = "\("System Size")"
            } else if sender.value < 0 {
                self.lineSpacingText = "\("System Size") \(Int(sender.value))"
                cell.theTitle2.text = "\("System Size") \(Int(sender.value))"
            } else {
                self.lineSpacingText = "\("System Size") \("+\(Int(sender.value))")"
                cell.theTitle2.text = "\("System Size") \("+\(Int(sender.value))")"
            }
        }
        
        GlobalStruct.customLineSize = CGFloat(sender.value)
        UserDefaults.standard.set(GlobalStruct.customLineSize, forKey: "customLineSize")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
        
        self.tableView.reloadData()
    }
    
    @objc func switchAutoplay(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.switchAutoplay = true
            UserDefaults.standard.setValue(GlobalStruct.switchAutoplay, forKey: "switchAutoplay")
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else {
            GlobalStruct.switchAutoplay = false
            UserDefaults.standard.setValue(GlobalStruct.switchAutoplay, forKey: "switchAutoplay")
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    @objc func switchActionButtons(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.showActionButtons = true
            UserDefaults.standard.setValue(GlobalStruct.showActionButtons, forKey: "showActionButtons")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else {
            GlobalStruct.showActionButtons = false
            UserDefaults.standard.setValue(GlobalStruct.showActionButtons, forKey: "showActionButtons")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    @objc func switchActionButtonCounts(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.showActionButtonCounts = true
            UserDefaults.standard.setValue(GlobalStruct.showActionButtonCounts, forKey: "showActionButtonCounts")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else {
            GlobalStruct.showActionButtonCounts = false
            UserDefaults.standard.setValue(GlobalStruct.showActionButtonCounts, forKey: "showActionButtonCounts")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    @objc func switchQuotePreviews(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.switchQuotePreviews = true
            UserDefaults.standard.setValue(GlobalStruct.switchQuotePreviews, forKey: "switchQuotePreviews")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else {
            GlobalStruct.switchQuotePreviews = false
            UserDefaults.standard.setValue(GlobalStruct.switchQuotePreviews, forKey: "switchQuotePreviews")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    @objc func switchLinkPreviews(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.switchLinkPreviews = true
            UserDefaults.standard.setValue(GlobalStruct.switchLinkPreviews, forKey: "switchLinkPreviews")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else {
            GlobalStruct.switchLinkPreviews = false
            UserDefaults.standard.setValue(GlobalStruct.switchLinkPreviews, forKey: "switchLinkPreviews")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    @objc func switchShowMedia(_ sender: UISwitch!) {
        if sender.isOn {
            GlobalStruct.switchMedia = true
            UserDefaults.standard.setValue(GlobalStruct.switchMedia, forKey: "switchMedia")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else {
            GlobalStruct.switchMedia = false
            UserDefaults.standard.setValue(GlobalStruct.switchMedia, forKey: "switchMedia")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateTint"), object: nil)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
}
