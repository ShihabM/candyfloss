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
    var currentListCursor: String? = nil
    var isFetchingFeeds: Bool = false
    var showingDescriptions: Bool = true
    var fromTab: Bool = false
    var isShowingFeeds: Bool = true
    
    // lists
    var tableView2 = UITableView()
    var allLists: [AppBskyLexicon.Graph.ListViewDefinition] = []
    var isFetching: Bool = false
    var otherListUser: String = ""
    
    var fromAddPin: Bool = false
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView2.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    @objc func updateTint() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let appearance = UINavigationBarAppearance()
            self.view.backgroundColor = GlobalStruct.backgroundTint
            appearance.backgroundColor = self.view.backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.compactAppearance = appearance
            let defaultFontSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
            for x in self.tableView.visibleCells {
                if let y = x as? FeedTipCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.bgView.backgroundColor = GlobalStruct.groupBG
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
                    y.theSubtitle.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                if let y = x as? TrendingFeedCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: defaultFontSize + GlobalStruct.customTextSize, weight: .semibold)
                    y.theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                if let y = x as? FeedCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
                    y.theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
            }
            self.tableView.reloadData()
            for x in self.tableView2.visibleCells {
                if let y = x as? FeedTipCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.bgView.backgroundColor = GlobalStruct.groupBG
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
                    y.theSubtitle.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                if let y = x as? TrendingFeedCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: defaultFontSize + GlobalStruct.customTextSize, weight: .semibold)
                    y.theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                if let y = x as? FeedCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
                    y.theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
            }
            self.tableView2.reloadData()
        }
    }
    
    @objc func updatePinned() {
        DispatchQueue.main.async {
            if !GlobalStruct.inVCFromList {
                if !self.fromTab {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                }
            }
            self.savePinnedListsToDisk()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tableView2.reloadData()
            }
        }
    }
    
    @objc func deleteList() {
        DispatchQueue.main.async {
            if let pinnedIndex = GlobalStruct.pinnedLists.firstIndex(where: { y in
                y.uri == GlobalStruct.listURIToDelete
            }) {
                GlobalStruct.pinnedLists.remove(at: pinnedIndex)
                self.updatePinned()
            }
            if let index = self.allLists.firstIndex(where: { y in
                y.uri == GlobalStruct.listURIToDelete
            }) {
                self.allLists.remove(at: index)
                self.updatePinned()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshLists), name: NSNotification.Name(rawValue: "refreshLists"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePinned), name: NSNotification.Name(rawValue: "updatePinned"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteList), name: NSNotification.Name(rawValue: "deleteList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        currentFeedCursor = UserDefaults.standard.value(forKey: "currentFeedCursor") as? String ?? nil
        currentListCursor = UserDefaults.standard.value(forKey: "currentListCursor") as? String ?? nil
        
        if fromTab {
            isShowingFeeds = false
        } else {
            if !fromAddPin {
                if otherListUser != "" {
                    GlobalStruct.isShowingFeeds = false
                    isShowingFeeds = GlobalStruct.isShowingFeeds
                } else {
                    if let x = UserDefaults.standard.value(forKey: "isShowingFeeds") as? Bool {
                        GlobalStruct.isShowingFeeds = x
                        isShowingFeeds = GlobalStruct.isShowingFeeds
                    }
                }
            } else {
                isShowingFeeds = GlobalStruct.isShowingFeeds
            }
        }
        
        if isShowingFeeds {
            navigationItem.title = "Feeds"
        } else {
            navigationItem.title = "Lists"
        }
        
        showingDescriptions = UserDefaults.standard.value(forKey: "showingDescriptions") as? Bool ?? true
        
        if fromTab {
            let titleLabel = UIButton()
            titleLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
            let attStringNewLine000 = NSMutableAttributedString()
            let attStringNewLine00 = NSMutableAttributedString(string: "Lists", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold),NSAttributedString.Key.foregroundColor : UIColor.label])
            attStringNewLine000.append(attStringNewLine00)
            titleLabel.setAttributedTitle(attStringNewLine000, for: .normal)
            self.navigationItem.titleView = titleLabel
        }
        
        setUpNavigationBar()
        setUpTable()
        fetchFeedsOrLists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalStruct.currentTab = 8
        if fromTab {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideNewPostButton"), object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if fromTab {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showNewPostButton"), object: nil)
        }
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
            
            if isShowingFeeds {
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
                if UIDevice.current.userInterfaceIdiom == .pad {
                    navigationItem.rightBarButtonItems = [UIBarButtonItem(), UIBarButtonItem(), UIBarButtonItem(), UIBarButtonItem(), navigationBarAddButtonItem]
                } else {
                    navigationItem.rightBarButtonItem = navigationBarAddButtonItem
                }
            }
            
            if !fromTab {
                setupListDropdown()
            }
        }
        
        if fromTab {
            let navigationButton = CustomButton(type: .system)
            navigationButton.setImage(UIImage(systemName: "gear"), for: .normal)
            navigationButton.addTarget(self, action: #selector(self.goToSettings), for: .touchUpInside)
            let navigationBarButtonItem = UIBarButtonItem(customView: navigationButton)
            navigationBarButtonItem.accessibilityLabel = "Settings"
            if UIDevice.current.userInterfaceIdiom == .pad {
                navigationItem.leftBarButtonItems = [UIBarButtonItem(), UIBarButtonItem(), UIBarButtonItem(), navigationBarButtonItem]
            } else {
                navigationItem.leftBarButtonItem = navigationBarButtonItem
            }
        }
    }
    
    @objc func goToSettings() {
        defaultHaptics()
        let vc = SettingsViewController()
        vc.fromNavigationStack = false
        getTopMostViewController()?.show(SloppySwipingNav(rootViewController: vc), sender: self)
    }
    
    @objc func setupListDropdown() {
        var theTitle: String = ""
        if isShowingFeeds {
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
            isShowingFeeds = true
            GlobalStruct.isShowingFeeds = true
            UserDefaults.standard.set(GlobalStruct.isShowingFeeds, forKey: "isShowingFeeds")
            self.tableView.alpha = 1
            self.tableView2.alpha = 0
            self.fetchFeedsOrLists()
            self.setUpNavigationBar()
        }
        if isShowingFeeds {
            menuItem.state = .on
        } else {
            menuItem.state = .off
        }
        allActions0.append(menuItem)
        let menuItem1 = UIAction(title: "Lists", image: UIImage(systemName: "list.bullet"), identifier: nil) { [weak self] action in
            guard let self else { return }
            isShowingFeeds = false
            GlobalStruct.isShowingFeeds = false
            UserDefaults.standard.set(GlobalStruct.isShowingFeeds, forKey: "isShowingFeeds")
            self.tableView.alpha = 0
            self.tableView2.alpha = 1
            self.fetchFeedsOrLists()
            self.setUpNavigationBar()
        }
        if isShowingFeeds {
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
        let vc = NewListViewController()
        let nvc = SloppySwipingNav(rootViewController: vc)
        getTopMostViewController()?.present(nvc, animated: true, completion: nil)
    }
    
    @objc func refreshLists() {
        DispatchQueue.main.async {
            self.isShowingFeeds = false
            self.allLists = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.fetchFeedsOrLists()
            }
        }
    }
    
    func fetchFeedsOrLists() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    if isShowingFeeds {
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
                        let x = try await atProto.getLists(from: theUser, limit: 50, cursor: currentListCursor)
                        allLists = x.lists
                        currentListCursor = x.cursor
                        if otherListUser == "" {
                            GlobalStruct.allLists = allLists
                        }
                        DispatchQueue.main.async {
                            self.tableView2.reloadData()
                            self.isFetching = false
                        }
                    }
                }
            } catch {
                print("Error fetching feeds: \(error)")
            }
        }
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(FeedTipCell.self, forCellReuseIdentifier: "FeedTipCell")
        tableView.register(TrendingFeedCell.self, forCellReuseIdentifier: "TopFeedCell")
        tableView.register(FeedCell.self, forCellReuseIdentifier: "FeedCell")
        tableView.register(FeedCell.self, forCellReuseIdentifier: "FeedCellPinned")
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
        tableView2.register(FeedTipCell.self, forCellReuseIdentifier: "FeedTipCell")
        tableView2.register(TrendingFeedCell.self, forCellReuseIdentifier: "TopListCell")
        tableView2.register(FeedCell.self, forCellReuseIdentifier: "ListCell")
        tableView2.register(FeedCell.self, forCellReuseIdentifier: "ListCellPinned")
        tableView2.dataSource = self
        tableView2.delegate = self
        tableView2.backgroundColor = UIColor.clear
        tableView2.layer.masksToBounds = true
        tableView2.rowHeight = UITableView.automaticDimension
        tableView2.tableHeaderView = UIView()
        tableView2.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView2)
        tableView2.reloadData()
        
        if isShowingFeeds {
            tableView.alpha = 1
            tableView2.alpha = 0
        } else {
            tableView.alpha = 0
            tableView2.alpha = 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if section == 0 {
                if GlobalStruct.pinnedFeeds.isEmpty {
                    return 1
                } else {
                    return GlobalStruct.pinnedFeeds.count
                }
            } else {
                return 2 + GlobalStruct.allFeeds.count
            }
        } else {
            if section == 0 {
                if allLists.isEmpty {
                    return 0
                } else {
                    if GlobalStruct.pinnedLists.isEmpty {
                        return 1
                    } else {
                        return GlobalStruct.pinnedLists.count
                    }
                }
            } else {
                if allLists.isEmpty {
                    return 0
                } else {
                    return 1 + allLists.count
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            if indexPath.section == 0 {
                if GlobalStruct.pinnedFeeds.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTipCell", for: indexPath) as! FeedTipCell
                    
                    cell.theTitle.text = "Swipe to Pin"
                    cell.theSubtitle.text = "Swipe feeds left to pin them for quick access from the home tab"
                    
                    cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width * 2, bottom: 0, right: 0)
                    cell.accessoryView = nil
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clear
                    cell.selectedBackgroundView = bgColorView
                    cell.backgroundColor = GlobalStruct.backgroundTint
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCellPinned", for: indexPath) as! FeedCell
                    
                    cell.configureCell(showingDescriptions)
                    if let url = GlobalStruct.pinnedFeeds[indexPath.row].feedItem?.avatarImageURL {
                        cell.avatar.sd_setImage(with: url, for: .normal)
                    } else {
                        cell.avatar.setImage(UIImage(), for: .normal)
                    }
                    cell.theTitle.text = GlobalStruct.pinnedFeeds[indexPath.row].feedItem?.displayName ?? ""
                    cell.theAuthor.text = "by @\(GlobalStruct.pinnedFeeds[indexPath.row].feedItem?.creator.actorHandle ?? "")"
                    if showingDescriptions {
                        cell.theDescription.text = GlobalStruct.pinnedFeeds[indexPath.row].feedItem?.description ?? ""
                    }
                    
                    if (GlobalStruct.currentFeedDisplayName == cell.theTitle.text) && GlobalStruct.listName == "" {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                    if indexPath.row == GlobalStruct.pinnedFeeds.count - 1 {
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
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TopFeedCell", for: indexPath) as! TrendingFeedCell
                    
                    cell.configureCell(false)
                    cell.theTitle.text = "All Feeds"
                    cell.theAuthor.text = "A list of popular feeds"
                    
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    cell.accessoryView = nil
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clear
                    cell.selectedBackgroundView = bgColorView
                    cell.backgroundColor = GlobalStruct.backgroundTint
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
                    let symbolConfigIcon = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
                    
                    if indexPath.row == 1 {
                        cell.configureCell(showingDescriptions)
                        cell.avatar.setImage(UIImage(systemName: "figure.walk", withConfiguration: symbolConfigIcon)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
                        cell.theTitle.text = "Following"
                        cell.theAuthor.text = "by @bsky.app"
                        if showingDescriptions {
                            cell.theDescription.text = "Posts from people you follow."
                        }
                    } else {
                        cell.configureCell(showingDescriptions)
                        if let url = GlobalStruct.allFeeds[indexPath.row - 2].avatarImageURL {
                            cell.avatar.sd_setImage(with: url, for: .normal)
                        } else {
                            cell.avatar.setImage(UIImage(), for: .normal)
                        }
                        cell.theTitle.text = GlobalStruct.allFeeds[indexPath.row - 2].displayName
                        cell.theAuthor.text = "by @\(GlobalStruct.allFeeds[indexPath.row - 2].creator.actorHandle)"
                        if showingDescriptions {
                            cell.theDescription.text = GlobalStruct.allFeeds[indexPath.row - 2].description
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
                    if indexPath.row == GlobalStruct.allFeeds.count {
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
        } else {
            if indexPath.section == 0 {
                if GlobalStruct.pinnedLists.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTipCell", for: indexPath) as! FeedTipCell
                    
                    cell.theTitle.text = "Swipe to Pin"
                    cell.theSubtitle.text = "Swipe lists left to pin them for quick access from the home tab"
                    
                    cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width * 2, bottom: 0, right: 0)
                    cell.accessoryView = nil
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clear
                    cell.selectedBackgroundView = bgColorView
                    cell.backgroundColor = GlobalStruct.backgroundTint
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ListCellPinned", for: indexPath) as! FeedCell
                    
                    cell.configureCell(true)
                    if let url = GlobalStruct.pinnedLists[indexPath.row].listItem?.avatarImageURL {
                        cell.avatar.sd_setImage(with: url, for: .normal)
                    } else {
                        cell.avatar.setImage(UIImage(), for: .normal)
                    }
                    cell.theTitle.text = GlobalStruct.pinnedLists[indexPath.row].listItem?.name ?? ""
                    cell.theAuthor.text = "by @\(GlobalStruct.pinnedLists[indexPath.row].listItem?.creator.actorHandle ?? "")"
                    cell.theDescription.text = GlobalStruct.pinnedLists[indexPath.row].listItem?.description ?? ""
                    
                    if otherListUser == "" {
                        if GlobalStruct.listName == cell.theTitle.text && !GlobalStruct.inVCFromList {
                            cell.accessoryType = .checkmark
                        } else {
                            cell.accessoryType = .none
                        }
                    }
                    if indexPath.row == allLists.count - 1 {
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
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TopListCell", for: indexPath) as! TrendingFeedCell
                    
                    cell.configureCell(false)
                    cell.theTitle.text = "All Lists"
                    if otherListUser != "" {
                        cell.theAuthor.text = "A list of @\(otherListUser)'s lists"
                    } else {
                        cell.theAuthor.text = "A list of your lists"
                    }
                    
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    cell.accessoryView = nil
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = UIColor.clear
                    cell.selectedBackgroundView = bgColorView
                    cell.backgroundColor = GlobalStruct.backgroundTint
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! FeedCell
                    
                    cell.configureCell(true)
                    if let url = allLists[indexPath.row - 1].avatarImageURL {
                        cell.avatar.sd_setImage(with: url, for: .normal)
                    } else {
                        cell.avatar.setImage(UIImage(), for: .normal)
                    }
                    cell.theTitle.text = allLists[indexPath.row - 1].name
                    cell.theAuthor.text = "by @\(allLists[indexPath.row - 1].creator.actorHandle)"
                    cell.theDescription.text = allLists[indexPath.row - 1].description ?? ""
                    
                    if isFetching == false && currentListCursor != nil {
                        if indexPath.row - 1 == allLists.count - 1 || indexPath.row - 1 == allLists.count - 5 {
                            isFetching = true
                            fetchFeedsOrLists()
                        }
                    }
                    
                    if otherListUser == "" {
                        if GlobalStruct.listName == cell.theTitle.text && !GlobalStruct.inVCFromList {
                            cell.accessoryType = .checkmark
                        } else {
                            cell.accessoryType = .none
                        }
                    }
                    if indexPath.row == allLists.count {
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
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tableView {
            if indexPath.section == 0 {
                if GlobalStruct.pinnedFeeds.isEmpty {
                    
                } else {
                    defaultHaptics()
                    GlobalStruct.listURI = ""
                    GlobalStruct.listName = ""
                    GlobalStruct.currentList = nil
                    GlobalStruct.currentFeedURI = GlobalStruct.pinnedFeeds[indexPath.row].uri
                    GlobalStruct.currentFeedDisplayName = GlobalStruct.pinnedFeeds[indexPath.row].name
                    GlobalStruct.currentFeed = GlobalStruct.pinnedFeeds[indexPath.row].feedItem
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "switchFeed"), object: nil)
                    saveCurrentFeedAndList()
                    tableView.reloadData()
                    dismiss(animated: true)
                }
            } else {
                if indexPath.row != 0 {
                    defaultHaptics()
                    GlobalStruct.listURI = ""
                    GlobalStruct.listName = ""
                    GlobalStruct.currentList = nil
                    if indexPath.row == 1 {
                        GlobalStruct.currentFeedURI = ""
                        GlobalStruct.currentFeedDisplayName = "Following"
                        GlobalStruct.currentFeed = nil
                    } else {
                        GlobalStruct.currentFeedURI = GlobalStruct.allFeeds[indexPath.row - 2].feedURI
                        GlobalStruct.currentFeedDisplayName = GlobalStruct.allFeeds[indexPath.row - 2].displayName
                        GlobalStruct.currentFeed = GlobalStruct.allFeeds[indexPath.row - 2]
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "switchFeed"), object: nil)
                    saveCurrentFeedAndList()
                    tableView.reloadData()
                    dismiss(animated: true)
                }
            }
        } else {
            if indexPath.section == 0 {
                if GlobalStruct.pinnedLists.isEmpty {
                    
                } else {
                    defaultHaptics()
                    let list = self.allLists.first { x in
                        x.name == GlobalStruct.pinnedLists[indexPath.row].name
                    }
                    GlobalStruct.listURI = GlobalStruct.pinnedLists[indexPath.row].uri
                    GlobalStruct.listName = GlobalStruct.pinnedLists[indexPath.row].name
                    GlobalStruct.listDescription = list?.description ?? ""
                    GlobalStruct.currentList = GlobalStruct.pinnedLists[indexPath.row].listItem
                    GlobalStruct.currentFeedURI = ""
                    GlobalStruct.currentFeedDisplayName = ""
                    GlobalStruct.currentFeed = nil
                    if otherListUser == "" && !fromTab {
                        GlobalStruct.inVCFromList = false
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "switchList"), object: nil)
                        saveCurrentFeedAndList()
                        tableView.reloadData()
                    } else {
                        GlobalStruct.inVCFromList = true
                        let vc = ViewController()
                        vc.fromListPush = true
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    dismiss(animated: true)
                }
            } else {
                if indexPath.row != 0 {
                    defaultHaptics()
                    GlobalStruct.listURI = allLists[indexPath.row - 1].uri
                    GlobalStruct.listName = allLists[indexPath.row - 1].name
                    GlobalStruct.listDescription = allLists[indexPath.row - 1].description ?? ""
                    GlobalStruct.currentList = allLists[indexPath.row - 1]
                    GlobalStruct.currentFeedURI = ""
                    GlobalStruct.currentFeedDisplayName = ""
                    GlobalStruct.currentFeed = nil
                    if otherListUser == "" && !fromTab {
                        GlobalStruct.inVCFromList = false
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "switchList"), object: nil)
                        saveCurrentFeedAndList()
                        tableView.reloadData()
                    } else {
                        GlobalStruct.inVCFromList = true
                        let vc = ViewController()
                        vc.fromListPush = true
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    dismiss(animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if tableView == self.tableView {
            return nil
        } else {
            if (indexPath.section == 0 && !GlobalStruct.pinnedLists.isEmpty) || (indexPath.section == 1 && indexPath.row != 0) {
                return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                    if indexPath.section == 0 {
                        let list = self.allLists.first { x in
                            x.name == GlobalStruct.pinnedLists[indexPath.row].name
                        }
                        return createListMenu(GlobalStruct.pinnedLists[indexPath.row].uri, listName: GlobalStruct.pinnedLists[indexPath.row].name, listDescription: list?.description ?? "", listItem: list, fromTab: self.fromTab)
                    } else {
                        return createListMenu(self.allLists[indexPath.row - 1].uri, listName: self.allLists[indexPath.row - 1].name, listDescription: self.allLists[indexPath.row - 1].description ?? "", listItem: self.allLists[indexPath.row - 1], fromTab: self.fromTab)
                    }
                }
            } else {
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == self.tableView {
            if indexPath.section == 0 && !GlobalStruct.pinnedFeeds.isEmpty {
                let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
                    GlobalStruct.pinnedFeeds.remove(at: indexPath.row)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                    self.savePinnedFeedsToDisk()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView.reloadData()
                    }
                    completionHandler(true)
                }
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                let image = UIImage(systemName: "pin.slash.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemRed, renderingMode: .alwaysOriginal) ?? UIImage()
                if let circularImage = createImageWithCircularBackground(icon: image, backgroundColor: .clear, diameter: 40) {
                    pinAction.image = circularImage
                }
                pinAction.backgroundColor = GlobalStruct.backgroundTint
                let configuration = UISwipeActionsConfiguration(actions: [pinAction])
                return configuration
            } else {
                if indexPath.row == 0 || indexPath.row == 1 {
                    return nil
                } else {
                    let contains = GlobalStruct.pinnedFeeds.contains { $0.name == GlobalStruct.allFeeds[indexPath.row - 2].displayName }
                    if contains {
                        let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
                            GlobalStruct.pinnedFeeds = GlobalStruct.pinnedFeeds.filter({ x in
                                x.name != GlobalStruct.allFeeds[indexPath.row - 2].displayName
                            })
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                            self.savePinnedFeedsToDisk()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.tableView.reloadData()
                            }
                            completionHandler(true)
                        }
                        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                        let image = UIImage(systemName: "pin.slash.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemRed, renderingMode: .alwaysOriginal) ?? UIImage()
                        if let circularImage = createImageWithCircularBackground(icon: image, backgroundColor: .clear, diameter: 40) {
                            pinAction.image = circularImage
                        }
                        pinAction.backgroundColor = GlobalStruct.backgroundTint
                        let configuration = UISwipeActionsConfiguration(actions: [pinAction])
                        return configuration
                    } else {
                        let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
                            GlobalStruct.pinnedFeeds.append(PinnedItems(name: GlobalStruct.allFeeds[indexPath.row - 2].displayName, uri: GlobalStruct.allFeeds[indexPath.row - 2].feedURI, feedItem: GlobalStruct.allFeeds[indexPath.row - 2], listItem: nil))
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                            self.savePinnedFeedsToDisk()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.tableView.reloadData()
                            }
                            completionHandler(true)
                        }
                        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                        let image = UIImage(systemName: "pin.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemOrange, renderingMode: .alwaysOriginal) ?? UIImage()
                        if let circularImage = createImageWithCircularBackground(icon: image, backgroundColor: .clear, diameter: 40) {
                            pinAction.image = circularImage
                        }
                        pinAction.backgroundColor = GlobalStruct.backgroundTint
                        let configuration = UISwipeActionsConfiguration(actions: [pinAction])
                        return configuration
                    }
                }
            }
        } else {
            if indexPath.section == 0 && !GlobalStruct.pinnedLists.isEmpty {
                let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
                    GlobalStruct.pinnedLists.remove(at: indexPath.row)
                    if !self.fromTab {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                    }
                    self.savePinnedListsToDisk()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.tableView2.reloadData()
                    }
                    completionHandler(true)
                }
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                let image = UIImage(systemName: "pin.slash.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemRed, renderingMode: .alwaysOriginal) ?? UIImage()
                if let circularImage = createImageWithCircularBackground(icon: image, backgroundColor: .clear, diameter: 40) {
                    pinAction.image = circularImage
                }
                pinAction.backgroundColor = GlobalStruct.backgroundTint
                let configuration = UISwipeActionsConfiguration(actions: [pinAction])
                return configuration
            } else {
                if indexPath.row == 0 {
                    return nil
                } else {
                    let contains = GlobalStruct.pinnedLists.contains { $0.name == self.allLists[indexPath.row - 1].name }
                    if contains {
                        let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
                            GlobalStruct.pinnedLists = GlobalStruct.pinnedLists.filter({ x in
                                x.name != self.allLists[indexPath.row - 1].name
                            })
                            if !self.fromTab {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                            }
                            self.savePinnedListsToDisk()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.tableView2.reloadData()
                            }
                            completionHandler(true)
                        }
                        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                        let image = UIImage(systemName: "pin.slash.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemRed, renderingMode: .alwaysOriginal) ?? UIImage()
                        if let circularImage = createImageWithCircularBackground(icon: image, backgroundColor: .clear, diameter: 40) {
                            pinAction.image = circularImage
                        }
                        pinAction.backgroundColor = GlobalStruct.backgroundTint
                        let configuration = UISwipeActionsConfiguration(actions: [pinAction])
                        return configuration
                    } else {
                        let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
                            GlobalStruct.pinnedLists.append(PinnedItems(name: self.allLists[indexPath.row - 1].name, uri: self.allLists[indexPath.row - 1].uri, feedItem: nil, listItem: self.allLists[indexPath.row - 1]))
                            if !self.fromTab {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                            }
                            self.savePinnedListsToDisk()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.tableView2.reloadData()
                            }
                            completionHandler(true)
                        }
                        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                        let image = UIImage(systemName: "pin.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemOrange, renderingMode: .alwaysOriginal) ?? UIImage()
                        if let circularImage = createImageWithCircularBackground(icon: image, backgroundColor: .clear, diameter: 40) {
                            pinAction.image = circularImage
                        }
                        pinAction.backgroundColor = GlobalStruct.backgroundTint
                        let configuration = UISwipeActionsConfiguration(actions: [pinAction])
                        return configuration
                    }
                }
            }
        }
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
    
}
