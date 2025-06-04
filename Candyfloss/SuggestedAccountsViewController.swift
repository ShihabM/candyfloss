//
//  SuggestedAccountsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 18/04/2025.
//

import UIKit
import ATProtoKit

class SuggestedAccountsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var whoToFollow: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var currentCategory: String = "For You"
    var allCategories: [String] = ["For You", "Art", "Sports", "Comics", "Music", "Politics", "Photography", "Science", "News", "Animals", "Books", "Comedy", "Culture", "Education", "Food", "Journalism", "Movies", "Nature", "Pets", "Tech", "TV", "Writers"]
    
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
        if searchResults.isEmpty {} else {
            whoToFollow = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = whoToFollow
                } else {
                    whoToFollow = searchResults
                    tableView.reloadData()
                }
            } else {
                let z = whoToFollow.filter({
                    return ($0.displayName ?? "").lowercased().contains(theText) || ($0.description ?? "").lowercased().contains(theText)
                })
                whoToFollow = z
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            whoToFollow = self.searchResults
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
        navigationItem.title = "For You"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        setUpNavigationBar()
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
        let theTitle: String = currentCategory
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
        for category in allCategories {
            let menuItem = UIAction(title: category, identifier: nil) { [weak self] action in
                guard let self else { return }
                currentCategory = category
                fetchUsers(currentCategory)
                tableView.reloadData()
                setupListDropdown()
            }
            if currentCategory == category {
                menuItem.state = .on
            } else {
                menuItem.state = .off
            }
            allActions0.append(menuItem)
        }
        let menu = UIMenu(title: "", options: [.displayInline], children: allActions0)
        titleLabel.menu = menu
        titleLabel.showsMenuAsPrimaryAction = true
    }
    
    func fetchUsers(_ category: String = "") {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getSuggestedUsers(category: category)
                    whoToFollow = x.actors
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Error fetching suggested users: \(error)")
                tableView.reloadData()
            }
        }
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView.tableHeaderView?.frame.size.height = 56
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 56))
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
            controller.searchBar.placeholder = "Search Suggested Accounts"
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
        return whoToFollow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        let user: AppBskyLexicon.Actor.ProfileViewDefinition? = whoToFollow[indexPath.row]
        if let url = user?.avatarImageURL {
            cell.avatar.sd_imageTransition = .fade
            cell.avatar.sd_setImage(with: url, for: .normal)
            cell.avatar.tag = indexPath.row
            cell.avatar.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        } else {
            let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            let avatarImage = UIImage(systemName: "person.fill", withConfiguration: symbolConfig1)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.avatar.setImage(avatarImage, for: .normal)
            cell.avatar.backgroundColor = GlobalStruct.baseTint
        }
        cell.username.text = user?.displayName ?? ""
        cell.usertag.text = "@\(user?.actorHandle ?? "")"
        let bioText = user?.description ?? ""
        var followsYou: Bool = false
        if let _ = user?.viewer?.followedByURI {
            followsYou = true
        }
        cell.configureCell(followsYou, bioText: bioText, defaultProfile: user)
        
        if indexPath.row == whoToFollow.count - 1 {
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
        vc.profile = whoToFollow[indexPath.row].actorDID
        navigationController?.pushViewController(vc, animated: true)
        if isSearching {
            searchController.isActive = false
        }
    }
    
}
