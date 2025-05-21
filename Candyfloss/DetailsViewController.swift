//
//  DetailsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import UIKit
import ATProtoKit

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var detailPost: AppBskyLexicon.Feed.PostViewDefinition? = nil
    var allParents: [AppBskyLexicon.Feed.ThreadViewPostDefinition] = []
    var allReplies: [AppBskyLexicon.Feed.ThreadViewPostDefinition] = []
    var nestedRepliesIndices: [Int] = []
    var scrollUpButton = UIButton()
    var scrollDownButton = UIButton()
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    @objc func reloadTables() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalStruct.currentTab = 100
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
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
            for x in self.tableView.visibleCells {
                if let y = x as? DetailCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.time.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.username.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.usertag.font = UIFont.systemFont(ofSize: smallestFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.text.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.text.mentionColor = GlobalStruct.baseTint
                    y.text.hashtagColor = GlobalStruct.baseTint
                    y.text.URLColor = GlobalStruct.baseTint
                    y.text.emailColor = GlobalStruct.baseTint
                    y.text.lineSpacing = GlobalStruct.customLineSize
                    if let text = y.text.text {
                        y.text.text = nil
                        y.text.text = text
                    }
                    y.uriLabel.textColor = GlobalStruct.baseTint
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
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Post"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = GlobalStruct.backgroundTint
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = UIColor.separator
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        GlobalStruct.detailImages = []
        GlobalStruct.detailImageWidth = 0
        GlobalStruct.detailImageHeight = 0
        GlobalStruct.detailVideoAspectRatioWidth = 0
        GlobalStruct.detailVideoAspectRatioHeight = 0
        
        fetchContext()
        setUpTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.scrollDownButton.alpha == 0 && GlobalStruct.showNextReplyButton {
            if allReplies.count > 3 {
                self.scrollDownButton.transform = .identity.scaledBy(x: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) { [weak self] in
                    guard let self else { return }
                    self.scrollDownButton.alpha = 1
                    self.scrollDownButton.transform = .identity
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideScrollUpButton()
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) { [weak self] in
            guard let self else { return }
            self.scrollDownButton.alpha = 0
            self.scrollDownButton.transform = .identity.scaledBy(x: 0.1, y: 0.1)
        }
    }
    
    func fetchContext() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    tableView.reloadData()
                    let x = try await atProto.getPostThread(from: detailPost?.uri ?? "")
                    switch x.thread  {
                    case .threadViewPost(let post):
                        // fetch parents iteratively
                        fetchParents(post)
                        for reply in post.replies ?? [] {
                            switch reply  {
                            case .threadViewPost(let post):
                                // fetch first level of replies
                                allReplies.append(post)
                                for reply in post.replies ?? [] {
                                    switch reply  {
                                    case .threadViewPost(let post):
                                        // fetch second level of replies
                                        allReplies.append(post)
                                        nestedRepliesIndices.append(allReplies.count - 1)
                                    default:
                                        break
                                    }
                                }
                            default:
                                break
                            }
                        }
                    default:
                        break
                    }
                    
                    if allReplies.count > 3 {
                        self.scrollDownButton.transform = .identity.scaledBy(x: 0.1, y: 0.1)
                        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) { [weak self] in
                            guard let self else { return }
                            self.scrollDownButton.alpha = 1
                            self.scrollDownButton.transform = .identity
                        }
                    }
                    
                    // reload all replies
                    let indexPaths = (0..<self.allReplies.count).map { IndexPath(row: $0, section: 3) }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                    
                        // set up footers
                        var repliesIndex = 0
                        var repliesHeights: CGFloat = 0
                        _ = allReplies.map({ x in
                            repliesHeights = CGFloat(repliesHeights) + CGFloat(tableView.rectForRow(at: IndexPath(row: repliesIndex, section: 3)).height)
                            repliesIndex += 1
                        })
                        var initialfinalFooterHeightight: CGFloat = 0
                        if allReplies.isEmpty {
                            initialfinalFooterHeightight = (tableView.bounds.height - tableView.rectForRow(at: IndexPath(row: 0, section: 1)).height - tableView.rectForRow(at: IndexPath(row: 1, section: 1)).height - tableView.rectForRow(at: IndexPath(row: 0, section: 2)).height - tableView.rectForRow(at: IndexPath(row: 1, section: 2)).height) + 6
                        } else {
                            initialfinalFooterHeightight = (tableView.bounds.height - tableView.rectForRow(at: IndexPath(row: 0, section: 1)).height - tableView.rectForRow(at: IndexPath(row: 1, section: 1)).height - tableView.rectForRow(at: IndexPath(row: 2, section: 1)).height - tableView.rectForRow(at: IndexPath(row: 0, section: 2)).height - tableView.rectForRow(at: IndexPath(row: 1, section: 2)).height) + 6
                        }
                        var finalFooterHeight = initialfinalFooterHeightight - repliesHeights - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 6
                        if finalFooterHeight < 0 {
                            finalFooterHeight = 0
                        }
                        if allReplies.count > 3 {
                            if GlobalStruct.showNextReplyButton {
                                finalFooterHeight += 80
                            }
                        }
                        let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: finalFooterHeight))
                        tableView.tableFooterView = customViewFooter
                        
                        // set correct offset
                        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                    
                    if !allParents.isEmpty {
                        // set up 'scroll to top' button
                        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
                        scrollUpButton.removeFromSuperview()
                        scrollUpButton.frame = CGRect(x: view.bounds.width - 52, y: (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) + (navigationController?.navigationBar.frame.height ?? 0.0) + 28, width: 36, height: 36)
                        scrollUpButton.backgroundColor = .clear
                        scrollUpButton.layer.cornerRadius = 18
                        scrollUpButton.setImage(UIImage(systemName: "arrow.up", withConfiguration: symbolConfig)?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal), for: .normal)
                        scrollUpButton.addTarget(self, action: #selector(scrollToTop), for: .touchUpInside)
                        scrollUpButton.alpha = 0
                        navigationController?.view.addSubview(scrollUpButton)
                        showScrollUpButton()
                    }
                }
            } catch {
                print("Error fetching context: \(error)")
            }
        }
    }
    
    func fetchParents(_ post: AppBskyLexicon.Feed.ThreadViewPostDefinition) {
        if let parent = post.parent {
            switch parent  {
            case .threadViewPost(let post):
                allParents.insert(post, at: 0)
                fetchParents(post)
            default:
                break
            }
        }
        UIView.performWithoutAnimation {
            tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .none)
        }
    }
    
    @objc func scrollToTop() {
        if GlobalStruct.switchHaptics {
            let haptics = UIImpactFeedbackGenerator(style: .medium)
            haptics.impactOccurred()
        }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        hideScrollUpButton()
    }
    
    func showScrollUpButton() {
        UIView.animate(withDuration: 0.75, delay: 0.15, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2) { [weak self] in
            guard let self else { return }
            self.scrollUpButton.alpha = 1
        }
    }
    
    func hideScrollUpButton() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2) { [weak self] in
            guard let self else { return }
            self.scrollUpButton.alpha = 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideScrollUpButton()
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")
        tableView.register(PostsCell.self, forCellReuseIdentifier: "PostsCell")
        tableView.register(DetailActionBarCell.self, forCellReuseIdentifier: "DetailActionBarCell")
        tableView.register(DetailImagesCell.self, forCellReuseIdentifier: "DetailImagesCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
        
        if GlobalStruct.showNextReplyButton {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
            scrollDownButton.frame = CGRect(x: self.view.bounds.width - 70, y: self.view.bounds.height - 70 - (self.tabBarController?.tabBar.bounds.height ?? 0), width: 60, height: 60)
            scrollDownButton.layer.cornerRadius = 30
            scrollDownButton.backgroundColor = GlobalStruct.baseTint
            scrollDownButton.setImage(UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            scrollDownButton.adjustsImageWhenHighlighted = false
            scrollDownButton.addTarget(self, action: #selector(self.scrollDownTapped), for: .touchUpInside)
            scrollDownButton.alpha = 0
            scrollDownButton.layer.shadowColor = UIColor.black.cgColor
            scrollDownButton.layer.shadowOffset = CGSize(width: 0, height: 15)
            scrollDownButton.layer.shadowRadius = 14
            scrollDownButton.layer.shadowOpacity = 0.24
            getTopMostViewController()?.view.addSubview(scrollDownButton)
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
            longPressRecognizer.minimumPressDuration = 0.27
            scrollDownButton.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            defaultHaptics()
            if GlobalStruct.nextReplyButtonState == 0 {
                if let navBar = self.navigationController?.navigationBar {
                    let whereIsNavBarInTableView = self.tableView.convert(navBar.bounds, from: navBar)
                    let pointWhereNavBarEnds = CGPoint(x: 0, y: whereIsNavBarInTableView.origin.y + whereIsNavBarInTableView.size.height + 4)
                    let indexP = self.tableView.indexPathForRow(at: pointWhereNavBarEnds)
                    if (indexP?.section ?? 0) < 3 {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
                    } else {
                        if ((indexP?.row ?? 0) - 1) > 0 {
                            self.tableView.scrollToRow(at: IndexPath(row: (indexP?.row ?? 0) - 1, section: 3), at: .top, animated: true)
                        } else {
                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
                        }
                    }
                }
            } else if GlobalStruct.nextReplyButtonState == 1 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
            } else {
                if allReplies.isEmpty {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
                } else {
                    self.tableView.scrollToRow(at: IndexPath(row: allReplies.count - 1, section: 3), at: .top, animated: true)
                }
            }
        }
    }
    
    @objc func scrollDownTapped() {
        defaultHaptics()
        if let navBar = self.navigationController?.navigationBar {
            let whereIsNavBarInTableView = self.tableView.convert(navBar.bounds, from: navBar)
            let pointWhereNavBarEnds = CGPoint(x: 0, y: whereIsNavBarInTableView.origin.y + whereIsNavBarInTableView.size.height + 4)
            let indexP = self.tableView.indexPathForRow(at: pointWhereNavBarEnds)
            if (indexP?.section ?? 0) < 3 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .top, animated: true)
            } else {
                if ((indexP?.row ?? 0) + 1) < allReplies.count {
                    self.tableView.scrollToRow(at: IndexPath(row: (indexP?.row ?? 0) + 1, section: 3), at: .top, animated: true)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return allParents.count
        } else if section == 1 {
            if let embed = detailPost?.embed {
                switch embed {
                case .embedImagesView(_):
                    return 2
                case .embedVideoView(_):
                    return 2
                case .embedExternalView(let externalEmbed):
                    // handle external gifs
                    if externalEmbed.external.uri.contains(".gif?") {
                        return 2
                    } else {
                        return 1
                    }
                default:
                    return 1
                }
            } else {
                return 1
            }
        } else if section == 2 {
            return 1
        } else {
            return allReplies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
            let post = allParents[indexPath.row].post
            
            configurePostCell(cell, with: post)
            
            cell.avatar.tag = indexPath.row
            cell.avatar.addTarget(self, action: #selector(parentProfileTapped(_:)), for: .touchUpInside)
            
            if indexPath.row == allParents.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 74, bottom: 0, right: 0)
            }
            cell.accessoryView = nil
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
                
                if let post = detailPost {
                    configureDetailCell(cell, with: post)
                }
                
                cell.avatar.tag = indexPath.row
                cell.avatar.addTarget(self, action: #selector(profileTapped(_:)), for: .touchUpInside)
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = .clear
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailImagesCell", for: indexPath) as! DetailImagesCell
                
                var images: [URL] = []
                var video: AppBskyLexicon.Embed.VideoDefinition.View? = nil
                if let embed = detailPost?.embed {
                    switch embed {
                    case .embedImagesView(let imageEmbed):
                        for image in imageEmbed.images {
                            if image.aspectRatio?.height ?? 0 > GlobalStruct.detailImageHeight {
                                GlobalStruct.detailImageWidth = image.aspectRatio?.width ?? 0
                                GlobalStruct.detailImageHeight = image.aspectRatio?.height ?? 0
                            }
                            images.append(image.fullSizeImageURL)
                            GlobalStruct.detailImages = images
                        }
                    case .embedVideoView(let videoEmbed):
                        if let width = videoEmbed.aspectRatio?.width, width != 0 {
                            GlobalStruct.detailVideoAspectRatioWidth = CGFloat(width)
                            GlobalStruct.detailImageWidth = Int(GlobalStruct.detailVideoAspectRatioWidth)
                        }
                        if let height = videoEmbed.aspectRatio?.height, height != 0 {
                            GlobalStruct.detailVideoAspectRatioHeight = CGFloat(height)
                            GlobalStruct.detailImageHeight = Int(GlobalStruct.detailVideoAspectRatioHeight)
                        }
                        if let thumbnail = videoEmbed.thumbnailImageURL, let url = URL(string: thumbnail) {
                            images.append(url)
                            GlobalStruct.detailImages = images
                        }
                        video = videoEmbed
                    case .embedExternalView(let externalEmbed):
                        // handle external gifs
                        if externalEmbed.external.uri.contains(".gif?") {
                            if let link = URL(string: "\(externalEmbed.external.uri)") {
                                images.append(link)
                                GlobalStruct.detailImages = images
                            }
                        } else {
                            break
                        }
                    default:
                        break
                    }
                }
                cell.configureCell(video)
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
                cell.accessoryView = nil
                let bgColorView = UIView()
                bgColorView.backgroundColor = UIColor.clear
                cell.selectedBackgroundView = bgColorView
                cell.backgroundColor = .clear
                return cell
            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailActionBarCell", for: indexPath) as! DetailActionBarCell
            
            if let post = detailPost {
                cell.setupButtons(post)
            }
            if let embed = detailPost?.embed {
                switch embed {
                case .embedImagesView(_):
                    cell.borderDividerLayer.isHidden = true
                case .embedVideoView(_):
                    cell.borderDividerLayer.isHidden = true
                case .embedExternalView(let externalEmbed):
                    // handle external gifs
                    if externalEmbed.external.uri.contains(".gif?") {
                        cell.borderDividerLayer.isHidden = true
                    } else {
                        cell.borderDividerLayer.isHidden = false
                    }
                default:
                    cell.borderDividerLayer.isHidden = false
                }
            } else {
                cell.borderDividerLayer.isHidden = false
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
            cell.accessoryView = nil
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = .clear
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
            let post = allReplies[indexPath.row].post
            
            var isNestedReply: Bool = false
            if nestedRepliesIndices.contains(indexPath.row) {
                isNestedReply = true
            }
            
            configurePostCell(cell, with: post, isNestedReply: isNestedReply)
            
            cell.avatar.tag = indexPath.row
            cell.avatar.addTarget(self, action: #selector(replyProfileTapped(_:)), for: .touchUpInside)
            
            if nestedRepliesIndices.contains(indexPath.row) {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 134, bottom: 0, right: 0)
            } else if indexPath.row == allReplies.count - 1 {
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
        if indexPath.section == 0 {
            let vc = DetailsViewController()
            vc.detailPost = allParents[indexPath.row].post
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 3 {
            let vc = DetailsViewController()
            vc.detailPost = allReplies[indexPath.row].post
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == 0 {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                return makePostContextMenu(indexPath.row, post: self.allParents[indexPath.row].post)
            }
        } else if indexPath.section == 1 {
            if let post = detailPost {
                return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                    return makePostContextMenu(indexPath.row, post: post)
                }
            } else {
                return nil
            }
        } else if indexPath.section == 3 {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                return makePostContextMenu(indexPath.row, post: self.allReplies[indexPath.row].post)
            }
        } else {
            return nil
        }
    }
    
    @objc func parentProfileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allParents[sender.tag].post.author.actorDID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func profileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        if let post = detailPost {
            vc.profile = post.author.actorDID
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func replyProfileTapped(_ sender: UIButton) {
        defaultHaptics()
        let vc = ProfileViewController()
        vc.profile = allReplies[sender.tag].post.author.actorDID
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
