//
//  FriendsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 09/03/2025.
//

import UIKit
import ATProtoKit

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var profile: String = ""
    var isShowingFollowers: Bool = true
    var followers: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    var following: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var isMutuals: Bool = false
    var allActivityUsers: [AppBskyLexicon.Actor.ProfileViewBasicDefinition] = []
    
    // lists
    var listName: String = ""
    var listURI: String = ""
    var fromList: Bool = false
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    var searchResultsAlt: [AppBskyLexicon.Actor.ProfileViewBasicDefinition] = []
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
        if allActivityUsers != [] {
            if searchResults.isEmpty {} else {
                allActivityUsers = searchResultsAlt
            }
            if let theText = searchController.searchBar.text?.lowercased() {
                if theText.isEmpty {
                    isSearching = false
                    if searchFirstTime {
                        searchFirstTime = false
                        searchResultsAlt = allActivityUsers
                    } else {
                        allActivityUsers = searchResultsAlt
                        tableView.reloadData()
                    }
                } else {
                    let z = allActivityUsers.filter({
                        return ($0.displayName ?? "").lowercased().contains(theText)
                    })
                    allActivityUsers = z
                    tableView.reloadData()
                    isSearching = true
                }
            }
        } else if isShowingFollowers || isMutuals || fromList {
            if searchResults.isEmpty {} else {
                followers = searchResults
            }
            if let theText = searchController.searchBar.text?.lowercased() {
                if theText.isEmpty {
                    isSearching = false
                    if searchFirstTime {
                        searchFirstTime = false
                        searchResults = followers
                    } else {
                        followers = searchResults
                        tableView.reloadData()
                    }
                } else {
                    let z = followers.filter({
                        return ($0.displayName ?? "").lowercased().contains(theText) || ($0.description ?? "").lowercased().contains(theText)
                    })
                    followers = z
                    tableView.reloadData()
                    isSearching = true
                }
            }
        } else {
            if searchResults.isEmpty {} else {
                following = searchResults
            }
            if let theText = searchController.searchBar.text?.lowercased() {
                if theText.isEmpty {
                    isSearching = false
                    if searchFirstTime {
                        searchFirstTime = false
                        searchResults = following
                    } else {
                        following = searchResults
                        tableView.reloadData()
                    }
                } else {
                    let z = following.filter({
                        return ($0.displayName ?? "").lowercased().contains(theText) || ($0.description ?? "").lowercased().contains(theText)
                    })
                    following = z
                    tableView.reloadData()
                    isSearching = true
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if allActivityUsers != [] {
            isSearching = false
            if !searchResults.isEmpty {
                allActivityUsers = self.searchResultsAlt
                tableView.reloadData()
            }
            searchFirstTime = true
        } else if isShowingFollowers || isMutuals || fromList {
            isSearching = false
            if !searchResults.isEmpty {
                followers = self.searchResults
                tableView.reloadData()
            }
            searchFirstTime = true
        } else {
            isSearching = false
            if !searchResults.isEmpty {
                following = self.searchResults
                tableView.reloadData()
            }
            searchFirstTime = true
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
            let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
            for x in self.tableView.visibleCells {
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
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        if isMutuals {
            navigationItem.title = "Mutuals"
        } else if fromList {
            navigationItem.title = "People"
        } else if allActivityUsers != [] {
            navigationItem.title = "New Followers"
        } else if isShowingFollowers {
            navigationItem.title = "Followers"
        } else {
            navigationItem.title = "Following"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        setUpNavigationBar()
        
        if !isMutuals {
            fetchFriends()
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.isFetching = false
            }
        }
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
    }
    
    func fetchFriends() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    
                    if fromList {
                        let x = try await atProto.getList(from: listURI)
                        followers = x.items.map({ item in
                            item.subject
                        })
                        currentCursor = x.cursor
                    } else if allActivityUsers != [] {
                        
                    } else if isShowingFollowers {
                        let x = try await atProto.getFollowers(by: profile, cursor: currentCursor)
                        followers += x.followers
                        currentCursor = x.cursor
                    } else {
                        let x = try await atProto.getFollows(from: profile, cursor: currentCursor)
                        following += x.follows
                        currentCursor = x.cursor
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.isFetching = false
                    }
                }
            } catch {
                print("Error fetching friends: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isFetching = false
                }
            }
        }
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
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
            if isMutuals {
                controller.searchBar.placeholder = "Search Mutuals"
            } else if fromList {
                controller.searchBar.placeholder = "Search People"
            } else if allActivityUsers != [] {
                controller.searchBar.placeholder = "Search New Followers"
            } else if isShowingFollowers {
                controller.searchBar.placeholder = "Search Followers"
            } else {
                controller.searchBar.placeholder = "Search Following"
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
        if allActivityUsers != [] {
            return allActivityUsers.count
        } else if isShowingFollowers || isMutuals || fromList {
            return followers.count
        } else {
            return following.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        var offsetCount: Int = 0
        if allActivityUsers != [] {
            offsetCount = allActivityUsers.count
            let user: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = allActivityUsers[indexPath.row]
            if let url = user?.avatarImageURL {
                cell.avatar.sd_imageTransition = .fade
                cell.avatar.sd_setImage(with: url, for: .normal)
                cell.avatar.tag = indexPath.row
            } else {
                cell.avatar.setImage(UIImage(), for: .normal)
            }
            cell.username.text = user?.displayName ?? ""
            cell.usertag.text = "@\(user?.actorHandle ?? "")"
            var followsYou: Bool = false
            if let _ = user?.viewer?.followedByURI {
                followsYou = true
            }
            cell.configureCell(followsYou, bioText: "", currentProfile: user)
            if isFetching == false && currentCursor != nil {
                if indexPath.row == offsetCount - 1 || indexPath.row == offsetCount - 5 {
                    isFetching = true
                    fetchFriends()
                }
            }
        } else {
            var user: AppBskyLexicon.Actor.ProfileViewDefinition? = nil
            if isShowingFollowers || isMutuals || fromList {
                user = followers[indexPath.row]
                offsetCount = followers.count
            } else {
                user = following[indexPath.row]
                offsetCount = following.count
            }
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
            var followsYou: Bool = false
            if let _ = user?.viewer?.followedByURI {
                followsYou = true
            }
            cell.configureCell(followsYou, bioText: bioText, defaultProfile: user)
            if isFetching == false && currentCursor != nil {
                if indexPath.row == offsetCount - 1 || indexPath.row == offsetCount - 5 {
                    isFetching = true
                    fetchFriends()
                }
            }
        }
        
        if indexPath.row == offsetCount - 1 {
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
        let vc = ProfileViewController()
        if allActivityUsers != [] {
            vc.profile = allActivityUsers[indexPath.row].actorDID
        } else if isShowingFollowers || isMutuals || fromList {
            vc.profile = followers[indexPath.row].actorDID
        } else {
            vc.profile = following[indexPath.row].actorDID
        }
        navigationController?.pushViewController(vc, animated: true)
        if isSearching {
            searchController.isActive = false
        }
    }
    
}
