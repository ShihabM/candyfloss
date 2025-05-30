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
    var filteredNotifications: [[AppBskyLexicon.Notification.Notification]] = []
    var allSubjectPosts: [AppBskyLexicon.Feed.PostViewDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var notificationsSection: Int = 0
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [[AppBskyLexicon.Notification.Notification]] = []
    var isSearching: Bool = false
    var searchFirstTime: Bool = true
    
    // loading indicator
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLayoutSubviews() {
        loadingIndicator.center = view.center
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView.tableHeaderView?.frame.size.height = 56
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = searchView.frame.size.width
        searchController.searchBar.frame.size.height = searchView.frame.size.height
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchResults.isEmpty {} else {
            filteredNotifications = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = filteredNotifications
                } else {
                    filteredNotifications = searchResults
                    tableView.reloadData()
                }
            } else {
                let z = filteredNotifications.filter({
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
                filteredNotifications = z
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            filteredNotifications = self.searchResults
            tableView.reloadData()
        }
        searchFirstTime = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalStruct.currentTab = 1
    }
    
    @objc func scrollUp() {
        if filteredNotifications.isEmpty {} else {
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
    
    @objc func resetTimelines() {
        DispatchQueue.main.async {
            self.allSubjectPosts = []
            self.allNotifications = []
            self.filteredNotifications = []
            self.fetchActivity()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        
        notificationsSection = UserDefaults.standard.value(forKey: "notificationsSection") as? Int ?? 0
        if notificationsSection == 0 {
            navigationItem.title = "Activity"
        } else {
            navigationItem.title = "Mentions"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollUp), name: NSNotification.Name(rawValue: "scrollUp1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setUpNavigationBar), name: NSNotification.Name(rawValue: "setUpNavigationBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetTimelines), name: NSNotification.Name(rawValue: "resetTimelines"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchActivity), name: NSNotification.Name(rawValue: "fetchActivity"), object: nil)
        
        setUpNavigationBar()
        
        fetchActivity()
        setUpTable()
    }
    
    @objc func setUpNavigationBar() {
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
        if UIDevice.current.userInterfaceIdiom == .pad {} else {
            navigationItem.leftBarButtonItem = navigationBarButtonItem
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad && !GlobalStruct.inSlideOver {
            let postButton = CustomButton(type: .system)
            postButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            postButton.addTarget(self, action: #selector(self.goToPost), for: .touchUpInside)
            let navigationBarPostButtonItem = UIBarButtonItem(customView: postButton)
            navigationBarPostButtonItem.accessibilityLabel = "Post"
            navigationItem.rightBarButtonItems = [UIBarButtonItem(), navigationBarPostButtonItem]
        }
        
        setupListDropdown()
    }
    
    @objc func setupListDropdown() {
        var theTitle: String = ""
        if notificationsSection == 0 {
            theTitle = "Activity"
        } else {
            theTitle = "Mentions"
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
        let menuItem = UIAction(title: "Activity", image: UIImage(systemName: "bell"), identifier: nil) { [weak self] action in
            guard let self else { return }
            notificationsSection = 0
            UserDefaults.standard.set(notificationsSection, forKey: "notificationsSection")
            filteredNotifications = allNotifications
            updateSearchBar(text: "Activity")
            tableView.reloadData()
            setupListDropdown()
        }
        if notificationsSection == 0 {
            menuItem.state = .on
        } else {
            menuItem.state = .off
        }
        allActions0.append(menuItem)
        let menuItem1 = UIAction(title: "Mentions", image: UIImage(systemName: "at"), identifier: nil) { [weak self] action in
            guard let self else { return }
            notificationsSection = 1
            UserDefaults.standard.set(notificationsSection, forKey: "notificationsSection")
            filteredNotifications = allNotifications.filter({ notification in
                notification.contains { n in
                    n.reason == .reply || n.reason == .mention
                }
            })
            updateSearchBar(text: "Mentions")
            tableView.reloadData()
            setupListDropdown()
        }
        if notificationsSection == 1 {
            menuItem1.state = .on
        } else {
            menuItem1.state = .off
        }
        allActions0.append(menuItem1)
        let menu = UIMenu(title: "", options: [.displayInline], children: allActions0)
        titleLabel.menu = menu
        titleLabel.showsMenuAsPrimaryAction = true
    }
    
    func updateSearchBar(text: String) {
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
            controller.searchBar.placeholder = "Search \(text)"
            self.definesPresentationContext = true
            searchView.addSubview(controller.searchBar)
            tableView.tableHeaderView = searchView
            return controller
        })()
    }
    
    @objc func goToSettings() {
        defaultHaptics()
        let vc = SettingsViewController()
        vc.fromNavigationStack = false
        getTopMostViewController()?.show(SloppySwipingNav(rootViewController: vc), sender: self)
    }
    
    @objc func goToPost() {
        defaultHaptics()
        let vc = ComposerViewController()
        let nvc = SloppySwipingNav(rootViewController: vc)
        nvc.isModalInPresentation = true
        self.present(nvc, animated: true, completion: nil)
    }
    
    @objc func fetchActivity() {
        Task {
            let user = GlobalStruct.allUsers.first { x in
                x.username == GlobalStruct.currentSelectedUser
            }
            do {
                if let atProto = GlobalStruct.atProto {
                    if currentCursor == nil {
                        let y = try await atProto.getProfile(for: user?.username ?? "")
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
                        if self.notificationsSection == 0 {
                            self.filteredNotifications = self.allNotifications
                        } else {
                            self.filteredNotifications = self.allNotifications.filter({ notification in
                                notification.contains { n in
                                    n.reason == .reply || n.reason == .mention
                                }
                            })
                        }
                        self.loadingIndicator.stopAnimating()
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                        self.isFetching = false
                    }
                }
            } catch {
                print("Error fetching activity: \(error)")
                DispatchQueue.main.async {
                    self.isFetching = false
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc func fetchLatest() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let latest = try await atProto.listNotifications(isPriority: nil, cursor: nil)

                    var newGrouped: [[AppBskyLexicon.Notification.Notification]] = []
                    var group: [AppBskyLexicon.Notification.Notification] = []
                    var previousReason: AppBskyLexicon.Notification.Notification.Reason? = nil
                    for notification in latest.notifications {
                        if allNotifications.flatMap({ $0 }).contains(where: { $0.uri == notification.uri }) {
                            break
                        }

                        if notification.reason == previousReason {
                            if !group.contains(where: { $0.author.actorDID == notification.author.actorDID }) {
                                group.insert(notification, at: 0)
                            }
                        } else {
                            if !group.isEmpty { newGrouped.append(group) }
                            group = [notification]
                        }
                        previousReason = notification.reason
                    }
                    if !group.isEmpty {
                        newGrouped.append(group)
                    }

                    var uris: [String] = []
                    for notification in latest.notifications {
                        if notification.reason == .reply || notification.reason == .mention {
                            uris.append(notification.uri)
                        } else if let uri = notification.reasonSubjectURI {
                            uris.append(uri)
                        }
                    }
                    let newSubjects = try await atProto.getPosts(uris)

                    DispatchQueue.main.async {
                        self.allSubjectPosts.insert(contentsOf: newSubjects.posts, at: 0)
                        self.allNotifications.insert(contentsOf: newGrouped, at: 0)

                        if self.notificationsSection == 0 {
                            self.filteredNotifications = self.allNotifications
                        } else {
                            self.filteredNotifications = self.allNotifications.filter {
                                $0.contains { $0.reason == .reply || $0.reason == .mention }
                            }
                        }

                        self.refreshControl.endRefreshing()
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Error fetching latest notifications: \(error)")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func setUpTable() {
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
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
        return filteredNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredNotifications[indexPath.row].first?.reason ?? .none == .reply || filteredNotifications[indexPath.row].first?.reason ?? .none == .mention {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
            
            cell.avatar.tag = indexPath.row
            cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
            if let post = allSubjectPosts.first(where: { post in
                post.uri == filteredNotifications[indexPath.row].first?.uri ?? ""
            }) {
                configurePostCell(cell, with: post)
            } else {
                if let record = filteredNotifications[indexPath.row].first?.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
                    if let url = filteredNotifications[indexPath.row].first?.author.avatarImageURL {
                        cell.avatar.sd_setImage(with: url, for: .normal)
                    } else {
                        cell.avatar.setImage(UIImage(), for: .normal)
                    }
                    cell.username.text = filteredNotifications[indexPath.row].first?.author.displayName ?? ""
                    if cell.username.text == "" {
                        cell.username.text = " "
                    }
                    cell.usertag.text = "@\(filteredNotifications[indexPath.row].first?.author.actorHandle ?? "")"
                    cell.text.text = record.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    let timeSince = record.createdAt
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = GlobalStruct.dateFormatter
                    if GlobalStruct.dateFormat == 0 {
                        cell.time.text = timeSince.toStringWithRelativeTime()
                    } else {
                        cell.time.text = timeSince.toString(dateStyle: .short, timeStyle: .short)
                    }
                    cell.repliesCount = 0
                    cell.likesCount = 0
                    cell.repostsCount = 0
                    cell.configure(post: nil, showActionButtons: GlobalStruct.showActionButtons, isRepost: nil, isNestedQuote: false, isNestedReply: false, isPinned: false)
                    Task {
                        do {
                            if let atProto = GlobalStruct.atProto {
                                let posts = try await atProto.getPosts([filteredNotifications[indexPath.row].first?.uri ?? ""])
                                self.allSubjectPosts += posts.posts
                                cell.repliesCount = posts.posts.first?.replyCount ?? 0
                                cell.likesCount = posts.posts.first?.likeCount ?? 0
                                cell.repostsCount = posts.posts.first?.repostCount ?? 0
                            }
                        } catch {
                            print("Error fetching post: \(error)")
                        }
                    }
                } else {
                    cell.avatar.setImage(UIImage(), for: .normal)
                    cell.username.text = ""
                    cell.usertag.text = ""
                    cell.text.text = ""
                    cell.time.text = ""
                }
            }
            
            if isFetching == false && currentCursor != nil {
                if indexPath.row == filteredNotifications.count - 1 || indexPath.row == filteredNotifications.count - 5 {
                    isFetching = true
                    fetchActivity()
                }
            }
            
            if indexPath.row == filteredNotifications.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
                post.uri == filteredNotifications[indexPath.row].first?.reasonSubjectURI ?? ""
            }) {
                if let record = post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
                    configureActivityCell(cell, with: filteredNotifications[indexPath.row], text: record.text)
                } else {
                    configureActivityCell(cell, with: filteredNotifications[indexPath.row], text: "Deleted post")
                }
            } else {
                configureActivityCell(cell, with: filteredNotifications[indexPath.row], text: "Deleted post")
            }
            
            cell.avatar1.tag = indexPath.row
            cell.avatar2.tag = indexPath.row
            cell.avatar3.tag = indexPath.row
            cell.avatar1.addTarget(self, action: #selector(viewProfile1), for: .touchUpInside)
            cell.avatar2.addTarget(self, action: #selector(viewProfile2), for: .touchUpInside)
            cell.avatar3.addTarget(self, action: #selector(viewProfile3), for: .touchUpInside)
            
            if isFetching == false && currentCursor != nil {
                if indexPath.row == filteredNotifications.count - 1 || indexPath.row == filteredNotifications.count - 5 {
                    isFetching = true
                    fetchActivity()
                }
            }
            
            if indexPath.row == filteredNotifications.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
            post.uri == filteredNotifications[indexPath.row].first?.uri ?? ""
        }) {
            let vc = DetailsViewController()
            vc.detailPost = post
            navigationController?.pushViewController(vc, animated: true)
        } else if let post = allSubjectPosts.first(where: { post in
            post.uri == filteredNotifications[indexPath.row].first?.reasonSubjectURI ?? ""
        }) {
            let vc = DetailsViewController()
            vc.detailPost = post
            navigationController?.pushViewController(vc, animated: true)
        } else {
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        if let record = filteredNotifications[indexPath.row].first?.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
                            let post = try await atProto.searchPosts(matching: record.text, author: filteredNotifications[indexPath.row].first?.author.actorHandle ?? "")
                            if let post = post.posts.first {
                                let vc = DetailsViewController()
                                vc.detailPost = post
                                navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                } catch {
                    print("Error fetching post: \(error)")
                }
            }
        }
        if filteredNotifications[indexPath.row].first?.reason ?? .none == .follow {
            let vc = FriendsViewController()
            vc.profile = ""
            vc.isShowingFollowers = true
            var allActivityUsers: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
            for x in filteredNotifications[indexPath.row] {
                allActivityUsers.append(x.author)
            }
            vc.allActivityUsers = allActivityUsers
            if UIDevice.current.userInterfaceIdiom == .pad {
                navigationController?.pushViewController(vc, animated: true)
            } else {
                UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
            }
        }
        if isSearching {
            searchController.isActive = false
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if self.filteredNotifications[indexPath.row].first?.reason ?? .none == .reply || self.filteredNotifications[indexPath.row].first?.reason ?? .none == .mention {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                if let post = self.allSubjectPosts.first(where: { post in
                    post.uri == self.filteredNotifications[indexPath.row].first?.uri ?? ""
                }) {
                    return makePostContextMenu(indexPath.row, post: post)
                } else {
                    return nil
                }
            }
        } else if self.filteredNotifications[indexPath.row].first?.reason ?? .none == .follow {
            return nil
        } else {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                if let post = self.allSubjectPosts.first(where: { post in
                    post.uri == self.filteredNotifications[indexPath.row].first?.reasonSubjectURI ?? ""
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
        vc.profile = filteredNotifications[sender.tag].first?.author.actorDID ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile1(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = filteredNotifications[sender.tag].first?.author.actorDID ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile2(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = filteredNotifications[sender.tag][1].author.actorDID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewProfile3(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = filteredNotifications[sender.tag][2].author.actorDID
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
