//
//  ProfileViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import UIKit
import ATProtoKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKPhotoBrowserDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var tempScrollPosition: CGFloat = 0
    let refreshControl = UIRefreshControl()
    var fromTab: Bool = false
    var profile: String = ""
    var currentProfile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = nil
    var allPosts: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var mutuals: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var isSearching: Bool = false
    var searchFirstTime: Bool = true
    
    // loading indicator
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileHeaderCell {
            cell.avatar.layer.borderColor = GlobalStruct.detailQuoteCell.cgColor
            cell.avatar1.layer.borderColor = GlobalStruct.detailQuoteCell.cgColor
            cell.avatar2.layer.borderColor = GlobalStruct.detailQuoteCell.cgColor
            cell.avatar3.layer.borderColor = GlobalStruct.detailQuoteCell.cgColor
            cell.bgView.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
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
        GlobalStruct.currentTab = 4
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
    
    @objc func scrollToProfilePosts() {
        DispatchQueue.main.async {
            if self.allPosts.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
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
            let biggestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize + 6
            let biggerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize + 4
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
            let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
            for x in self.tableView.visibleCells {
                if let y = x as? ProfileHeaderCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.username.font = UIFont.systemFont(ofSize: biggestFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.usertag.titleLabel?.font = UIFont.systemFont(ofSize: biggerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.followsYouTag.titleLabel?.font = UIFont.systemFont(ofSize: mostSmallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.bio.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.joinedDate.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.bio.mentionColor = GlobalStruct.baseTint
                    y.bio.hashtagColor = GlobalStruct.baseTint
                    y.bio.URLColor = GlobalStruct.baseTint
                    y.bio.emailColor = GlobalStruct.baseTint
                    y.bio.lineSpacing = GlobalStruct.customLineSize
                    y.bio.numberOfLines = GlobalStruct.maxLines
                    if let text = y.bio.text {
                        y.bio.text = nil
                        y.bio.text = text
                    }
                    y.followsYouTag.backgroundColor = GlobalStruct.baseTint
                    y.followingButton.backgroundColor = GlobalStruct.baseTint
                }
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
    
    @objc func resetTimelines() {
        DispatchQueue.main.async {
            self.allPosts = []
            self.mutuals = []
            self.fetchTimeline()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Profile"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollUp), name: NSNotification.Name(rawValue: "scrollUp4"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAvatarView), name: Notification.Name("showAvatarView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProfileHeader), name: Notification.Name("updateProfileHeader"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollToProfilePosts), name: Notification.Name("scrollToProfilePosts"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetTimelines), name: NSNotification.Name(rawValue: "resetTimelines"), object: nil)
        
        setUpNavigationBar()
        
        fetchTimeline()
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
        
        if profile == "" {
            let navigationButton = CustomButton(type: .system)
            navigationButton.setImage(UIImage(systemName: "gear"), for: .normal)
            navigationButton.addTarget(self, action: #selector(self.goToSettings), for: .touchUpInside)
            let navigationBarButtonItem = UIBarButtonItem(customView: navigationButton)
            navigationBarButtonItem.accessibilityLabel = "Settings"
            navigationItem.leftBarButtonItem = navigationBarButtonItem
        }
    }
    
    @objc func goToSettings() {
        defaultHaptics()
        let vc = SettingsViewController()
        vc.fromNavigationStack = false
        getTopMostViewController()?.show(SloppySwipingNav(rootViewController: vc), sender: self)
    }
    
    @objc func updateProfileHeader() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    currentProfile = try await atProto.getProfile(for: profile)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Error updating profile header: \(error)")
            }
        }
    }
    
    func fetchTimeline() {
        Task {
            let user = GlobalStruct.allUsers.first { x in
                x.username == GlobalStruct.currentSelectedUser
            }
            do {
                if let atProto = GlobalStruct.atProto {
                    if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {
                        if GlobalStruct.currentUser == nil {
                            GlobalStruct.currentUser = try await atProto.getProfile(for: user?.username ?? "")
                            tableView.reloadData()
                        }
                        let x = try await atProto.getAuthorFeed(by: GlobalStruct.currentUser?.actorDID ?? "", limit: nil, cursor: currentCursor, shouldIncludePins: true)
                        allPosts += x.feed.filter({ post in
                            post.reply == nil
                        })
                        currentCursor = x.cursor
                        DispatchQueue.main.async {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                            self.isFetching = false
                        }
                    } else {
                        currentProfile = try await atProto.getProfile(for: profile)
                        fetchMutuals()
                        let x = try await atProto.getAuthorFeed(by: profile, limit: nil, cursor: currentCursor, shouldIncludePins: true)
                        allPosts += x.feed.filter({ post in
                            post.reply == nil
                        })
                        currentCursor = x.cursor
                        DispatchQueue.main.async {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                            self.isFetching = false
                        }
                    }
                }
            } catch {
                print("Error fetching profiles and feed: \(error)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.isFetching = false
                }
            }
        }
    }
    
    @objc func fetchLatest() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    var user: String = ""
                    if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {
                        user = GlobalStruct.currentUser?.actorDID ?? ""
                    } else {
                        user = profile
                    }
                    let x = try await atProto.getAuthorFeed(by: user, limit: nil)
                    allPosts = x.feed.filter({ post in
                        post.reply == nil
                    }) + allPosts
                    if let pinned = allPosts.first(where: { post in
                        if let pinned = post.reason {
                            switch pinned {
                            case .reasonPin( _):
                                return true
                            default:
                                return false
                            }
                        } else {
                            return false
                        }
                    }) {
                        allPosts = allPosts.filter({ post in
                            post.id != pinned.id
                        })
                        allPosts = [pinned] + allPosts
                    }
                    allPosts = allPosts.removingDuplicates()
                    tableView.reloadData()
                    refreshControl.endRefreshing()
                }
            } catch {
                print("Error fetching feed: \(error)")
                refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func fetchMutuals() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getKnownFollowers(from: currentProfile?.actorHandle ?? "")
                    mutuals = x.followers
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Error fetching mutuals: \(error)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
        tableView.register(ProfileHeaderCell.self, forCellReuseIdentifier: "ProfileHeaderCell")
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
            controller.searchBar.placeholder = "Search Profile"
            self.definesPresentationContext = true
            searchView.addSubview(controller.searchBar)
            tableView.tableHeaderView = searchView
            return controller
        })()
        view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isSearching {
                return 0
            } else {
                return 1
            }
        } else {
            return allPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentUser: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = GlobalStruct.currentUser
        if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {} else {
            currentUser = currentProfile
        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderCell", for: indexPath) as! ProfileHeaderCell
            if let currentAccount = currentUser {
                if let url = currentAccount.avatarImageURL {
                    cell.avatar.sd_imageTransition = .fade
                    cell.avatar.sd_setImage(with: url, for: .normal)
                    cell.avatar.tag = indexPath.row
                    cell.avatar.addTarget(self, action: #selector(expandAvatar(_:)), for: .touchUpInside)
                }
                if let url = currentAccount.bannerImageURL {
                    cell.headerImage.sd_imageTransition = .fade
                    cell.headerImage.sd_setImage(with: url, for: .normal)
                    cell.headerImage.tag = indexPath.row
                    cell.headerImage.addTarget(self, action: #selector(self.expandHeader(_:)), for: .touchUpInside)
                }
                
                cell.username.text = currentAccount.displayName ?? ""
                cell.usertag.setTitle("@\(currentAccount.actorHandle)", for: .normal)
                cell.bio.text = currentAccount.description ?? ""
                
                let joinedOn = currentAccount.createdAt
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = GlobalStruct.dateFormatter
                let joinedDate = joinedOn?.toString(dateStyle: .short, timeStyle: .none) ?? ""
                let joinedTime = joinedOn?.toString(dateStyle: .none, timeStyle: .short) ?? ""
                cell.joinedDate.text = "Joined on \(joinedDate) at \(joinedTime)"
                
                var followsYou: Bool = false
                var currentUser: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = nil
                if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {
                    cell.moreButton.alpha = 0
                    cell.followingButton.alpha = 0
                    cell.currentProfile = GlobalStruct.currentUser
                    currentUser = GlobalStruct.currentUser
                } else {
                    cell.moreButton.alpha = 1
                    cell.followingButton.alpha = 1
                    cell.currentProfile = currentProfile
                    currentUser = currentProfile
                    if let _ = currentProfile?.viewer?.followedByURI {
                        followsYou = true
                    }
                }
                if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {
                    cell.moreButton.alpha = 1
                }
                cell.configure(followersCount: "\((currentAccount.followerCount ?? 0).formatUsingAbbreviation())", followingCount: "\((currentAccount.followCount ?? 0).formatUsingAbbreviation())", postsCount: currentAccount.postCount?.formatUsingAbbreviation() ?? "0", followsYou: followsYou, following: currentProfile?.viewer?.followingURI, currentProfile: currentUser, mutuals: mutuals)
            }
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            cell.hoverStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
            let post = allPosts[indexPath.row].post
            
            configurePostCell(cell, with: post, reason: allPosts[indexPath.row].reason)
            
            cell.avatar.tag = indexPath.row
            cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
            cell.repost.tag = indexPath.row
            cell.repost.addTarget(self, action: #selector(repostTapped(_:)), for: .touchUpInside)
            
            if isFetching == false && currentCursor != nil {
                if indexPath.row == allPosts.count - 1 || indexPath.row == allPosts.count - 5 {
                    isFetching = true
                    fetchTimeline()
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let vc = DetailsViewController()
            vc.detailPost = allPosts[indexPath.row].post
            navigationController?.pushViewController(vc, animated: true)
        }
        if isSearching {
            searchController.isActive = false
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == 1 {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                return makePostContextMenu(indexPath.row, post: self.allPosts[indexPath.row].post, reason: self.allPosts[indexPath.row].reason)
            }
        } else {
            return nil
        }
    }
    
    @objc func profileTapped(_ sender: UIButton) {
        var idCheck: String = ""
        if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {
            idCheck = GlobalStruct.currentUser?.actorDID ?? ""
        } else {
            idCheck = currentProfile?.actorDID ?? ""
        }
        if allPosts[sender.tag].post.author.actorDID != idCheck {
            defaultHaptics()
            let vc = ProfileViewController()
            vc.profile = allPosts[sender.tag].post.author.actorDID
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func repostTapped(_ sender: UIButton) {
        var idCheck: String = ""
        if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {
            idCheck = GlobalStruct.currentUser?.actorDID ?? ""
        } else {
            idCheck = currentProfile?.actorDID ?? ""
        }
        if let reason = allPosts[sender.tag].reason {
            switch reason {
            case .reasonRepost(let repost):
                if repost.by.actorDID != idCheck {
                    defaultHaptics()
                    let vc = ProfileViewController()
                    vc.profile = repost.by.actorDID
                    navigationController?.pushViewController(vc, animated: true)
                }
            default:
                break
            }
        }
    }
    
    @objc func expandAvatar(_ sender: UIButton) {
        defaultHaptics()
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileHeaderCell {
            var currentUser: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = GlobalStruct.currentUser
            if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {} else {
                currentUser = currentProfile
            }
            if let avatar = currentUser?.avatarImageURL {
                GlobalStruct.mediaBrowserRadiusType = 1
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImageURL(avatar.absoluteString)
                photo.shouldCachePhotoURLImage = true
                photo.contentMode = .scaleAspectFill
                images.append(photo)
                let originImage = cell.avatar.imageView?.image ?? UIImage()
                let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell.avatar, imageText: "", imageText2: 0, imageText3: 0, imageText4: "")
                browser.delegate = self
                SKPhotoBrowserOptions.enableSingleTapDismiss = false
                SKPhotoBrowserOptions.displayCounterLabel = false
                SKPhotoBrowserOptions.displayBackAndForwardButton = false
                SKPhotoBrowserOptions.displayAction = false
                SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
                SKPhotoBrowserOptions.displayVerticalScrollIndicator = false
                SKPhotoBrowserOptions.displayCloseButton = false
                SKPhotoBrowserOptions.displayStatusbar = false
                browser.initializePageIndex(0)
                getTopMostViewController()?.present(browser, animated: true, completion: {})
            }
        }
    }
    
    @objc func expandHeader(_ sender: UIButton) {
        defaultHaptics()
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileHeaderCell {
            var currentUser: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = GlobalStruct.currentUser
            if profile == "" || profile == GlobalStruct.currentUser?.actorDID ?? "" {} else {
                currentUser = currentProfile
            }
            UIView.animate(withDuration: 0.12, delay: 0.0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0.02, options: [.curveEaseInOut], animations: {
                cell.avatar.alpha = 0
            })
            GlobalStruct.fromHeaderTap = true
            if let header = currentUser?.bannerImageURL {
                GlobalStruct.mediaBrowserRadiusType = 2
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImageURL(header.absoluteString)
                photo.shouldCachePhotoURLImage = true
                photo.contentMode = .scaleAspectFill
                images.append(photo)
                let originImage = cell.headerImage.imageView?.image ?? UIImage()
                let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: cell.headerImage, imageText: "", imageText2: 0, imageText3: 0, imageText4: "")
                browser.delegate = self
                SKPhotoBrowserOptions.enableSingleTapDismiss = false
                SKPhotoBrowserOptions.displayCounterLabel = false
                SKPhotoBrowserOptions.displayBackAndForwardButton = false
                SKPhotoBrowserOptions.displayAction = false
                SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
                SKPhotoBrowserOptions.displayVerticalScrollIndicator = false
                SKPhotoBrowserOptions.displayCloseButton = false
                SKPhotoBrowserOptions.displayStatusbar = false
                browser.initializePageIndex(0)
                getTopMostViewController()?.present(browser, animated: true, completion: {})
            }
        }
    }
    
    @objc func showAvatarView() {
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileHeaderCell {
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0.02, options: [.curveEaseInOut], animations: {
                    cell.avatar.alpha = 1
                })
            }
        }
    }

}

