//
//  HashtagViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 14/05/2025.
//

import UIKit
import ATProtoKit

class HashtagViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var hashtag: String = ""
    var allPosts: [AppBskyLexicon.Feed.PostViewDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [AppBskyLexicon.Feed.PostViewDefinition] = []
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
                    let matchingAccount: Bool = ($0.author.displayName ?? "").lowercased().contains(theText)
                    if let record = $0.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
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
        navigationItem.title = "#\(hashtag)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        setUpNavigationBar()
        
        fetchPosts()
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
    
    func fetchPosts() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.searchPosts(matching: "#\(hashtag)", cursor: currentCursor)
                    allPosts += x.posts
                    currentCursor = x.cursor
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.tableView.reloadData()
                        self.isFetching = false
                    }
                }
            } catch {
                print("Error fetching hashtags: \(error)")
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.isFetching = false
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
            controller.searchBar.placeholder = "Search #\(hashtag)"
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
        return allPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
        let post = allPosts[indexPath.row]
        configurePostCell(cell, with: post)
        
        cell.avatar.tag = indexPath.row
        cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
        
        if isFetching == false && currentCursor != nil {
            if indexPath.row == allPosts.count - 1 || indexPath.row == allPosts.count - 5 {
                isFetching = true
                fetchPosts()
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
        vc.detailPost = allPosts[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        if isSearching {
            searchController.isActive = false
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return makePostContextMenu(indexPath.row, post: self.allPosts[indexPath.row])
        }
    }
    
    @objc func profileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allPosts[sender.tag].author.actorDID
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
