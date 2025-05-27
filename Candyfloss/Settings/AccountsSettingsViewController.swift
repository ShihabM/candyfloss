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
    
    let config = ATProtocolConfiguration()
    
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
        
        let addButton = CustomButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.addTarget(self, action: #selector(self.newAccount), for: .touchUpInside)
        let navigationBarAddButtonItem = UIBarButtonItem(customView: addButton)
        navigationBarAddButtonItem.accessibilityLabel = "New Account"
        navigationItem.rightBarButtonItem = navigationBarAddButtonItem
        
        fetchAccounts()
    }
    
    @objc func newAccount() {
        let alert = UIAlertController(title: "Sign In", message: "Enter username and password", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Username"
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
        }
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.autocapitalizationType = .none
            textField.isSecureTextEntry = true
        }
        let connectAction = UIAlertAction(title: "Sign In", style: .default) { _ in
            let username = alert.textFields?[0].text ?? ""
            let password = alert.textFields?[1].text ?? ""
            let user = UserStruct(username: username, password: password)
            GlobalStruct.allUsers.append(user)
            GlobalStruct.currentSelectedUser = username
            self.fetchAccounts(true)
            Task {
                await self.authenticate(saveToDisk: true)
            }
        }
        alert.addAction(connectAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func fetchAccounts(_ latest: Bool = false) {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    if latest {
                        let y = try await atProto.getProfile(for: GlobalStruct.allUsers.last?.username ?? "")
                        allAccounts.append(y)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        for user in GlobalStruct.allUsers {
                            let y = try await atProto.getProfile(for: user.username)
                            allAccounts.append(y)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
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
        
        let user: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = allAccounts[indexPath.row]
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
            GlobalStruct.currentUser = allAccounts[indexPath.row]
            GlobalStruct.currentSelectedUser = allAccounts[indexPath.row].actorHandle
            UserDefaults.standard.set(GlobalStruct.currentSelectedUser, forKey: "currentSelectedUser")
            Task {
                await authenticate()
            }
        }
    }
    
    func authenticate(saveToDisk: Bool = false) async {
        let user = GlobalStruct.allUsers.first { x in
            x.username == GlobalStruct.currentSelectedUser
        }
        do {
            try await config.authenticate(with: user?.username ?? GlobalStruct.userHandle, password: user?.password ?? GlobalStruct.userAppPassword)
            GlobalStruct.atProto = await ATProtoKit(sessionConfiguration: config)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "resetTimelines"), object: nil)
            if saveToDisk {
                do {
                    try Disk.save(GlobalStruct.allUsers, to: .documents, as: "allUsers")
                    UserDefaults.standard.set(GlobalStruct.currentSelectedUser, forKey: "currentSelectedUser")
                } catch {
                    print("error saving to Disk")
                }
            } else {
                dismiss(animated: true)
            }
        } catch {
            print("Error authenticating: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if allAccounts[indexPath.row].actorHandle != GlobalStruct.currentSelectedUser {
            let removeAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
                if let index = self.allAccounts.firstIndex(where: { x in
                    x.actorHandle == GlobalStruct.currentSelectedUser
                }) {
                    self.allAccounts.remove(at: index)
                    GlobalStruct.allUsers.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    do {
                        try Disk.save(GlobalStruct.allUsers, to: .documents, as: "allUsers")
                    } catch {
                        print("error saving to Disk")
                    }
                }
                completionHandler(true)
            }
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            let image = UIImage(systemName: "trash.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal) ?? UIImage()
            if let circularImage = createImageWithCircularBackground(icon: image, backgroundColor: .systemRed, diameter: 40) {
                removeAction.image = circularImage
            }
            removeAction.backgroundColor = GlobalStruct.backgroundTint
            let configuration = UISwipeActionsConfiguration(actions: [removeAction])
            return configuration
        } else {
            return nil
        }
    }
    
    func createImageWithCircularBackground(icon: UIImage, backgroundColor: UIColor, diameter: CGFloat) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        var scale: CGFloat = 1
        scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        context.interpolationQuality = .high
        let path = UIBezierPath(ovalIn: frame)
        backgroundColor.setFill()
        path.fill()
        path.addClip()
        let iconSize = icon.size
        let iconRect = CGRect(
            x: (diameter - iconSize.width) / 2,
            y: (diameter - iconSize.height) / 2,
            width: iconSize.width,
            height: iconSize.height
        )
        icon.draw(in: iconRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
