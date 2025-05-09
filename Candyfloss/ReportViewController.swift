//
//  ReportViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 21/03/2025.
//

import UIKit
import SDWebImage
import ATProtoKit

class ReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var reportReasons: [String] = ["Appeal", "Misleading", "Rude", "Sexual", "Spam", "Violation", "Other"]
    var selectedIndex: Int = 4
    
    var reportCategory: ComAtprotoLexicon.Moderation.ReasonTypeDefinition = .spam
    var reportComment: String? = nil
    var blockUser: Bool = false
    
    var currentPost: AppBskyLexicon.Feed.PostViewDefinition? = nil
    var currentUser: AppBskyLexicon.Actor.ProfileViewDefinition? = nil
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.modalBackground
        navigationItem.title = "Report User"
        if let _ = currentPost {
            navigationItem.title = "Report Post"
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = GlobalStruct.backgroundTint
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = UIColor.separator
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        if 0 == 0 {
            let button = CustomButton(type: .system)
            button.setTitle("Close", for: .normal)
            button.setTitleColor(GlobalStruct.baseTint, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            barButtonItem.accessibilityLabel = "Dismiss"
            navigationItem.leftBarButtonItem = barButtonItem
        }
        if 0 == 0 {
            let button = CustomButton(type: .system)
            button.setTitle("Report", for: .normal)
            button.setTitleColor(GlobalStruct.baseTint, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(self.report), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            barButtonItem.accessibilityLabel = "Report"
            navigationItem.rightBarButtonItem = barButtonItem
        }
        
        setUpTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func dismissView() {
        defaultHaptics()
        self.dismiss(animated: true)
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(PostsCell.self, forCellReuseIdentifier: "PostsCell")
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell1")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell2")
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.reportReasons.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let post = currentPost {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
                configurePostCell(cell, with: post, showActionButtons: false)
                cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                if let user = currentUser {
                    if let url = user.avatarImageURL {
                        cell.avatar.sd_imageTransition = .fade
                        cell.avatar.sd_setImage(with: url, for: .normal)
                        cell.avatar.tag = indexPath.row
                    }
                    cell.username.text = user.displayName ?? ""
                    cell.usertag.text = "@\(user.actorHandle)"
                    let bioText = user.description ?? ""
                    var followsYou: Bool = false
                    if let _ = user.viewer?.followedByURI {
                        followsYou = true
                    }
                    cell.configureCell(followsYou, bioText: bioText, defaultProfile: user)
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.detailQuoteCell
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell1", for: indexPath) as! PlainCell
            
            cell.theTitle.text = self.reportReasons[indexPath.row]
            
            if self.selectedIndex == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.detailQuoteCell
            cell.hoverStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell2", for: indexPath) as! PlainCell
            
            cell.theTitle.text = "Block User"
            
            let switchView = UISwitch(frame: .zero)
            if self.blockUser {
                switchView.setOn(true, animated: false)
            } else {
                switchView.setOn(false, animated: false)
            }
            switchView.onTintColor = GlobalStruct.baseTint
            switchView.tintColor = GlobalStruct.baseTint
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchBlock(_:)), for: .valueChanged)
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
    
    @objc func switchBlock(_ sender: UISwitch!) {
        if sender.isOn {
            self.blockUser = true
        } else {
            self.blockUser = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.reportCategory = .appeal
            } else if indexPath.row == 1 {
                self.reportCategory = .misleading
            } else if indexPath.row == 2 {
                self.reportCategory = .rude
            } else if indexPath.row == 3 {
                self.reportCategory = .sexual
            } else if indexPath.row == 4 {
                self.reportCategory = .spam
            } else if indexPath.row == 5 {
                self.reportCategory = .violation
            } else {
                self.reportCategory = .other
            }
            self.selectedIndex = indexPath.row
            self.tableView.reloadData()
        } else {
            
        }
    }
    
    @objc func report() {
        defaultHaptics()
        if self.blockUser {
            Task {
                
            }
        }
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let atProtoAdmin = ATProtoAdmin(sessionConfiguration: atProto.sessionConfiguration)
                    if let _ = currentPost {
                        let recordUri = currentPost?.uri ?? ""
                        let recordCID = currentPost?.cid ?? ""
                        let subject = ATUnion.CreateReportSubjectUnion.strongReference(ComAtprotoLexicon.Repository.StrongReference(recordURI: recordUri, cidHash: recordCID))
                        let x = try await atProtoAdmin.createReport(with: reportCategory, subject: subject)
                        print("Reported: \(x.id)")
                    } else {
//                        let recordUri = currentPost?.post.uri ?? ""
//                        let recordCID = currentPost?.post.cid ?? ""
//                        let subject = ComAtprotoLexicon.Repository.StrongReference(recordURI: recordUri, cidHash: recordCID)
//                        let x = try await atProtoAdmin.createReport(with: reportCategory, subject: subject)
//                        print("Reported: \(x.id)")
                    }
                    DispatchQueue.main.async {
                        self.dismissView()
                    }
                }
            } catch {
                print("Error reporting: \(error.localizedDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return nil
        } else {
            return "\nOptionally also block this user, which will prevent them from being able to follow or mention you. note that they will still be able to read your posts."
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
