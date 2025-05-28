//
//  StarterPackViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 22/04/2025.
//

import UIKit
import ATProtoKit

class StarterPackViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var allMembers: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    var allPosts: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var showingMembers: Bool = true
    var starterPackURI: String = ""
    var starterPackDisplayName: String = ""
    var starterPack: AppBskyLexicon.Graph.StarterPackViewBasicDefinition? = nil
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    var searchResults2: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
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
        if showingMembers {
            if searchResults.isEmpty {} else {
                allMembers = searchResults
            }
            if let theText = searchController.searchBar.text?.lowercased() {
                if theText.isEmpty {
                    isSearching = false
                    if searchFirstTime {
                        searchFirstTime = false
                        searchResults = allMembers
                    } else {
                        allMembers = searchResults
                        tableView.reloadData()
                    }
                } else {
                    let z = allMembers.filter({
                        return ($0.displayName ?? "").lowercased().contains(theText) || ($0.description ?? "").lowercased().contains(theText)
                    })
                    allMembers = z
                    tableView.reloadData()
                    isSearching = true
                }
            }
        } else {
            if searchResults2.isEmpty {} else {
                allPosts = searchResults2
            }
            if let theText = searchController.searchBar.text?.lowercased() {
                if theText.isEmpty {
                    isSearching = false
                    if searchFirstTime {
                        searchFirstTime = false
                        searchResults2 = allPosts
                    } else {
                        allPosts = searchResults2
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
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            allMembers = self.searchResults
            allPosts = self.searchResults2
            tableView.reloadData()
        }
        searchFirstTime = true
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
            let defaultFontSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
            let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
            for x in self.tableView.visibleCells {
                if let y = x as? StarterPackHeaderCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: defaultFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.followAllButton.backgroundColor = GlobalStruct.baseTint
                }
                if let y = x as? StarterPackListCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .semibold)
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
        if showingMembers {
            navigationItem.title = "Members"
        } else {
            navigationItem.title = "Posts"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        setUpNavigationBar()
        fetchStarterPack()
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
        setupListDropdown()
    }
    
    @objc func setupListDropdown() {
        var theTitle: String = ""
        if showingMembers {
            theTitle = "Members"
        } else {
            theTitle = "Posts"
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
        let menuItem = UIAction(title: "Members", image: UIImage(systemName: "person.2"), identifier: nil) { [weak self] action in
            guard let self else { return }
            self.showingMembers = true
            self.fetchStarterPack()
            self.setUpTable()
            self.setUpNavigationBar()
        }
        if showingMembers {
            menuItem.state = .on
        } else {
            menuItem.state = .off
        }
        allActions0.append(menuItem)
        let menuItem1 = UIAction(title: "Posts", image: UIImage(systemName: "heart.text.square"), identifier: nil) { [weak self] action in
            guard let self else { return }
            self.showingMembers = false
            self.fetchStarterPack()
            self.setUpTable()
            self.setUpNavigationBar()
        }
        if showingMembers {
            menuItem1.state = .off
        } else {
            menuItem1.state = .on
        }
        allActions0.append(menuItem1)
        let menu = UIMenu(title: "", options: [.displayInline], children: allActions0)
        titleLabel.menu = menu
        titleLabel.showsMenuAsPrimaryAction = true
    }
    
    func fetchStarterPack() {
        if showingMembers {
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let x = try await atProto.getList(from: starterPackURI)
                        allMembers = x.items.map({ item in
                            item.subject
                        })
                        currentCursor = x.cursor
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.isFetching = false
                        }
                    }
                } catch {
                    print("Error fetching starter pack members: \(error)")
                    DispatchQueue.main.async {
                        self.isFetching = false
                    }
                }
            }
        } else {
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let x = try await atProto.getListFeed(from: starterPackURI)
                        allPosts += x.feed
                        currentCursor = x.cursor
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.isFetching = false
                        }
                    }
                } catch {
                    print("Error fetching starter pack posts: \(error)")
                    DispatchQueue.main.async {
                        self.isFetching = false
                    }
                }
            }
        }
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(StarterPackHeaderCell.self, forCellReuseIdentifier: "StarterPackHeaderCell")
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.register(PostsCell.self, forCellReuseIdentifier: "PostsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
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
            if showingMembers {
                controller.searchBar.placeholder = "Search Members"
            } else {
                controller.searchBar.placeholder = "Search Posts"
            }
            self.definesPresentationContext = true
            searchView.addSubview(controller.searchBar)
            tableView.tableHeaderView = searchView
            return controller
        })()
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showingMembers {
            return allMembers.count + 1
        } else {
            return allPosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showingMembers {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StarterPackHeaderCell", for: indexPath) as! StarterPackHeaderCell
                
                if let starterPack = starterPack {
                    cell.configureCell()
                    if let url = starterPack.creator.avatarImageURL {
                        cell.avatar.sd_imageTransition = .fade
                        cell.avatar.sd_setImage(with: url, for: .normal)
                    } else {
                        cell.avatar.setImage(UIImage(), for: .normal)
                    }
                    cell.avatar.backgroundColor = .systemBlue
                    cell.theAuthor.text = "@\(starterPack.creator.actorHandle)"
                    if let record = starterPack.record.getRecord(ofType: AppBskyLexicon.Graph.StarterpackRecord.self) {
                        cell.theTitle.text = record.name
                        cell.theDescription.text = record.description ?? "View all starter pack members below"
                    }
                    
                    let personCount = starterPack.joinedAllTimeCount ?? 0
                    var personText: String = ""
                    if personCount == 0 {
                        personText = "start using"
                    } else if personCount == 1 {
                        personText = "1 person has used"
                    } else {
                        personText = "\(starterPack.joinedAllTimeCount ?? 0) people have used"
                    }
                    let attachment1 = NSTextAttachment()
                    let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize + GlobalStruct.customTextSize, weight: .regular)
                    let downImage1 = UIImage(systemName: "figure.2.arms.open", withConfiguration: symbolConfig1)
                    let downImage2 = imageWithImage(image: downImage1 ?? UIImage(), scaledToSize: CGSize(width: downImage1?.size.width ?? 0, height: (downImage1?.size.height ?? 0) - 3))
                    attachment1.image = downImage2.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
                    attachment1.bounds = CGRect(x: 0, y: -3, width: downImage2.size.width, height: downImage2.size.height)
                    let attStringNewLine000 = NSMutableAttributedString()
                    let attStringNewLine00 = NSMutableAttributedString(string: " \(personText) this starter pack", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize + GlobalStruct.customTextSize, weight: .regular),NSAttributedString.Key.foregroundColor : GlobalStruct.secondaryTextColor])
                    let attString00 = NSAttributedString(attachment: attachment1)
                    attStringNewLine000.append(attString00)
                    attStringNewLine000.append(attStringNewLine00)
                    
                    cell.followAllButton.addTarget(self, action: #selector(followAllTapped(_:)), for: .touchUpInside)
                    cell.shareButton.addTarget(self, action: #selector(shareTapped(_:)), for: .touchUpInside)
                }
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = GlobalStruct.backgroundTint
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                
                let user: AppBskyLexicon.Actor.ProfileViewDefinition? = allMembers[indexPath.row - 1]
                if let url = user?.avatarImageURL {
                    cell.avatar.sd_imageTransition = .fade
                    cell.avatar.sd_setImage(with: url, for: .normal)
                    cell.avatar.tag = indexPath.row - 1
                } else {
                    cell.avatar.setImage(UIImage(), for: .normal)
                }
                cell.username.text = user?.displayName ?? ""
                cell.usertag.text = "@\(user?.actorHandle ?? "")"
                let bioText = user?.description ?? ""
                var followsYou: Bool = false
                if let _ = user?.viewer?.followedByURI {
                    followsYou = true
                }
                cell.configureCell(followsYou, bioText: bioText, defaultProfile: user)
                
                if indexPath.row == allMembers.count {
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
                        fetchStarterPack()
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if showingMembers {
            if indexPath.row > 0 {
                let vc = ProfileViewController()
                vc.profile = allMembers[indexPath.row - 1].actorDID
                navigationController?.pushViewController(vc, animated: true)
                if isSearching {
                    searchController.isActive = false
                }
            }
        } else {
            let vc = DetailsViewController()
            vc.detailPost = allPosts[indexPath.row].post
            navigationController?.pushViewController(vc, animated: true)
            if isSearching {
                searchController.isActive = false
            }
        }
    }
    
    @objc func followAllTapped(_ sender: UIButton) {
        defaultHaptics()
//        for actor in allMembers {
//            Task {
//                do {
//                    if let atProto = GlobalStruct.atProto {
//                        let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
//                        _ = try await atProtoBluesky.createFollowRecord(actorDID: actor.actorDID)
//                        DispatchQueue.main.async {
//                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProfileHeader"), object: nil)
//                        }
//                    }
//                } catch {
//                    print("Error following user: \(error)")
//                }
//            }
//        }
    }
    
    @objc func shareTapped(_ sender: UIButton) {
        defaultHaptics()
        let trimmedURI = (starterPack?.uri ?? "").replacingOccurrences(of: "at://", with: "").split(separator: "/")
        let did = "\(trimmedURI.first ?? "")"
        let key = "\(trimmedURI.last ?? "")"
        let link = "https://bsky.app/starter-pack/\(did)/\(key)"
        if let text = URL(string: link) {
            let textToShare = [text]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = getTopMostViewController()?.view
            activityViewController.popoverPresentationController?.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
            getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
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
