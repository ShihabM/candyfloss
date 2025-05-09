//
//  MessagesViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import UIKit
import ATProtoKit

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var tempScrollPosition: CGFloat = 0
    let refreshControl = UIRefreshControl()
    var allMessages: [ChatBskyLexicon.Conversation.ConversationViewDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var fromNavigation: Bool = false
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [ChatBskyLexicon.Conversation.ConversationViewDefinition] = []
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
            allMessages = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = allMessages
                } else {
                    allMessages = searchResults
                    tableView.reloadData()
                }
            } else {
                let z = allMessages.filter({
                    let matchingAccount: Bool = ($0.members.last?.displayName ?? "").lowercased().contains(theText)
                    if let message = $0.lastMessage {
                        switch message {
                        case .messageView(let message):
                            return message.text.lowercased().contains(theText) || matchingAccount
                        default:
                            return false
                        }
                    }
                    return false
                })
                allMessages = z
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            allMessages = self.searchResults
            tableView.reloadData()
        }
        searchFirstTime = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalStruct.currentTab = 5
    }
    
    @objc func scrollUp() {
        if allMessages.isEmpty {} else {
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
                if let y = x as? MessageCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.time.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.usertag.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.text.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
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
                }
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Messages"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollUp), name: NSNotification.Name(rawValue: "scrollUp5"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        setUpNavigationBar()
        
        fetchMessages()
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
    
    @objc func goToSettings() {
        defaultHaptics()
        let vc = SettingsViewController()
        vc.fromNavigationStack = false
        getTopMostViewController()?.show(SloppySwipingNav(rootViewController: vc), sender: self)
    }
    
    func fetchMessages() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    if currentCursor == nil {
                        let y = try await atProto.getProfile(for: GlobalStruct.userHandle)
                        GlobalStruct.currentUser = y
                    }
                    let atProtoBluesky = ATProtoBlueskyChat(atProtoKitInstance: atProto)
                    let x = try await atProtoBluesky.listConversations(cursor: currentCursor)
                    allMessages += x.conversations
                    currentCursor = x.cursor
                    tableView.reloadData()
                    refreshControl.endRefreshing()
                }
            } catch {
                print("Error fetching messages: \(error.localizedDescription)")
                refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func fetchLatest() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let atProtoBluesky = ATProtoBlueskyChat(atProtoKitInstance: atProto)
                    let x = try await atProtoBluesky.listConversations()
                    let newMessages = x.conversations.filter { newMessage in
                        !allMessages.contains(where: { $0.conversationID == newMessage.conversationID })
                    }
                    DispatchQueue.main.async {
                        if !newMessages.isEmpty {
                            self.allMessages.insert(contentsOf: newMessages, at: 0)
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            } catch {
                print("Error fetching messages: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
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
            controller.searchBar.placeholder = "Search Messages"
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
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        if let message = allMessages[indexPath.row].lastMessage {
            switch message {
            case .messageView(let message):
                configureMessageCell(cell, with: message, members: allMessages[indexPath.row].members)
            default:
                break
            }
        }
        
        cell.avatar.tag = indexPath.row
        cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
        cell.text.numberOfLines = 2
        
        if isFetching == false && currentCursor != nil {
            if indexPath.row == allMessages.count - 1 || indexPath.row == allMessages.count - 5 {
                isFetching = true
                fetchMessages()
            }
        }
        
        if indexPath.row == allMessages.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
        }
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = GlobalStruct.backgroundTint
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearching {
            searchController.isActive = false
        }
    }
    
    @objc func profileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allMessages[sender.tag].members.first?.actorDID ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
