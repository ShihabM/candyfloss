//
//  FeedsListsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 10/04/2025.
//

import UIKit
import ATProtoKit

class FeedsListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // feeds
    var tableView = UITableView()
    var currentFeedCursor: String? = nil
    var isFetchingFeeds: Bool = false
    var showingDescriptions: Bool = true
    
    // lists
    var tableView2 = UITableView()
    var allLists: [AppBskyLexicon.Graph.ListViewDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var otherListUser: String = ""
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView2.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        
        currentCursor = UserDefaults.standard.value(forKey: "currentFeedCursor") as? String ?? nil
        
        if otherListUser != "" {
            GlobalStruct.isShowingFeeds = false
        } else {
            if let x = UserDefaults.standard.value(forKey: "isShowingFeeds") as? Bool {
                GlobalStruct.isShowingFeeds = x
            }
        }
        
        if GlobalStruct.isShowingFeeds {
            navigationItem.title = "Feeds"
        } else {
            navigationItem.title = "Lists"
        }
        
        showingDescriptions = UserDefaults.standard.value(forKey: "showingDescriptions") as? Bool ?? true
        
        setUpNavigationBar()
        setUpTable()
        fetchFeedsOrLists()
    }
    
    func setUpNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = GlobalStruct.backgroundTint
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = UIColor.separator
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        if otherListUser == "" {
            let closeButton = CustomButton(type: .system)
            closeButton.setTitle("Close", for: .normal)
            closeButton.setTitleColor(GlobalStruct.baseTint, for: .normal)
            closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            closeButton.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
            let closeBarButtonItem = UIBarButtonItem(customView: closeButton)
            closeBarButtonItem.accessibilityLabel = "Dismiss"
            navigationItem.leftBarButtonItem = closeBarButtonItem
            
            if GlobalStruct.isShowingFeeds {
                let feedsButton = CustomButton(type: .system)
                if showingDescriptions {
                    feedsButton.setImage(UIImage(systemName: "arrow.down.and.line.horizontal.and.arrow.up"), for: .normal)
                } else {
                    feedsButton.setImage(UIImage(systemName: "arrow.up.and.line.horizontal.and.arrow.down"), for: .normal)
                }
                feedsButton.addTarget(self, action: #selector(self.toggleDescriptions), for: .touchUpInside)
                let navigationBarFeedButtonItem = UIBarButtonItem(customView: feedsButton)
                navigationBarFeedButtonItem.accessibilityLabel = "Toggle descriptions"
                navigationItem.rightBarButtonItem = navigationBarFeedButtonItem
            } else {
                let addButton = CustomButton(type: .system)
                addButton.setImage(UIImage(systemName: "plus"), for: .normal)
                addButton.addTarget(self, action: #selector(self.newList), for: .touchUpInside)
                let navigationBarAddButtonItem = UIBarButtonItem(customView: addButton)
                navigationBarAddButtonItem.accessibilityLabel = "New List"
                navigationItem.rightBarButtonItem = navigationBarAddButtonItem
            }
            
            setupListDropdown()
        }
    }
    
    @objc func setupListDropdown() {
        var theTitle: String = ""
        if GlobalStruct.isShowingFeeds {
            theTitle = "Feeds"
        } else {
            theTitle = "Lists"
        }
        let titleLabel = UIButton()
        titleLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        let attachment1 = NSTextAttachment()
        let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        let downImage1 = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig1)
        let downImage2 = imageWithImage(image: downImage1 ?? UIImage(), scaledToSize: CGSize(width: downImage1?.size.width ?? 0, height: (downImage1?.size.height ?? 0) - 3))
        attachment1.image = downImage2.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
        let attStringNewLine000 = NSMutableAttributedString()
        let attStringNewLine00 = NSMutableAttributedString(string: "\(theTitle) ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold),NSAttributedString.Key.foregroundColor : UIColor.label])
        let attString00 = NSAttributedString(attachment: attachment1)
        attStringNewLine000.append(attStringNewLine00)
        attStringNewLine000.append(attString00)
        titleLabel.setAttributedTitle(attStringNewLine000, for: .normal)
        self.navigationItem.titleView = titleLabel
        var allActions0: [UIAction] = []
        let menuItem = UIAction(title: "Feeds", image: UIImage(systemName: "rectangle"), identifier: nil) { [weak self] action in
            guard let self else { return }
            GlobalStruct.isShowingFeeds = true
            UserDefaults.standard.set(GlobalStruct.isShowingFeeds, forKey: "isShowingFeeds")
            self.tableView.alpha = 1
            self.tableView2.alpha = 0
            self.fetchFeedsOrLists()
            self.setUpNavigationBar()
        }
        if GlobalStruct.isShowingFeeds {
            menuItem.state = .on
        } else {
            menuItem.state = .off
        }
        allActions0.append(menuItem)
        let menuItem1 = UIAction(title: "Lists", image: UIImage(systemName: "list.bullet"), identifier: nil) { [weak self] action in
            guard let self else { return }
            GlobalStruct.isShowingFeeds = false
            UserDefaults.standard.set(GlobalStruct.isShowingFeeds, forKey: "isShowingFeeds")
            self.tableView.alpha = 0
            self.tableView2.alpha = 1
            self.fetchFeedsOrLists()
            self.setUpNavigationBar()
        }
        if GlobalStruct.isShowingFeeds {
            menuItem1.state = .off
        } else {
            menuItem1.state = .on
        }
        allActions0.append(menuItem1)
        let menu = UIMenu(title: "", options: [.displayInline], children: allActions0)
        titleLabel.menu = menu
        titleLabel.showsMenuAsPrimaryAction = true
    }
    
    @objc func dismissView() {
        defaultHaptics()
        dismiss(animated: true)
    }
    
    @objc func toggleDescriptions() {
        defaultHaptics()
        showingDescriptions = !showingDescriptions
        UserDefaults.standard.set(showingDescriptions, forKey: "showingDescriptions")
        setUpNavigationBar()
        tableView.reloadData()
    }
    
    @objc func newList() {
        defaultHaptics()
        
    }
    
    func fetchFeedsOrLists() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    if GlobalStruct.isShowingFeeds {
                        let x = try await atProto.getSuggestedFeeds(cursor: currentFeedCursor)
                        GlobalStruct.allFeeds += x.feeds
                        currentFeedCursor = x.cursor
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.isFetchingFeeds = false
                        }
                        do {
                            try Disk.save(GlobalStruct.allFeeds, to: .documents, as: "allFeeds.json")
                            UserDefaults.standard.set(currentFeedCursor, forKey: "currentFeedCursor")
                        } catch {
                            print("error saving to Disk")
                        }
                    } else {
                        var theUser = GlobalStruct.currentUser?.actorDID ?? ""
                        if otherListUser != "" {
                            theUser = otherListUser
                        }
                        let x = try await atProto.getLists(from: theUser, limit: 50, cursor: currentCursor)
                        allLists = x.lists
                        currentCursor = x.cursor
                        DispatchQueue.main.async {
                            self.tableView2.reloadData()
                            self.isFetching = false
                        }
                    }
                }
            } catch {
                print("Error fetching feeds: \(error.localizedDescription)")
            }
        }
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(FeedCell.self, forCellReuseIdentifier: "FeedCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
        tableView.reloadData()
        
        tableView2.removeFromSuperview()
        tableView2.register(FeedCell.self, forCellReuseIdentifier: "ListCell")
        tableView2.dataSource = self
        tableView2.delegate = self
        tableView2.backgroundColor = UIColor.clear
        tableView2.layer.masksToBounds = true
        tableView2.rowHeight = UITableView.automaticDimension
        tableView2.tableHeaderView = UIView()
        tableView2.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView2)
        tableView2.reloadData()
        
        if GlobalStruct.isShowingFeeds {
            tableView.alpha = 1
            tableView2.alpha = 0
        } else {
            tableView.alpha = 0
            tableView2.alpha = 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return 1 + GlobalStruct.allFeeds.count
        } else {
            return allLists.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
            let symbolConfigIcon = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            
            if indexPath.row == 0 {
                cell.configureCell(showingDescriptions)
                cell.avatar.setImage(UIImage(systemName: "figure.walk", withConfiguration: symbolConfigIcon)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
                cell.theTitle.text = "Following"
                cell.theAuthor.text = "by @bsky.app"
                if showingDescriptions {
                    cell.theDescription.text = "Posts from people you follow."
                }
            } else {
                cell.configureCell(showingDescriptions)
                if let url = GlobalStruct.allFeeds[indexPath.row - 1].avatarImageURL {
                    cell.avatar.sd_setImage(with: url, for: .normal)
                }
                cell.theTitle.text = GlobalStruct.allFeeds[indexPath.row - 1].displayName
                cell.theAuthor.text = "by @\(GlobalStruct.allFeeds[indexPath.row - 1].creator.actorHandle)"
                if showingDescriptions {
                    cell.theDescription.text = GlobalStruct.allFeeds[indexPath.row - 1].description
                }
            }
            
            if isFetchingFeeds == false && currentFeedCursor != nil {
                if indexPath.row == GlobalStruct.allFeeds.count - 1 || indexPath.row == GlobalStruct.allFeeds.count - 5 {
                    isFetchingFeeds = true
                    fetchFeedsOrLists()
                }
            }
            
            if (GlobalStruct.currentFeedDisplayName == cell.theTitle.text) && GlobalStruct.listName == "" {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            if indexPath.row == GlobalStruct.allFeeds.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
            }
            cell.accessoryView = nil
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! FeedCell
            
            cell.configureCell(true)
            if let url = allLists[indexPath.row].avatarImageURL {
                cell.avatar.sd_setImage(with: url, for: .normal)
            }
            cell.theTitle.text = allLists[indexPath.row].name
            cell.theAuthor.text = "by @\(allLists[indexPath.row].creator.actorHandle)"
            cell.theDescription.text = allLists[indexPath.row].description ?? ""
            
            if isFetching == false && currentCursor != nil {
                if indexPath.row == allLists.count - 1 || indexPath.row == allLists.count - 5 {
                    isFetching = true
                    fetchFeedsOrLists()
                }
            }
            
            if otherListUser == "" {
                if GlobalStruct.listName == cell.theTitle.text {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            if indexPath.row == allLists.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
            }
            cell.accessoryView = nil
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        defaultHaptics()
        if tableView == self.tableView {
            GlobalStruct.listURI = ""
            GlobalStruct.listName = ""
            if indexPath.row == 0 {
                GlobalStruct.currentFeedURI = ""
                GlobalStruct.currentFeedDisplayName = "Following"
            } else {
                GlobalStruct.currentFeedURI = GlobalStruct.allFeeds[indexPath.row - 1].feedURI
                GlobalStruct.currentFeedDisplayName = GlobalStruct.allFeeds[indexPath.row - 1].displayName
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "switchFeed"), object: nil)
            saveCurrentFeedAndList()
            tableView.reloadData()
            dismiss(animated: true)
        } else {
            GlobalStruct.listURI = allLists[indexPath.row].uri
            GlobalStruct.listName = allLists[indexPath.row].name
            GlobalStruct.currentFeedURI = ""
            GlobalStruct.currentFeedDisplayName = ""
            if otherListUser == "" {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "switchList"), object: nil)
                saveCurrentFeedAndList()
                tableView.reloadData()
            } else {
                let vc = ViewController()
                vc.fromListPush = true
                navigationController?.pushViewController(vc, animated: true)
            }
            dismiss(animated: true)
        }
    }
    
    func saveCurrentFeedAndList() {
        UserDefaults.standard.set(GlobalStruct.currentFeedURI, forKey: "currentFeedURI")
        UserDefaults.standard.set(GlobalStruct.currentFeedDisplayName, forKey: "currentFeedDisplayName")
        UserDefaults.standard.set(GlobalStruct.listURI, forKey: "listURI")
        UserDefaults.standard.set(GlobalStruct.listName, forKey: "listName")
    }
    
}
