//
//  ExploreViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import UIKit
import ATProtoKit

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var tempScrollPosition: CGFloat = 0
    let refreshControl = UIRefreshControl()
    var fetchedAreasCount: Int = 0
    var fromNavigation: Bool = false
    
    // trends
    var trends: [AppBskyLexicon.Unspecced.TrendViewDefinition] = []
    
    // suggested users
    var suggestedUsers: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    var whoToFollow: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    
    // starter packs
    var starterPacks: [AppBskyLexicon.Graph.StarterPackViewBasicDefinition] = []
    var allStarterPacks: [AppBskyLexicon.Graph.StarterPackViewBasicDefinition] = []
    
    // suggested feeds
    var suggestedFeeds: [AppBskyLexicon.Feed.GeneratorViewDefinition] = []
    var feedPosts1: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var feedPosts2: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var feedPosts3: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var feedPosts4: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var feedPosts5: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [AppBskyLexicon.Unspecced.TrendViewDefinition] = []
    var isSearching: Bool = false
    var searchFirstTime: Bool = true
    
    // loading indicator
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView.tableHeaderView?.frame.size.height = 56
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchResults.isEmpty {} else {
            trends = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = trends
                } else {
                    trends = searchResults
                    tableView.reloadData()
                }
            } else {
                let z = trends.filter({
                    return ($0.topic).lowercased().contains(theText)
                })
                trends = z
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            trends = self.searchResults
            tableView.reloadData()
        }
        searchFirstTime = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalStruct.currentTab = 2
    }
    
    @objc func scrollUp() {
        if trends.isEmpty {} else {
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
            let defaultFontSize = UIFont.preferredFont(forTextStyle: .title2).pointSize + 2
            let defaultFontSize2 = UIFont.preferredFont(forTextStyle: .title3).pointSize
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
            let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
            for x in self.tableView.visibleCells {
                if let y = x as? TrendingTopicsCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theSubtitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                if let y = x as? TrendingFeedCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: defaultFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
                if let y = x as? UserCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.usertag.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.followsYouTag.titleLabel?.font = UIFont.systemFont(ofSize: mostSmallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.bio.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
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
                }
                if let y = x as? StarterPackListCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
                    y.theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
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
            self.trends = []
            self.suggestedUsers = []
            self.whoToFollow = []
            self.starterPacks = []
            self.allStarterPacks = []
            self.suggestedFeeds = []
            self.feedPosts1 = []
            self.feedPosts2 = []
            self.feedPosts3 = []
            self.feedPosts4 = []
            self.feedPosts5 = []
            self.fetchTrending()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Explore"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollUp), name: NSNotification.Name(rawValue: "scrollUp2"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetTimelines), name: NSNotification.Name(rawValue: "resetTimelines"), object: nil)
        
        setUpNavigationBar()
        fetchTrending()
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
        
        if !fromNavigation {
            let navigationButton = CustomButton(type: .system)
            navigationButton.setImage(UIImage(systemName: "gear"), for: .normal)
            navigationButton.addTarget(self, action: #selector(self.goToSettings), for: .touchUpInside)
            let navigationBarButtonItem = UIBarButtonItem(customView: navigationButton)
            navigationBarButtonItem.accessibilityLabel = "Settings"
            navigationItem.leftBarButtonItem = navigationBarButtonItem
        }
    }
    
    @objc func fetchTrending() {
        fetchedAreasCount = 0
        guard !isSearching else {
            refreshControl.endRefreshing()
            return
        }
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getTrends(limit: 5)
                    trends = Array(x.trends.prefix(5))
                    fetchedAreasCount += 1
                    DispatchQueue.main.async {
                        if self.fetchedAreasCount == 4 {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            } catch {
                print("Error fetching trending topics: \(error)")
                loadingIndicator.stopAnimating()
                tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getSuggestedFollowsByActor(GlobalStruct.currentUser?.actorHandle ?? "")
                    suggestedUsers = Array(x.suggestions.prefix(5))
                    whoToFollow = x.suggestions
                    fetchedAreasCount += 1
                    DispatchQueue.main.async {
                        if self.fetchedAreasCount == 4 {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            } catch {
                print("Error fetching suggested users: \(error)")
                loadingIndicator.stopAnimating()
                tableView.reloadData()
                refreshControl.endRefreshing()
            }
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getSuggestions()
                    if !whoToFollow.isEmpty {
                        whoToFollow += x.actors
                    }
                    fetchedAreasCount += 1
                    DispatchQueue.main.async {
                        if self.fetchedAreasCount == 4 {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            } catch {
                print("Error fetching more suggested users: \(error)")
                loadingIndicator.stopAnimating()
                tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getStarterPacks(uris: GlobalStruct.starterPacks)
                    starterPacks = Array(x.starterPacks.shuffled().prefix(5))
                    allStarterPacks = x.starterPacks.sorted {
                        let name1 = $0.record.getRecord(ofType: AppBskyLexicon.Graph.StarterpackRecord.self)?.name.lowercased() ?? ""
                        let name2 = $1.record.getRecord(ofType: AppBskyLexicon.Graph.StarterpackRecord.self)?.name.lowercased() ?? ""
                        return name1 < name2
                    }
                    fetchedAreasCount += 1
                    DispatchQueue.main.async {
                        if self.fetchedAreasCount == 4 {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            } catch {
                print("Error fetching starter packs: \(error)")
                loadingIndicator.stopAnimating()
                tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getSuggestedFeeds()
                    suggestedFeeds = x.feeds.filter({ feed in
                        feed.creator.actorHandle != "bsky.app" && feed.creator.actorHandle != "skyfeed.xyz" && feed.creator.actorHandle != "flicknow.xyz" && feed.creator.actorHandle != "jaz.bsky.social" && feed.creator.actorHandle != "furryli.st" && feed.creator.actorHandle != "jcsalterego.bluesky.social" && feed.creator.actorHandle != "bsky.one" && feed.creator.actorHandle != "mayawest.online" && feed.creator.actorHandle != "ealmuina.xyz"
                    })
                    .shuffled()
                    .prefix(5)
                    .map { $0 }
                    DispatchQueue.main.async {
                        if self.fetchedAreasCount == 4 {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                    fetchFeedPosts()
                }
            } catch {
                print("Error fetching suggested feeds: \(error)")
                loadingIndicator.stopAnimating()
                tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchFeedPosts() {
        Task {
            for (index, feed) in suggestedFeeds.enumerated() {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let x = try await atProto.getFeed(by: feed.feedURI, limit: 5)
                        if index == 0 {
                            feedPosts1 = x.feed
                        }
                        if index == 1 {
                            feedPosts2 = x.feed
                        }
                        if index == 2 {
                            feedPosts3 = x.feed
                        }
                        if index == 3 {
                            feedPosts4 = x.feed
                        }
                        if index == 4 {
                            feedPosts5 = x.feed
                        }
                        DispatchQueue.main.async {
                            if self.fetchedAreasCount == 4 {
                                self.loadingIndicator.stopAnimating()
                                self.tableView.reloadData()
                                self.refreshControl.endRefreshing()
                            }
                        }
                    }
                } catch {
                    print("Error fetching feed posts: \(error)")
                    loadingIndicator.stopAnimating()
                    tableView.reloadData()
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc func goToSettings() {
        defaultHaptics()
        let vc = SettingsViewController()
        vc.fromNavigationStack = false
        getTopMostViewController()?.show(SloppySwipingNav(rootViewController: vc), sender: self)
    }
    
    func setUpTable() {
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        tableView.removeFromSuperview()
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(TrendingTopicsCell.self, forCellReuseIdentifier: "TrendingTopicsCell")
        tableView.register(TrendingFeedCell.self, forCellReuseIdentifier: "WhoToFollowCell")
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.register(TrendingFeedCell.self, forCellReuseIdentifier: "StarterPacksCell")
        tableView.register(StarterPackListCell.self, forCellReuseIdentifier: "StarterPackListCell")
        tableView.register(TrendingFeedCell.self, forCellReuseIdentifier: "TrendingFeedCell")
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
        refreshControl.addTarget(self, action: #selector(self.fetchTrending), for: .valueChanged)
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
            controller.searchBar.placeholder = "Search Posts, Users, and Feeds"
            self.definesPresentationContext = true
            searchView.addSubview(controller.searchBar)
            tableView.tableHeaderView = searchView
            return controller
        })()
        view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return trends.count
        } else if section == 1 {
            if suggestedUsers.isEmpty {
                return 0
            } else {
                return suggestedUsers.count + 1
            }
        } else if section == 2 {
            if starterPacks.isEmpty {
                return 0
            } else {
                return starterPacks.count + 1
            }
        } else {
            return suggestedFeeds.count + feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingTopicsCell", for: indexPath) as! TrendingTopicsCell
            
            if indexPath.row == 0 {
                let attachment1 = NSTextAttachment()
                attachment1.image = UIImage(systemName: "flame.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))?.withTintColor(.white, renderingMode: .alwaysOriginal)
                attachment1.bounds = CGRect(x: 0, y: -2.5, width: attachment1.image!.size.width, height: attachment1.image!.size.height)
                let attStringNewLine000 = NSMutableAttributedString()
                let attString00 = NSAttributedString(attachment: attachment1)
                attStringNewLine000.append(attString00)
                let attributedString = NSMutableAttributedString(string: " Hot", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.white])
                attStringNewLine000.append(attributedString)
                cell.theIcon.setAttributedTitle(attStringNewLine000, for: .normal)
                cell.theIcon.backgroundColor = .systemRed
                cell.theIcon.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 7, right: 10)
            } else {
                let attStringNewLine000 = NSMutableAttributedString()
                let timeSince = trends[indexPath.row].startedAt
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = GlobalStruct.dateFormatter
                let attributedString = NSMutableAttributedString(string: "\(timeSince.toStringWithRelativeTime()) ago", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
                attStringNewLine000.append(attributedString)
                cell.theIcon.setAttributedTitle(attStringNewLine000, for: .normal)
                cell.theIcon.backgroundColor = GlobalStruct.groupBG
                cell.theIcon.contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 6, right: 10)
            }
            cell.theIcon.isUserInteractionEnabled = false
            cell.theSubtitle.text = "\(indexPath.row + 1)"
            cell.theTitle.text = trends[indexPath.row].displayName
            cell.theDescription.text = "\(trends[indexPath.row].postCount.formatUsingAbbreviation()) posts • \(trends[indexPath.row].category?.capitalized ?? "")"
            
            if indexPath.row == trends.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
            }
            cell.accessoryView = nil
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WhoToFollowCell", for: indexPath) as! TrendingFeedCell
                
                cell.configureCell(false)
                cell.theTitle.text = "Suggested Accounts"
                cell.theAuthor.text = "Suggestions based on who you follow"
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.backgroundTint
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                
                let user = suggestedUsers[indexPath.row - 1]
                if let url = user.avatarImageURL {
                    cell.avatar.sd_imageTransition = .fade
                    cell.avatar.sd_setImage(with: url, for: .normal)
                    cell.avatar.tag = indexPath.row
                } else {
                    cell.avatar.setImage(UIImage(), for: .normal)
                }
                cell.username.text = user.displayName ?? ""
                cell.usertag.text = "@\(user.actorHandle)"
                let bioText = user.description ?? ""
                var followsYou: Bool = false
                if let _ = user.viewer?.followedByURI {
                    followsYou = true
                }
                cell.configureCell(followsYou, bioText: bioText, defaultProfile: user)
                
                if indexPath.row == suggestedUsers.count {
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
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StarterPacksCell", for: indexPath) as! TrendingFeedCell
                
                cell.configureCell(false)
                cell.theTitle.text = "Starter Packs"
                cell.theAuthor.text = "Suggested starter packs"
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.backgroundTint
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StarterPackListCell", for: indexPath) as! StarterPackListCell
                
                cell.configureCell()
                if let url = starterPacks[indexPath.row - 1].creator.avatarImageURL {
                    cell.avatar.sd_imageTransition = .fade
                    cell.avatar.sd_setImage(with: url, for: .normal)
                } else {
                    cell.avatar.setImage(UIImage(), for: .normal)
                }
                cell.avatar.backgroundColor = .systemBlue
                cell.theAuthor.text = "@\(starterPacks[indexPath.row - 1].creator.actorHandle)"
                if let record = starterPacks[indexPath.row - 1].record.getRecord(ofType: AppBskyLexicon.Graph.StarterpackRecord.self) {
                    cell.theTitle.text = record.name
                    cell.theDescription.text = record.description
                }
                cell.theDescription.numberOfLines = 2
                
                if indexPath.row == starterPacks.count {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                } else {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
                }
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.backgroundTint
                return cell
            }
        } else {
            let headerIndexPathRows: [Int] = [0, feedPosts1.count + 1, feedPosts1.count + feedPosts2.count + 2, feedPosts1.count + feedPosts2.count + feedPosts3.count + 3, feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + 4, feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count + 5]
            
            if headerIndexPathRows.contains(indexPath.row) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrendingFeedCell", for: indexPath) as! TrendingFeedCell
                
                let indexToUse: Int = headerIndexPathRows.firstIndex { x in
                    x == indexPath.row
                } ?? 0
                
                cell.configureCell(false)
                cell.theTitle.text = suggestedFeeds[indexToUse].displayName
                cell.theAuthor.text = "Feed by @\(suggestedFeeds[indexToUse].creator.actorHandle)"
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.backgroundTint
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
                
                if indexPath.row < feedPosts1.count + 1 {
                    if !feedPosts1.isEmpty {
                        let post = feedPosts1[indexPath.row - 1].post
                        configurePostCell(cell, with: post, reason: feedPosts1[indexPath.row - 1].reason)
                    }
                    if indexPath.row == feedPosts1.count {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    } else {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
                    }
                } else if indexPath.row < feedPosts1.count + feedPosts2.count + 2 {
                    if !feedPosts2.isEmpty {
                        let post = feedPosts2[indexPath.row - feedPosts1.count - 2].post
                        configurePostCell(cell, with: post, reason: feedPosts2[indexPath.row - feedPosts1.count - 2].reason)
                    }
                    if indexPath.row == feedPosts1.count + feedPosts2.count + 1 {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    } else {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
                    }
                } else if indexPath.row < feedPosts1.count + feedPosts2.count + feedPosts3.count + 3 {
                    if !feedPosts3.isEmpty {
                        let post = feedPosts3[indexPath.row - feedPosts1.count - feedPosts2.count - 3].post
                        configurePostCell(cell, with: post, reason: feedPosts3[indexPath.row - feedPosts1.count - feedPosts2.count - 3].reason)
                    }
                    if indexPath.row == feedPosts1.count + feedPosts2.count + feedPosts3.count + 2 {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    } else {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
                    }
                } else if indexPath.row < feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + 4 {
                    if !feedPosts4.isEmpty {
                        let post = feedPosts4[indexPath.row - feedPosts1.count - feedPosts2.count - feedPosts3.count - 4].post
                        configurePostCell(cell, with: post, reason: feedPosts4[indexPath.row - feedPosts1.count - feedPosts2.count - feedPosts3.count - 4].reason)
                    }
                    if indexPath.row == feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + 3 {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    } else {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
                    }
                } else if indexPath.row < feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count + 5 {
                    if !feedPosts5.isEmpty {
                        let post = feedPosts5[indexPath.row - feedPosts1.count - feedPosts2.count - feedPosts3.count - feedPosts4.count - 5].post
                        configurePostCell(cell, with: post, reason: feedPosts5[indexPath.row - feedPosts1.count - feedPosts2.count - feedPosts3.count - feedPosts4.count - 5].reason)
                    }
                    if indexPath.row == feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count + 4 {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    } else {
                        cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
                    }
                } else {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
                }
                
                cell.avatar.tag = indexPath.row
                cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
                cell.repost.tag = indexPath.row
                cell.repost.addTarget(self, action: #selector(repostTapped(_:)), for: .touchUpInside)
                
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.backgroundTint
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let rkey: String = "\(trends[indexPath.row].link.split(separator: "/").last ?? "")"
            GlobalStruct.listURI = ""
            GlobalStruct.listName = ""
            GlobalStruct.currentList = nil
            GlobalStruct.currentFeed = nil
            let vc = ViewController()
            vc.fromFeedPush = true
            vc.currentFeedURI = "at://did:plc:qrz3lhbyuxbeilrc6nekdqme/app.bsky.feed.generator/\(rkey)"
            vc.currentFeedDisplayName = trends[indexPath.row].displayName
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let vc = SuggestedAccountsViewController()
                vc.whoToFollow = whoToFollow
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = ProfileViewController()
                vc.profile = suggestedUsers[indexPath.row - 1].actorDID
                navigationController?.pushViewController(vc, animated: true)
                if isSearching {
                    searchController.isActive = false
                }
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let vc = AllStarterPacksViewController()
                vc.starterPacks = allStarterPacks
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = StarterPackViewController()
                vc.showingMembers = true
                if let record = starterPacks[indexPath.row - 1].record.getRecord(ofType: AppBskyLexicon.Graph.StarterpackRecord.self) {
                    vc.starterPackURI = record.listURI
                    vc.starterPackDisplayName = record.name
                    vc.starterPack = starterPacks[indexPath.row - 1]
                }
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let headerIndexPathRows: [Int] = [0, feedPosts1.count + 1, feedPosts1.count + feedPosts2.count + 2, feedPosts1.count + feedPosts2.count + feedPosts3.count + 3, feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + 4, feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count + 5]
            if headerIndexPathRows.contains(indexPath.row) {
                let indexToUse: Int = headerIndexPathRows.firstIndex { x in
                    x == indexPath.row
                } ?? 0
                GlobalStruct.listURI = ""
                GlobalStruct.listName = ""
                GlobalStruct.currentList = nil
                GlobalStruct.currentFeed = suggestedFeeds[indexToUse]
                let vc = ViewController()
                vc.fromFeedPush = true
                vc.currentFeedURI = suggestedFeeds[indexToUse].feedURI
                vc.currentFeedDisplayName = suggestedFeeds[indexToUse].displayName
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = DetailsViewController()
                if indexPath.row < feedPosts1.count + 1 {
                    vc.detailPost = feedPosts1[indexPath.row - 1].post
                } else if indexPath.row < feedPosts1.count + feedPosts2.count + 2 {
                    vc.detailPost = feedPosts2[indexPath.row - feedPosts1.count - 2].post
                } else if indexPath.row < feedPosts1.count + feedPosts2.count + feedPosts3.count + 3 {
                    vc.detailPost = feedPosts3[indexPath.row - feedPosts1.count - feedPosts2.count - 3].post
                } else if indexPath.row < feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + 4 {
                    vc.detailPost = feedPosts4[indexPath.row - feedPosts1.count - feedPosts2.count - feedPosts3.count - 4].post
                } else if indexPath.row < feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count + 5 {
                    vc.detailPost = feedPosts5[indexPath.row - feedPosts1.count - feedPosts2.count - feedPosts3.count - feedPosts4.count - 5].post
                }
                navigationController?.pushViewController(vc, animated: true)
                if isSearching {
                    searchController.isActive = false
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section > 2 {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                if indexPath.row < self.feedPosts1.count + 1 {
                    return makePostContextMenu(indexPath.row - 1, post: self.feedPosts1[indexPath.row - 1].post)
                } else if indexPath.row < self.feedPosts1.count + self.feedPosts2.count + 2 {
                    return makePostContextMenu(indexPath.row - self.feedPosts1.count - 2, post: self.feedPosts2[indexPath.row - self.feedPosts1.count - 2].post)
                } else if indexPath.row < self.feedPosts1.count + self.feedPosts2.count + self.feedPosts3.count + 3 {
                    return makePostContextMenu(indexPath.row - self.feedPosts1.count - self.feedPosts2.count - 3, post: self.feedPosts3[indexPath.row - self.feedPosts1.count - self.feedPosts2.count - 3].post)
                } else if indexPath.row < self.feedPosts1.count + self.feedPosts2.count + self.feedPosts3.count + self.feedPosts4.count + 4 {
                    return makePostContextMenu(indexPath.row - self.feedPosts1.count - self.feedPosts2.count - self.feedPosts3.count - 4, post: self.feedPosts4[indexPath.row - self.feedPosts1.count - self.feedPosts2.count - self.feedPosts3.count - 4].post)
                } else if indexPath.row < self.feedPosts1.count + self.feedPosts2.count + self.feedPosts3.count + self.feedPosts4.count + self.feedPosts5.count + 5 {
                    return makePostContextMenu(indexPath.row - self.feedPosts1.count - self.feedPosts2.count - self.feedPosts3.count - self.feedPosts4.count - 5, post: self.feedPosts5[indexPath.row - self.feedPosts1.count - self.feedPosts2.count - self.feedPosts3.count - self.feedPosts4.count - 5].post)
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
    }
    
    @objc func profileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        if sender.tag < feedPosts1.count + 1 {
            vc.profile = feedPosts1[sender.tag - 1].post.author.actorDID
        } else if sender.tag < feedPosts1.count + feedPosts2.count + 2 {
            vc.profile = feedPosts2[sender.tag - feedPosts1.count - 2].post.author.actorDID
        } else if sender.tag < feedPosts1.count + feedPosts2.count + feedPosts3.count + 3 {
            vc.profile = feedPosts3[sender.tag - feedPosts1.count - feedPosts2.count - 3].post.author.actorDID
        } else if sender.tag < feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + 4 {
            vc.profile = feedPosts4[sender.tag - feedPosts1.count - feedPosts2.count - feedPosts3.count - 4].post.author.actorDID
        } else if sender.tag < feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count + 5 {
            vc.profile = feedPosts5[sender.tag - feedPosts1.count - feedPosts2.count - feedPosts3.count - feedPosts4.count - 5].post.author.actorDID
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func repostTapped(_ sender: UIButton) {
        defaultHaptics()
        if sender.tag < feedPosts1.count + 1 {
            if let reason = feedPosts1[sender.tag - 1].reason {
                switch reason {
                case .reasonRepost(let repost):
                    let vc = ProfileViewController()
                    vc.profile = repost.by.actorDID
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }
        } else if sender.tag < feedPosts1.count + feedPosts2.count + 2 {
            if let reason = feedPosts2[sender.tag - feedPosts1.count - 2].reason {
                switch reason {
                case .reasonRepost(let repost):
                    let vc = ProfileViewController()
                    vc.profile = repost.by.actorDID
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }
        } else if sender.tag < feedPosts1.count + feedPosts2.count + feedPosts3.count + 3 {
            if let reason = feedPosts3[sender.tag - feedPosts1.count - feedPosts2.count - 3].reason {
                switch reason {
                case .reasonRepost(let repost):
                    let vc = ProfileViewController()
                    vc.profile = repost.by.actorDID
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }
        } else if sender.tag < feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + 4 {
            if let reason = feedPosts4[sender.tag - feedPosts1.count - feedPosts2.count - feedPosts3.count - 4].reason {
                switch reason {
                case .reasonRepost(let repost):
                    let vc = ProfileViewController()
                    vc.profile = repost.by.actorDID
                    navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }
        } else if sender.tag < feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count + 5 {
            if let reason = feedPosts5[sender.tag - feedPosts1.count - feedPosts2.count - feedPosts3.count - feedPosts4.count - 5].reason {
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section > 2 {
            let headerIndexPathRows: [Int] = [0, feedPosts1.count + 1, feedPosts1.count + feedPosts2.count + 2, feedPosts1.count + feedPosts2.count + feedPosts3.count + 3, feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + 4, feedPosts1.count + feedPosts2.count + feedPosts3.count + feedPosts4.count + feedPosts5.count + 5]
            if headerIndexPathRows.contains(indexPath.row) {
                let indexToUse: Int = headerIndexPathRows.firstIndex { x in
                    x == indexPath.row
                } ?? 0
                let contains = GlobalStruct.pinnedFeeds.contains { $0.name == self.suggestedFeeds[indexToUse].displayName }
                if contains {
                    let pinAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
                        GlobalStruct.pinnedFeeds = GlobalStruct.pinnedFeeds.filter({ x in
                            x.name != self.suggestedFeeds[indexToUse].displayName
                        })
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                        self.savePinnedFeedsToDisk()
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
                        GlobalStruct.pinnedFeeds.append(PinnedItems(name: self.suggestedFeeds[indexToUse].displayName, uri: self.suggestedFeeds[indexToUse].feedURI, feedItem: self.suggestedFeeds[indexToUse], listItem: nil))
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "setupListDropdown"), object: nil)
                        self.savePinnedFeedsToDisk()
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
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func savePinnedFeedsToDisk() {
        do {
            try Disk.save(GlobalStruct.pinnedFeeds, to: .documents, as: "pinnedFeeds")
        } catch {
            print("error saving to Disk")
        }
    }
    
}
