//
//  MessagesListViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import UIKit
import ATProtoKit

class MessagesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var tempScrollPosition: CGFloat = 0
    let refreshControl = UIRefreshControl()
    var allMessages: [ChatBskyLexicon.Conversation.ConversationViewDefinition] = []
    var filteredMessages: [ChatBskyLexicon.Conversation.ConversationViewDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var fromNavigation: Bool = false
    var messageSection: Int = 0
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [ChatBskyLexicon.Conversation.ConversationViewDefinition] = []
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
            filteredMessages = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = filteredMessages
                } else {
                    filteredMessages = searchResults
                    tableView.reloadData()
                }
            } else {
                let z = filteredMessages.filter({
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
                filteredMessages = z
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            filteredMessages = self.searchResults
            tableView.reloadData()
        }
        searchFirstTime = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalStruct.currentTab = 5
    }
    
    @objc func scrollUp() {
        if filteredMessages.isEmpty {} else {
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
        
        setupListDropdown()
    }
    
    @objc func setupListDropdown() {
        var theTitle: String = ""
        if messageSection == 0 {
            theTitle = "Messages"
        } else if messageSection == 1 {
            theTitle = "Muted"
        } else {
            theTitle = "Requested"
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
        let menuItem = UIAction(title: "Messages", image: UIImage(systemName: "message"), identifier: nil) { [weak self] action in
            guard let self else { return }
            messageSection = 0
            filteredMessages = allMessages.filter({ message in
                message.status == .accepted && !message.isMuted
            })
            updateSearchBar(text: "Messages")
            tableView.reloadData()
            setupListDropdown()
        }
        if messageSection == 0 {
            menuItem.state = .on
        } else {
            menuItem.state = .off
        }
        allActions0.append(menuItem)
        let menuItem1 = UIAction(title: "Muted", image: UIImage(systemName: "speaker.slash"), identifier: nil) { [weak self] action in
            guard let self else { return }
            messageSection = 1
            filteredMessages = allMessages.filter({ message in
                message.isMuted
            })
            updateSearchBar(text: "Muted")
            tableView.reloadData()
            setupListDropdown()
        }
        if messageSection == 1 {
            menuItem1.state = .on
        } else {
            menuItem1.state = .off
        }
        allActions0.append(menuItem1)
        let menuItem2 = UIAction(title: "Requested", image: UIImage(systemName: "questionmark.bubble"), identifier: nil) { [weak self] action in
            guard let self else { return }
            messageSection = 2
            filteredMessages = allMessages.filter({ message in
                message.status == .request
            })
            updateSearchBar(text: "Requested")
            tableView.reloadData()
            setupListDropdown()
        }
        if messageSection == 2 {
            menuItem2.state = .on
        } else {
            menuItem2.state = .off
        }
        allActions0.append(menuItem2)
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
                    if messageSection == 0 {
                        filteredMessages = allMessages.filter({ message in
                            message.status == .accepted && !message.isMuted
                        })
                    } else if messageSection == 1 {
                        filteredMessages = allMessages.filter({ message in
                            message.isMuted
                        })
                    } else {
                        filteredMessages = allMessages.filter({ message in
                            message.status == .request
                        })
                    }
                    currentCursor = x.cursor
                    
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                }
            } catch {
                print("Error fetching messages: \(error)")
                loadingIndicator.stopAnimating()
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
                            if self.messageSection == 0 {
                                self.filteredMessages = self.allMessages.filter({ message in
                                    message.status == .accepted && !message.isMuted
                                })
                            } else if self.messageSection == 1 {
                                self.filteredMessages = self.allMessages.filter({ message in
                                    message.isMuted
                                })
                            } else {
                                self.filteredMessages = self.allMessages.filter({ message in
                                    message.status == .request
                                })
                            }
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        } else {
                            self.refreshControl.endRefreshing()
                        }
                    }
                }
            } catch {
                print("Error fetching messages: \(error)")
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
        return filteredMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        if let message = filteredMessages[indexPath.row].lastMessage {
            switch message {
            case .messageView(let message):
                configureMessageCell(cell, with: message, members: filteredMessages[indexPath.row].members)
            default:
                break
            }
        }
        
        if let author = filteredMessages[indexPath.row].members.first(where: { member in
            member.actorDID != GlobalStruct.currentUser?.actorDID ?? ""
        }) {
            // message avatar
            if let url = author.avatarImageURL {
                cell.avatar.sd_setImage(with: url, for: .normal)
            } else {
                cell.avatar.setImage(UIImage(), for: .normal)
            }
            
            // message user details
            cell.username.text = author.displayName ?? ""
            if cell.username.text == "" {
                cell.username.text = " "
            }
            cell.usertag.text = "@\(author.actorHandle)"
        }
        cell.avatar.tag = indexPath.row
        cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
        cell.text.numberOfLines = 2
        
        if isFetching == false && currentCursor != nil {
            if indexPath.row == filteredMessages.count - 1 || indexPath.row == filteredMessages.count - 5 {
                isFetching = true
                fetchMessages()
            }
        }
        
        if indexPath.row == filteredMessages.count - 1 {
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
        let vc = MessageChatViewController()
        if let author = filteredMessages[indexPath.row].members.first(where: { member in
            member.actorDID != GlobalStruct.currentUser?.actorDID ?? ""
        }) {
            vc.displayName = author.displayName ?? "Chat"
            vc.actorDID = author.actorDID
            vc.avatar = author.avatarImageURL
            vc.isMuted = filteredMessages[indexPath.row].isMuted
        }
        vc.conversation = [filteredMessages[indexPath.row]]
        navigationController?.pushViewController(vc, animated: true)
        if isSearching {
            searchController.isActive = false
        }
    }
    
    @objc func profileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        if let author = filteredMessages[sender.tag].members.first(where: { member in
            member.actorDID != GlobalStruct.currentUser?.actorDID ?? ""
        }) {
            vc.profile = author.actorDID
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
