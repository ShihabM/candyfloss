//
//  ViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import UIKit
import ATProtoKit
import AVFAudio

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    let config = ATProtocolConfiguration()
    
    var tableView = UITableView()
    var tempScrollPosition: CGFloat = 0
    let refreshControl = UIRefreshControl()
    var allPosts: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    
    // feeds
    var currentFeedCursor: String? = nil
    var fromFeedPush: Bool = false
    
    // temp feed from explore
    var currentFeedURI = ""
    var currentFeedDisplayName = ""
    
    // lists
    var listName: String = ""
    var listURI: String = ""
    var fromListPush: Bool = false
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var isSearching: Bool = false
    var searchFirstTime: Bool = true
    
    // loading indicator
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView.tableHeaderView?.frame.size.height = 56
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = searchView.frame.size.width
        searchController.searchBar.frame.size.height = searchView.frame.size.height
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchResults.isEmpty {} else {
            allPosts = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = allPosts
                } else {
                    allPosts = searchResults
                    tableView.reloadData()
                }
            } else {
                let z = allPosts.filter({
                    let matchingAccount: Bool = ($0.post.author.displayName ?? "").lowercased().contains(theText)
                    if let record = $0.post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
                        return record.text.lowercased().contains(theText) || matchingAccount
                    } else {
                        return false
                    }
                })
                allPosts = z
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            allPosts = self.searchResults
            tableView.reloadData()
        }
        searchFirstTime = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalStruct.currentTab = 0
    }
    
    @objc func scrollUp() {
        if allPosts.isEmpty {} else {
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
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
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
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = listName != "" ? listName : fromFeedPush ? currentFeedDisplayName : GlobalStruct.currentFeedDisplayName
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollUp), name: NSNotification.Name(rawValue: "scrollUp0"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setUpNavigationBar), name: NSNotification.Name(rawValue: "setUpNavigationBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupListDropdown), name: NSNotification.Name(rawValue: "setupListDropdown"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchLatest), name: NSNotification.Name(rawValue: "fetchLatest"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToFeeds), name: NSNotification.Name(rawValue: "goToFeeds"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchFeed), name: NSNotification.Name(rawValue: "switchFeed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchList), name: NSNotification.Name(rawValue: "switchList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                try? AVAudioSession.sharedInstance().setActive(true)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        setUpNavigationBar()
        
        if fromFeedPush {
            switchFeed(false)
        } else if fromListPush {
            switchList(false)
        } else {
            if let x = UserDefaults.standard.value(forKey: "isShowingFeeds") as? Bool {
                GlobalStruct.isShowingFeeds = x
            }
            if let x = UserDefaults.standard.value(forKey: "currentFeedURI") as? String {
                GlobalStruct.currentFeedURI = x
            }
            if let x = UserDefaults.standard.value(forKey: "currentFeedDisplayName") as? String {
                GlobalStruct.currentFeedDisplayName = x
            }
            if let x = UserDefaults.standard.value(forKey: "listURI") as? String {
                GlobalStruct.listURI = x
            }
            if let x = UserDefaults.standard.value(forKey: "listName") as? String {
                GlobalStruct.listName = x
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if GlobalStruct.currentFeedURI != "" {
                    self.switchFeed(false)
                } else if GlobalStruct.listURI != "" {
                    self.switchList(false)
                } else {
                    self.fetchTimeline(false)
                    self.setUpTable()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupListDropdown()
        }
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
        
        if !fromFeedPush && !fromListPush {
            let feedsButton = CustomButton(type: .system)
            feedsButton.setImage(UIImage(systemName: "list.bullet.below.rectangle"), for: .normal)
            feedsButton.addTarget(self, action: #selector(self.goToFeeds), for: .touchUpInside)
            let navigationBarFeedButtonItem = UIBarButtonItem(customView: feedsButton)
            navigationBarFeedButtonItem.accessibilityLabel = "Feeds"
            navigationItem.leftBarButtonItem = navigationBarFeedButtonItem
        }
        if listName == "" {
            navigationItem.rightBarButtonItems = []
        } else {
            let moreButton = CustomButton(type: .system)
            moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            var menuActions: [UIAction] = []
            let viewPeople = UIAction(title: "People", image: UIImage(systemName: "person"), identifier: nil) { action in
                let vc = FriendsViewController()
                vc.fromList = true
                vc.listName = self.listName
                vc.listURI = self.listURI
                UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
            }
            menuActions.append(viewPeople)
            let editList = UIAction(title: "Edit List", image: UIImage(systemName: "pencil.and.scribble"), identifier: nil) { action in
                
            }
            menuActions.append(editList)
            let menu = UIMenu(title: "", options: [.displayInline], children: menuActions)
            moreButton.menu = menu
            moreButton.showsMenuAsPrimaryAction = true
            let navigationBarButtonItem = UIBarButtonItem(customView: moreButton)
            navigationBarButtonItem.accessibilityLabel = "More"
            if GlobalStruct.isPostButtonInNavBar {
                navigationItem.rightBarButtonItems = [UIBarButtonItem(), UIBarButtonItem(), UIBarButtonItem(), UIBarButtonItem(), UIBarButtonItem(), UIBarButtonItem(), UIBarButtonItem(), navigationBarButtonItem]
            } else {
                navigationItem.rightBarButtonItems = [navigationBarButtonItem]
            }
        }
        
        setupListDropdown()
    }
    
    @objc func setupListDropdown() {
        let titleLabel = UIButton()
        titleLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        let attachment1 = NSTextAttachment()
        let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        let downImage1 = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig1)
        let downImage2 = imageWithImage(image: downImage1 ?? UIImage(), scaledToSize: CGSize(width: downImage1?.size.width ?? 0, height: (downImage1?.size.height ?? 0) - 3))
        attachment1.image = downImage2.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
        let attStringNewLine000 = NSMutableAttributedString()
        let attStringNewLine00 = NSMutableAttributedString(string: "\(listName != "" ? listName : fromFeedPush ? currentFeedDisplayName : GlobalStruct.currentFeedDisplayName) ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold),NSAttributedString.Key.foregroundColor : UIColor.label])
        let attString00 = NSAttributedString(attachment: attachment1)
        attStringNewLine000.append(attStringNewLine00)
        attStringNewLine000.append(attString00)
        titleLabel.setAttributedTitle(attStringNewLine000, for: .normal)
        self.navigationItem.titleView = titleLabel
        var allActions0: [UIAction] = []
        if !GlobalStruct.pinnedFeeds.isEmpty {
            let theImage = UIImageView()
            let symbolConfigIcon = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            theImage.image = UIImage(systemName: "figure.walk", withConfiguration: symbolConfigIcon)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            let menuItem = UIAction(title: "Following", image: imageWithBackground(theImage.image ?? UIImage(), backgroundColor: GlobalStruct.blueskyBlue, size: CGSize(width: 30, height: 30)).withRoundedCorners() ?? UIImage(systemName: "rectangle"), identifier: nil) { [weak self] action in
                guard let self else { return }
                GlobalStruct.listURI = ""
                GlobalStruct.listName = ""
                GlobalStruct.currentList = nil
                GlobalStruct.currentFeedURI = ""
                GlobalStruct.currentFeedDisplayName = "Following"
                GlobalStruct.currentFeed = nil
                NotificationCenter.default.post(name: Notification.Name(rawValue: "switchFeed"), object: nil)
                saveCurrentFeedAndList()
                setupListDropdown()
            }
            if GlobalStruct.currentFeedDisplayName == "Following" {
                menuItem.state = .on
            } else {
                menuItem.state = .off
            }
            allActions0.append(menuItem)
        }
        for feed in GlobalStruct.pinnedFeeds {
            if let url = feed.feedItem?.avatarImageURL {
                let theImage = UIImageView()
                theImage.sd_setImage(with: url)
                let menuItem = UIAction(title: feed.name, image: theImage.image?.withRoundedCorners() ?? UIImage(systemName: "rectangle"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.listURI = ""
                    GlobalStruct.listName = ""
                    GlobalStruct.currentList = nil
                    GlobalStruct.currentFeedURI = feed.uri
                    GlobalStruct.currentFeedDisplayName = feed.name
                    GlobalStruct.currentFeed = feed.feedItem
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "switchFeed"), object: nil)
                    saveCurrentFeedAndList()
                    setupListDropdown()
                }
                if GlobalStruct.currentFeedDisplayName == feed.name {
                    menuItem.state = .on
                } else {
                    menuItem.state = .off
                }
                allActions0.append(menuItem)
            } else {
                let menuItem = UIAction(title: feed.name, image: UIImage(systemName: "rectangle"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.listURI = ""
                    GlobalStruct.listName = ""
                    GlobalStruct.currentList = nil
                    GlobalStruct.currentFeedURI = feed.uri
                    GlobalStruct.currentFeedDisplayName = feed.name
                    GlobalStruct.currentFeed = feed.feedItem
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "switchFeed"), object: nil)
                    saveCurrentFeedAndList()
                    setupListDropdown()
                }
                if GlobalStruct.currentFeedDisplayName == feed.name {
                    menuItem.state = .on
                } else {
                    menuItem.state = .off
                }
                allActions0.append(menuItem)
            }
        }
        let feedsSubMenu = UIMenu(title: "", options: [.displayInline], children: allActions0)
        var allActions1: [UIAction] = []
        for list in GlobalStruct.pinnedLists {
            if let url = list.listItem?.avatarImageURL {
                let theImage = UIImageView()
                theImage.sd_setImage(with: url)
                let menuItem = UIAction(title: list.name, image: theImage.image?.withRoundedCorners() ?? UIImage(systemName: "list.bullet"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.listURI = list.uri
                    GlobalStruct.listName = list.name
                    GlobalStruct.currentList = list.listItem
                    GlobalStruct.currentFeedURI = ""
                    GlobalStruct.currentFeedDisplayName = ""
                    GlobalStruct.currentFeed = nil
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "switchList"), object: nil)
                    saveCurrentFeedAndList()
                    setupListDropdown()
                }
                if GlobalStruct.listName == list.name {
                    menuItem.state = .on
                } else {
                    menuItem.state = .off
                }
                allActions1.append(menuItem)
            } else {
                let menuItem = UIAction(title: list.name, image: UIImage(systemName: "list.bullet"), identifier: nil) { [weak self] action in
                    guard let self else { return }
                    GlobalStruct.listURI = list.uri
                    GlobalStruct.listName = list.name
                    GlobalStruct.currentList = list.listItem
                    GlobalStruct.currentFeedURI = ""
                    GlobalStruct.currentFeedDisplayName = ""
                    GlobalStruct.currentFeed = nil
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "switchList"), object: nil)
                    saveCurrentFeedAndList()
                    setupListDropdown()
                }
                if GlobalStruct.listName == list.name {
                    menuItem.state = .on
                } else {
                    menuItem.state = .off
                }
                allActions1.append(menuItem)
            }
        }
        let listsSubMenu = UIMenu(title: "", options: [.displayInline], children: allActions1)
        let menuItem1 = UIAction(title: "View Feeds", image: UIImage(systemName: "rectangle"), identifier: nil) { [weak self] action in
            guard let self else { return }
            GlobalStruct.isShowingFeeds = true
            let vc = FeedsListsViewController()
            vc.currentFeedCursor = currentFeedCursor
            vc.fromAddPin = true
            let nvc = SloppySwipingNav(rootViewController: vc)
            show(nvc, sender: self)
        }
        let menuItem2 = UIAction(title: "View Lists", image: UIImage(systemName: "list.bullet"), identifier: nil) { [weak self] action in
            guard let self else { return }
            GlobalStruct.isShowingFeeds = false
            let vc = FeedsListsViewController()
            vc.currentFeedCursor = currentFeedCursor
            vc.fromAddPin = true
            let nvc = SloppySwipingNav(rootViewController: vc)
            show(nvc, sender: self)
        }
        let lastSubMenu = UIMenu(title: "", options: [.displayInline], children: [menuItem1, menuItem2])
        var pinTitle: String = "Pin Feed"
        var pinImage: String = "pin"
        var shouldPin: Bool = true
        if GlobalStruct.listName != "" {
            if GlobalStruct.pinnedLists.contains(where: { $0.name == GlobalStruct.listName }) {
                pinTitle = "Unpin List"
                pinImage = "pin.slash"
                shouldPin = false
            } else {
                pinTitle = "Pin List"
            }
        } else {
            if GlobalStruct.pinnedFeeds.contains(where: { $0.name == GlobalStruct.currentFeedDisplayName }) {
                pinTitle = "Unpin Feed"
                pinImage = "pin.slash"
                shouldPin = false
            }
        }
        let menuItem3 = UIAction(title: pinTitle, image: UIImage(systemName: pinImage), identifier: nil) { [weak self] action in
            guard let self else { return }
            if GlobalStruct.listName != "" {
                if shouldPin {
                    GlobalStruct.pinnedLists.append(PinnedItems(name: GlobalStruct.listName, uri: GlobalStruct.listURI, feedItem: nil, listItem: GlobalStruct.currentList))
                    self.setupListDropdown()
                    self.savePinnedFeedsToDisk()
                } else {
                    GlobalStruct.pinnedLists = GlobalStruct.pinnedLists.filter({ x in
                        x.name != GlobalStruct.listName
                    })
                    self.setupListDropdown()
                    self.savePinnedFeedsToDisk()
                }
            } else {
                if shouldPin {
                    GlobalStruct.pinnedFeeds.append(PinnedItems(name: GlobalStruct.currentFeedDisplayName, uri: GlobalStruct.currentFeedURI, feedItem: GlobalStruct.currentFeed, listItem: nil))
                    self.setupListDropdown()
                    self.savePinnedFeedsToDisk()
                } else {
                    GlobalStruct.pinnedFeeds = GlobalStruct.pinnedFeeds.filter({ x in
                        x.name != GlobalStruct.currentFeedDisplayName
                    })
                    self.setupListDropdown()
                    self.savePinnedFeedsToDisk()
                }
            }
        }
        let pinSubMenu = UIMenu(title: "", options: [.displayInline], children: [menuItem3])
        if GlobalStruct.pinnedFeeds.isEmpty && GlobalStruct.pinnedLists.isEmpty {
            let menu = UIMenu(title: "Pin feeds and lists for quick access", options: [.displayInline], children: [feedsSubMenu, listsSubMenu, lastSubMenu])
            titleLabel.menu = menu
        } else {
            if GlobalStruct.currentFeedDisplayName == "Following" {
                let menu = UIMenu(title: "", options: [.displayInline], children: [feedsSubMenu, listsSubMenu])
                titleLabel.menu = menu
            } else {
                let menu = UIMenu(title: "", options: [.displayInline], children: [feedsSubMenu, listsSubMenu, pinSubMenu])
                titleLabel.menu = menu
            }
        }
        titleLabel.showsMenuAsPrimaryAction = true
    }
    
    func savePinnedFeedsToDisk() {
        do {
            try Disk.save(GlobalStruct.pinnedFeeds, to: .documents, as: "pinnedFeeds")
        } catch {
            print("error saving to Disk")
        }
    }
    
    func savePinnedListsToDisk() {
        do {
            try Disk.save(GlobalStruct.pinnedLists, to: .documents, as: "pinnedLists")
        } catch {
            print("error saving to Disk")
        }
    }
    
    func saveCurrentFeedAndList() {
        UserDefaults.standard.set(GlobalStruct.currentFeedURI, forKey: "currentFeedURI")
        UserDefaults.standard.set(GlobalStruct.currentFeedDisplayName, forKey: "currentFeedDisplayName")
        UserDefaults.standard.set(GlobalStruct.listURI, forKey: "listURI")
        UserDefaults.standard.set(GlobalStruct.listName, forKey: "listName")
        do {
            try Disk.save(GlobalStruct.currentFeed, to: .documents, as: "currentFeed")
        } catch {
            print("error saving to Disk")
        }
        do {
            try Disk.save(GlobalStruct.currentList, to: .documents, as: "currentList")
        } catch {
            print("error saving to Disk")
        }
    }
    
    @objc func goToFeeds() {
        defaultHaptics()
        let vc = FeedsListsViewController()
        vc.currentFeedCursor = currentFeedCursor
        let nvc = SloppySwipingNav(rootViewController: vc)
        show(nvc, sender: self)
    }
    
    @objc func switchFeed(_ hasAuthenticated: Bool = true) {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
            self.navigationItem.title = self.fromFeedPush ? self.currentFeedDisplayName : GlobalStruct.currentFeedDisplayName
            self.listURI = ""
            self.listName = ""
            self.allPosts = []
            self.currentCursor = nil
            self.tableView.reloadData()
            self.setUpTable()
            self.fetchTimeline(hasAuthenticated)
            self.setUpNavigationBar()
        }
    }
    
    @objc func switchList(_ hasAuthenticated: Bool = true) {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
            self.navigationItem.title = GlobalStruct.listName
            self.listURI = GlobalStruct.listURI
            self.listName = GlobalStruct.listName
            self.allPosts = []
            self.currentCursor = nil
            self.tableView.reloadData()
            self.setUpTable()
            self.fetchTimeline(hasAuthenticated)
            self.setUpNavigationBar()
        }
    }
    
    func fetchTimeline(_ hasAuthenticated: Bool = true) {
        Task {
            do {
                if hasAuthenticated {
                    if let atProto = GlobalStruct.atProto {
                        if currentCursor == nil {
                            let y = try await atProto.getProfile(for: GlobalStruct.userHandle)
                            GlobalStruct.currentUser = y
                        }
                        
                        if listName != "" {
                            let x = try await atProto.getListFeed(from: listURI, limit: 100)
                            
                            // filter out posts that are replies (except replies to own posts)
                            allPosts += x.feed.filter({ post in
                                var toReturn: Bool = false
                                if let parent = post.reply?.parent {
                                    switch parent  {
                                    case .postView(let parents):
                                        if parents.author.actorDID == post.post.author.actorDID {
                                            toReturn = true
                                        } else {
                                            toReturn = false
                                        }
                                    default:
                                        toReturn = false
                                    }
                                } else {
                                    toReturn = false
                                }
                                return toReturn || (post.reply == nil)
                            })
                            
                            currentCursor = x.cursor
                            DispatchQueue.main.async {
                                self.loadingIndicator.stopAnimating()
                                self.tableView.reloadData()
                                self.isFetching = false
                            }
                            
                            // prefetch feeds
                            fetchFeeds()
                        } else if GlobalStruct.currentFeedURI == "" && !fromFeedPush {
                            let x = try await atProto.getTimeline(limit: 100, cursor: currentCursor)
                            
                            // filter out posts that are replies (except replies to own posts)
                            allPosts += x.feed.filter({ post in
                                var toReturn: Bool = false
                                if let parent = post.reply?.parent {
                                    switch parent  {
                                    case .postView(let parents):
                                        if parents.author.actorDID == post.post.author.actorDID {
                                            toReturn = true
                                        } else {
                                            toReturn = false
                                        }
                                    default:
                                        toReturn = false
                                    }
                                } else {
                                    toReturn = false
                                }
                                return toReturn || (post.reply == nil)
                            })
                            
                            currentCursor = x.cursor
                            DispatchQueue.main.async {
                                self.loadingIndicator.stopAnimating()
                                self.tableView.reloadData()
                                self.isFetching = false
                            }
                            
                            // prefetch feeds
                            fetchFeeds()
                        } else {
                            var feedURI: String = GlobalStruct.currentFeedURI
                            if fromFeedPush {
                                feedURI = currentFeedURI
                            }
                            let x = try await atProto.getFeed(by: feedURI, limit: 100, cursor: currentCursor)
                            
                            // filter out posts that are replies (except replies to own posts)
                            allPosts += x.feed.filter({ post in
                                var toReturn: Bool = false
                                if let parent = post.reply?.parent {
                                    switch parent  {
                                    case .postView(let parents):
                                        if parents.author.actorDID == post.post.author.actorDID {
                                            toReturn = true
                                        } else {
                                            toReturn = false
                                        }
                                    default:
                                        toReturn = false
                                    }
                                } else {
                                    toReturn = false
                                }
                                return toReturn || (post.reply == nil)
                            })
                            
                            currentCursor = x.cursor
                            DispatchQueue.main.async {
                                self.loadingIndicator.stopAnimating()
                                self.tableView.reloadData()
                                self.isFetching = false
                            }
                            
                            // prefetch feeds
                            fetchFeeds()
                        }
                    }
                } else {
                    Task {
                        await authenticate()
                    }
                }
            } catch {
                print("Error fetching feed, refresh token and retry: \(error.localizedDescription)")
                do {
                    if let atProto = GlobalStruct.atProto {
                        try await atProto.sessionConfiguration?.refreshSession()
                        Task {
                            await authenticate()
                        }
                    }
                } catch {
                    print("Error fetching session: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    self.isFetching = false
                }
            }
        }
    }
    
    @objc func fetchLatest() {
        guard !isSearching else {
            refreshControl.endRefreshing()
            return
        }
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    if listName != "" {
                        let x = try await atProto.getListFeed(from: listURI, limit: 100)
                        
                        // filter out posts that are replies (except replies to own posts)
                        allPosts = x.feed.filter({ post in
                            var toReturn: Bool = false
                            if let parent = post.reply?.parent {
                                switch parent  {
                                case .postView(let parents):
                                    if parents.author.actorDID == post.post.author.actorDID {
                                        toReturn = true
                                    } else {
                                        toReturn = false
                                    }
                                default:
                                    toReturn = false
                                }
                            } else {
                                toReturn = false
                            }
                            return toReturn || (post.reply == nil)
                        }) + allPosts
                        
                        allPosts = allPosts.removingDuplicates()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    } else if GlobalStruct.currentFeedURI == "" && !fromFeedPush {
                        let x = try await atProto.getTimeline(limit: 100)
                        
                        // filter out posts that are replies (except replies to own posts)
                        allPosts = x.feed.filter({ post in
                            var toReturn: Bool = false
                            if let parent = post.reply?.parent {
                                switch parent  {
                                case .postView(let parents):
                                    if parents.author.actorDID == post.post.author.actorDID {
                                        toReturn = true
                                    } else {
                                        toReturn = false
                                    }
                                default:
                                    toReturn = false
                                }
                            } else {
                                toReturn = false
                            }
                            return toReturn || (post.reply == nil)
                        }) + allPosts
                        
                        allPosts = allPosts.removingDuplicates()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    } else {
                        var feedURI: String = GlobalStruct.currentFeedURI
                        if fromFeedPush {
                            feedURI = currentFeedURI
                        }
                        let x = try await atProto.getFeed(by: feedURI, limit: 100)
                        
                        // filter out posts that are replies (except replies to own posts)
                        allPosts = x.feed.filter({ post in
                            var toReturn: Bool = false
                            if let parent = post.reply?.parent {
                                switch parent  {
                                case .postView(let parents):
                                    if parents.author.actorDID == post.post.author.actorDID {
                                        toReturn = true
                                    } else {
                                        toReturn = false
                                    }
                                default:
                                    toReturn = false
                                }
                            } else {
                                toReturn = false
                            }
                            return toReturn || (post.reply == nil)
                        }) + allPosts
                        
                        allPosts = allPosts.removingDuplicates()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            } catch {
                print("Error fetching feed, refresh token and retry: \(error.localizedDescription)")
                do {
                    if let atProto = GlobalStruct.atProto {
                        try await atProto.sessionConfiguration?.refreshSession()
                        Task {
                            await authenticate(false)
                        }
                    }
                } catch {
                    print("Error fetching session: \(error.localizedDescription)")
                }
                refreshControl.endRefreshing()
            }
        }
    }
    
    func authenticate(_ fetchNextimeline: Bool = true) async {
        do {
            try await config.authenticate(with: GlobalStruct.userHandle, password: GlobalStruct.userAppPassword)
            GlobalStruct.atProto = await ATProtoKit(sessionConfiguration: config)
            if fetchNextimeline {
                fetchTimeline()
            } else {
                fetchLatest()
            }
        } catch {
            print("Error fetching: \(error.localizedDescription)")
        }
    }
    
    func fetchFeeds() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getSuggestedFeeds()
                    GlobalStruct.allFeeds = x.feeds
                    currentFeedCursor = x.cursor
                }
            } catch {
                print("Error fetching feeds: \(error.localizedDescription)")
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
            controller.searchBar.placeholder = "Search \(listName != "" ? listName : fromFeedPush ? currentFeedDisplayName : GlobalStruct.currentFeedDisplayName)"
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
        return allPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
        let post = allPosts[indexPath.row].post
        configurePostCell(cell, with: post, reason: allPosts[indexPath.row].reason)
        
        cell.avatar.tag = indexPath.row
        cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
        cell.repost.tag = indexPath.row
        cell.repost.addTarget(self, action: #selector(repostTapped(_:)), for: .touchUpInside)
        
        if !isSearching {
            if isFetching == false && currentCursor != nil {
                if indexPath.row == allPosts.count - 1 || indexPath.row == allPosts.count - 5 {
                    isFetching = true
                    fetchTimeline()
                }
            }
        }
        
        if indexPath.row == allPosts.count - 1 {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailsViewController()
        vc.detailPost = allPosts[indexPath.row].post
        navigationController?.pushViewController(vc, animated: true)
        if isSearching {
            searchController.isActive = false
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return makePostContextMenu(indexPath.row, post: self.allPosts[indexPath.row].post, reason: self.allPosts[indexPath.row].reason)
        }
    }
    
    @objc func profileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allPosts[sender.tag].post.author.actorDID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func repostTapped(_ sender: UIButton) {
        defaultHaptics()
        if let reason = allPosts[sender.tag].reason {
            switch reason {
            case .reasonRepost(let repost):
                let vc = ProfileViewController()
                vc.profile = repost.by.actorDID
                navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }

}

