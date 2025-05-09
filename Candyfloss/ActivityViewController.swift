//
//  ActivityViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import UIKit
import ATProtoKit

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var tempScrollPosition: CGFloat = 0
    let refreshControl = UIRefreshControl()
    var allNotifications: [[AppBskyLexicon.Notification.Notification]] = []
    var allSubjectPosts: [AppBskyLexicon.Feed.PostViewDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [[AppBskyLexicon.Notification.Notification]] = []
    var isSearching: Bool = false
    var searchFirstTime: Bool = true
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView.tableHeaderView?.frame.size.height = 56
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = searchView.frame.size.width
        searchController.searchBar.frame.size.height = searchView.frame.size.height
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchResults.isEmpty {} else {
            allNotifications = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = allNotifications
                } else {
                    allNotifications = searchResults
                    tableView.reloadData()
                }
            } else {
                let z = allNotifications.filter({
                    for x in $0 {
                        let matchingAccount: Bool = (x.author.displayName ?? "").lowercased().contains(theText)
                        if let record = x.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
                            return record.text.lowercased().contains(theText) || matchingAccount
                        } else {
                            return false
                        }
                    }
                    return false
                })
                allNotifications = z
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            allNotifications = self.searchResults
            tableView.reloadData()
        }
        searchFirstTime = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalStruct.currentTab = 1
    }
    
    @objc func scrollUp() {
        if allNotifications.isEmpty {} else {
            if tableView.contentOffset.y <= 60 {
                tableView.setContentOffset(CGPoint(x: 0, y: tempScrollPosition), animated: true)
                tempScrollPosition = tableView.contentOffset.y
            } else {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                tempScrollPosition = tableView.contentOffset.y
            }
        }
    }
    
    @objc func reloadTables() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func updateTint() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.searchController.searchBar.backgroundColor = GlobalStruct.backgroundTint
            self.searchController.searchBar.barTintColor = GlobalStruct.backgroundTint
            let appearance = UINavigationBarAppearance()
            self.view.backgroundColor = GlobalStruct.backgroundTint
            appearance.backgroundColor = self.view.backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.compactAppearance = appearance
            let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
            let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
            for x in self.tableView.visibleCells {
                if let y = x as? PostsCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.time.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.usertag.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.text.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.repost.titleLabel?.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.text.mentionColor = GlobalStruct.baseTint
                    y.text.hashtagColor = GlobalStruct.baseTint
                    y.text.URLColor = GlobalStruct.baseTint
                    y.text.emailColor = GlobalStruct.baseTint
                    y.text.lineSpacing = GlobalStruct.customLineSize
                    y.text.numberOfLines = GlobalStruct.maxLines
                    if let text = y.text.text {
                        y.text.text = nil
                        y.text.text = text
                    }
                    y.uriLabel.textColor = GlobalStruct.baseTint
                }
                if let y = x as? ActivityCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.time.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.postContents.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.postContents.lineSpacing = GlobalStruct.customLineSize
                    y.postContents.numberOfLines = GlobalStruct.maxLines
                }
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Activity"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollUp), name: NSNotification.Name(rawValue: "scrollUp1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        setUpNavigationBar()
        
        fetchActivity()
        setUpTable()
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
        
        let navigationButton = CustomButton(type: .system)
        navigationButton.setImage(UIImage(systemName: "gear"), for: .normal)
        navigationButton.addTarget(self, action: #selector(self.goToSettings), for: .touchUpInside)
        let navigationBarButtonItem = UIBarButtonItem(customView: navigationButton)
        navigationBarButtonItem.accessibilityLabel = "Settings"
        navigationItem.leftBarButtonItem = navigationBarButtonItem
    }
    
    @objc func goToSettings() {
        defaultHaptics()
        let vc = SettingsViewController()
        vc.fromNavigationStack = false
        getTopMostViewController()?.show(SloppySwipingNav(rootViewController: vc), sender: self)
    }
    
    func fetchActivity() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    if currentCursor == nil {
                        let y = try await atProto.getProfile(for: GlobalStruct.userHandle)
                        GlobalStruct.currentUser = y
                    }
                    let x = try await atProto.listNotifications(isPriority: nil, cursor: currentCursor)
                    currentCursor = x.cursor
                    
                    var groupedNotifications: [[AppBskyLexicon.Notification.Notification]] = []
                    var currentGroup: [AppBskyLexicon.Notification.Notification] = []
                    var previousReason: AppBskyLexicon.Notification.Notification.Reason? = nil
                    for notification in x.notifications {
                        if notification.reason == previousReason {
                            if currentGroup.contains(where: { x in
                                x.author.actorDID == notification.author.actorDID
                            }) {} else {
                                currentGroup.append(notification)
                            }
                        } else {
                            if !currentGroup.isEmpty {
                                groupedNotifications.append(currentGroup)
                            }
                            currentGroup = [notification]
                        }
                        previousReason = notification.reason
                    }
                    if !currentGroup.isEmpty {
                        groupedNotifications.append(currentGroup)
                    }
                    
                    var uris: [String] = []
                    for notification in x.notifications {
                        if notification.reason == .reply || notification.reason == .mention {
                            uris.append(notification.uri)
                        } else if let uri = notification.reasonSubjectURI {
                            uris.append(uri)
                        }
                    }
                    let subjects = try await atProto.getPosts(uris)
                    
                    DispatchQueue.main.async {
                        self.allSubjectPosts += subjects.posts
                        self.allNotifications += groupedNotifications
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                        self.isFetching = false
                    }
                }
            } catch {
                print("Error fetching activity: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isFetching = false
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc func fetchLatest() {
        self.refreshControl.endRefreshing()
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(PostsCell.self, forCellReuseIdentifier: "PostsCell")
        tableView.register(ActivityCell.self, forCellReuseIdentifier: "ActivityCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.refreshControl = refreshControl
        refreshControl.backgroundColor = .clear
        refreshControl.addTarget(self, action: #selector(self.fetchLatest), for: .valueChanged)
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.backgroundImage = UIImage()
            controller.searchBar.backgroundColor = GlobalStruct.backgroundTint
            controller.searchBar.barTintColor = GlobalStruct.backgroundTint
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self
            controller.definesPresentationContext = true
            controller.searchBar.placeholder = "Search Activity"
            self.definesPresentationContext = true
            searchView.addSubview(controller.searchBar)
            tableView.tableHeaderView = searchView
            return controller
        })()
        view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if allNotifications[indexPath.row].first?.reason ?? .none == .reply {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
            
            if let post = allSubjectPosts.first(where: { post in
                post.uri == allNotifications[indexPath.row].first?.uri ?? ""
            }) {
                configurePostCell(cell, with: post)
                
                cell.avatar.tag = indexPath.row
                cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
            }
            
            if isFetching == false && currentCursor != nil {
                if indexPath.row == allNotifications.count - 1 || indexPath.row == allNotifications.count - 5 {
                    isFetching = true
                    fetchActivity()
                }
            }
            
            if indexPath.row == allNotifications.count - 1 {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
            
            if let post = allSubjectPosts.first(where: { post in
                post.uri == allNotifications[indexPath.row].first?.reasonSubjectURI ?? ""
            }) {
                if let record = post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
                    configureActivityCell(cell, with: allNotifications[indexPath.row], text: record.text)
                } else {
                    configureActivityCell(cell, with: allNotifications[indexPath.row], text: "Deleted post")
                }
            } else {
                configureActivityCell(cell, with: allNotifications[indexPath.row], text: "Deleted post")
            }
            
            cell.avatar1.tag = indexPath.row
            cell.avatar2.tag = indexPath.row
            cell.avatar3.tag = indexPath.row
            cell.avatar1.addTarget(self, action: #selector(viewProfile1), for: .touchUpInside)
            cell.avatar2.addTarget(self, action: #selector(viewProfile2), for: .touchUpInside)
            cell.avatar3.addTarget(self, action: #selector(viewProfile3), for: .touchUpInside)
            
            if isFetching == false && currentCursor != nil {
                if indexPath.row == allNotifications.count - 1 || indexPath.row == allNotifications.count - 5 {
                    isFetching = true
                    fetchActivity()
                }
            }
            
            if indexPath.row == allNotifications.count - 1 {
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
        if let post = allSubjectPosts.first(where: { post in
            post.uri == allNotifications[indexPath.row].first?.uri ?? ""
        }) {
            let vc = DetailsViewController()
            vc.detailPost = post
            navigationController?.pushViewController(vc, animated: true)
        } else if let post = allSubjectPosts.first(where: { post in
            post.uri == allNotifications[indexPath.row].first?.reasonSubjectURI ?? ""
        }) {
            let vc = DetailsViewController()
            vc.detailPost = post
            navigationController?.pushViewController(vc, animated: true)
        }
        if allNotifications[indexPath.row].first?.reason ?? .none == .follow {
            let vc = FriendsViewController()
            vc.profile = ""
            vc.isShowingFollowers = true
            var allActivityUsers: [AppBskyLexicon.Actor.ProfileViewBasicDefinition] = []
            for x in allNotifications[indexPath.row] {
                allActivityUsers.append(x.author)
            }
            vc.allActivityUsers = allActivityUsers
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
        }
        if isSearching {
            searchController.isActive = false
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if self.allNotifications[indexPath.row].first?.reason ?? .none == .reply {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                if let post = self.allSubjectPosts.first(where: { post in
                    post.uri == self.allNotifications[indexPath.row].first?.uri ?? ""
                }) {
                    return makePostContextMenu(indexPath.row, post: post)
                } else {
                    return nil
                }
            }
        } else if self.allNotifications[indexPath.row].first?.reason ?? .none == .follow {
            return nil
        } else {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                if let post = self.allSubjectPosts.first(where: { post in
                    post.uri == self.allNotifications[indexPath.row].first?.reasonSubjectURI ?? ""
                }) {
                    return makePostContextMenu(indexPath.row, post: post)
                } else {
                    return nil
                }
            }
        }
    }
    
    @objc func profileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allNotifications[sender.tag].first?.author.actorDID ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile1(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allNotifications[sender.tag].first?.author.actorDID ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile2(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allNotifications[sender.tag][1].author.actorDID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile3(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allNotifications[sender.tag][2].author.actorDID
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
