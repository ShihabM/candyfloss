//
//  AccountsSettingsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 27/05/2025.
//

import Foundation
import UIKit
import ATProtoKit

class AccountsSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var allAccounts: [AppBskyLexicon.Actor.ProfileViewDetailedDefinition] = []
    
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
        navigationItem.title = "Accounts"
        
        tableView.allowsFocus = true
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = GlobalStruct.modalBackground
        tableView.layer.masksToBounds = true
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        tableView.reloadData()
        
        fetchAccounts()
    }
    
    func fetchAccounts() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    for user in GlobalStruct.allUsers {
                        let y = try await atProto.getProfile(for: user.username)
                        allAccounts.append(y)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    allAccounts = allAccounts.sorted(by: { x, y in
                        x.actorHandle < y.actorHandle
                    })
                    tableView.reloadData()
                }
            } catch {
                print("Error fetching accounts: \(error)")
            }
        }
    }
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        var user: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = allAccounts[indexPath.row]
        if let url = user?.avatarImageURL {
            cell.avatar.sd_imageTransition = .fade
            cell.avatar.sd_setImage(with: url, for: .normal)
            cell.avatar.tag = indexPath.row
        } else {
            cell.avatar.setImage(UIImage(), for: .normal)
        }
        cell.username.text = user?.displayName ?? ""
        cell.usertag.text = "@\(user?.actorHandle ?? "")"
        let bioText = user?.description ?? ""
        cell.configureCell(false, bioText: bioText)
        
        if user?.actorHandle ?? "" == GlobalStruct.currentSelectedUser {
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if allAccounts[indexPath.row].actorHandle != GlobalStruct.currentSelectedUser {
            
        }
    }
    
}
