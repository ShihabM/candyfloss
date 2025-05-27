//
//  ComposerViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 28/03/2025.
//

import UIKit
import PhotosUI
import AVKit
import ATProtoKit

class ComposerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, PHPickerViewControllerDelegate, SKPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVPlayerViewControllerDelegate {
    
    private var pendingRequestWorkItem: DispatchWorkItem?
    var work = DispatchWorkItem(block: {})
    var trimmedAtString: String = ""
    var userItemsAll: [AppBskyLexicon.Actor.ProfileViewDefinition] = []
    
    var atProto: ATProtoKit? = nil
    let config = ATProtocolConfiguration()
    var allAccounts: [AppBskyLexicon.Actor.ProfileViewDetailedDefinition] = []
    var currentSelectedUser: String = ""
    var currentUser: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = nil
    
    var tableView = UITableView()
    var allPosts: [AppBskyLexicon.Feed.PostViewDefinition] = []
    var formatToolbar = UIToolbar()
    var formatToolbar2 = UIToolbar()
    var scrollView = UIScrollView()
    var keyHeight: CGFloat = 0
    var currentPostText: String = ""
    var currentLocale: String = "en_EN"
    var counterButton = UIBarButtonItem()
    var remainingCharacters: Int = GlobalStruct.currentMaxChars
    var hasSetOnce: Bool = false
    var canPost: Bool = false
    var isQuote: Bool = false
    
    var hasVideo: Bool = false
    var hasGIF: Bool = false
    var attachedMedia: [UIImage] = []
    var mediaAltText: [String?] = []
    var photoPickerView: PHPickerViewController!
    var photoPickerView2 = UIImagePickerController()
    var mediaContainer1 = UIButton()
    var mediaImage1 = UIImageView()
    var mediaContainer2 = UIButton()
    var mediaImage2 = UIImageView()
    var mediaContainer3 = UIButton()
    var mediaImage3 = UIImageView()
    var mediaContainer4 = UIButton()
    var mediaImage4 = UIImageView()
    var thumbnailAttempt: Int = 0
    var videoData: Data = Data()
    var videoURL: URL = URL(string: "www.google.com")!
    
    var whoCanReply: [ATProtoBluesky.ThreadgateAllowRule] = [.allowMentions, .allowFollowing, .allowFollowers]
    var allowQuotes: Bool = true
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if allPosts.isEmpty {} else {
            let footerHeight = tableView.bounds.height - tableView.rectForRow(at: IndexPath(row: 0, section: 1)).height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
            let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight))
            customViewFooter.isUserInteractionEnabled = false
            tableView.tableFooterView = customViewFooter
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        }
        
        // accounts
        fetchAccounts()
    }
    
    @objc func restoreFromDrafts() {
        if let draft = GlobalStruct.currentDraft {
            currentPostText = draft.text
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.post.text = currentPostText
                parseText()
                let footerHe = self.tableView.bounds.height - self.tableView.rectForRow(at: IndexPath(row: 0, section: 1)).height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - self.formatToolbar.frame.size.height
                let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: footerHe))
                customViewFooter.isUserInteractionEnabled = false
                self.tableView.tableFooterView = customViewFooter
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
                let maxAllowedHeight = self.view.bounds.height - self.keyHeight - (self.navigationController?.navigationBar.frame.size.height ?? 0) - self.formatToolbar.frame.size.height
                let size = CGSize(width: cell.post.bounds.width, height: .infinity)
                let estimatedSize = cell.post.sizeThatFits(size)
                let newHeight = min(estimatedSize.height, maxAllowedHeight)
                if estimatedSize.height > (maxAllowedHeight - 100) {
                    cell.post.isScrollEnabled = true
                } else {
                    cell.post.isScrollEnabled = false
                }
                cell.post.constraints.forEach { constraint in
                    if constraint.firstAttribute == .height {
                        constraint.constant = newHeight
                    }
                }
            }
            if draft.reply != nil || draft.quote != nil {
                Task {
                    do {
                        if let atProto = self.atProto {
                            let x = try await atProto.getPosts([draft.reply?.uri ?? draft.quote?.uri ?? ""])
                            allPosts = x.posts
                            DispatchQueue.main.async {
                                self.setUpTable()
                                let footerHeight = self.tableView.bounds.height - self.tableView.rectForRow(at: IndexPath(row: 0, section: 1)).height - self.view.safeAreaInsets.bottom - self.view.safeAreaInsets.top
                                let customViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: footerHeight))
                                customViewFooter.isUserInteractionEnabled = false
                                self.tableView.tableFooterView = customViewFooter
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
                                }
                            }
                        }
                    } catch {
                        print("error fetching post: \(error)")
                    }
                }
            }
            tableView.reloadData()
            enablePosting()
            createToolbar()
        }
    }
    
    @objc func updateMediaAltText() {
        mediaAltText[GlobalStruct.composerMediaIndex] = GlobalStruct.currentMediaAltText
        GlobalStruct.currentMediaAltText = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Compose"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.restoreFromDrafts), name: NSNotification.Name(rawValue: "restoreFromDrafts"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createToolbar), name: NSNotification.Name(rawValue: "createToolbar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotateComposerMedia), name: NSNotification.Name(rawValue: "rotateComposerMedia"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMediaAltText), name: NSNotification.Name(rawValue: "updateMediaAltText"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        do {
            GlobalStruct.drafts = try Disk.retrieve("drafts.json", from: .documents, as: [PostDrafts].self)
        } catch {
            print("error fetching from Disk")
        }
        
        atProto = GlobalStruct.atProto
        currentSelectedUser = GlobalStruct.currentSelectedUser
        currentUser = GlobalStruct.currentUser
        
        setUpNavigationBar()
        setUpTable()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        GlobalStruct.fromComposerMedia = false
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
        let closeButton = CustomButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(GlobalStruct.baseTint, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        closeButton.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        let closeBarButtonItem = UIBarButtonItem(customView: closeButton)
        closeBarButtonItem.accessibilityLabel = "Dismiss"
        navigationItem.leftBarButtonItem = closeBarButtonItem
        let postButton = CustomButton(type: .system)
        postButton.setTitle("Post", for: .normal)
        postButton.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
        postButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        postButton.addTarget(self, action: #selector(self.submitPost), for: .touchUpInside)
        let postBarButtonItem = UIBarButtonItem(customView: postButton)
        postBarButtonItem.accessibilityLabel = "Post"
        navigationItem.rightBarButtonItem = postBarButtonItem
    }
    
    @objc func dismissView() {
        defaultHaptics()
        if currentPostText == "" {
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "Unsaved Post", message: "Save as draft?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Save Draft", style: .default, handler: { (UIAlertAction) in
                var reply: PostDraftsQuoteReply? = nil
                var quote: PostDraftsQuoteReply? = nil
                if !self.allPosts.isEmpty {
                    if let post = self.allPosts.first {
                        if self.isQuote {
                            quote = PostDraftsQuoteReply(uri: post.uri, cid: post.cid)
                            GlobalStruct.drafts.insert(PostDrafts(text: self.currentPostText, createdAt: Date(), media: nil, reply: reply, quote: quote), at: 0)
                        } else {
                            reply = PostDraftsQuoteReply(uri: post.uri, cid: post.cid)
                            GlobalStruct.drafts.insert(PostDrafts(text: self.currentPostText, createdAt: Date(), media: nil, reply: reply, quote: quote), at: 0)
                        }
                    }
                } else {
                    GlobalStruct.drafts.insert(PostDrafts(text: self.currentPostText, createdAt: Date(), media: nil, reply: reply, quote: quote), at: 0)
                }
                do {
                    try Disk.save(GlobalStruct.drafts, to: .documents, as: "drafts.json")
                } catch {
                    print("error saving to Disk")
                }
                self.dismiss(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Continue Editing", style: .cancel, handler: { (UIAlertAction) in
                
            }))
            alert.addAction(UIAlertAction(title: "Delete and Dismiss", style: .destructive, handler: { (UIAlertAction) in
                self.dismiss(animated: true)
            }))
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = getTopMostViewController()?.view
                presenter.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
            }
            getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func submitPost() {
        defaultHaptics()
        disablePosting()
        Task {
            do {
                if let atProto = self.atProto {
                    let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                    
                    // media
                    var allImages: [ATProtoTools.ImageQuery] = []
                    for (index, image) in attachedMedia.enumerated() {
                        let image = ATProtoTools.ImageQuery(
                            imageData: image.jpegData(compressionQuality: 0.8) ?? Data(),
                            fileName: "image-\(UUID()).jpg",
                            altText: mediaAltText[index],
                            aspectRatio: nil
                        )
                        allImages.append(image)
                    }
                    
                    // post
                    if let post = allPosts.first, let session = try await atProto.getUserSession() {
                        if isQuote {
                            let strongReference = ComAtprotoLexicon.Repository.StrongReference(recordURI: post.uri, cidHash: post.cid)
                            let post = try await atProtoBluesky.createPostRecord(
                                text: currentPostText,
                                locales: [Locale(identifier: currentLocale)],
                                embed: .record(strongReference: strongReference)
                            )
                            _ = try await atProtoBluesky.createThreadgateRecord(
                                postURI: post.recordURI,
                                replyControls: whoCanReply
                            )
                            DispatchQueue.main.async {
                                print("Created quote: \(post)")
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "fetchLatest"), object: nil)
                                self.dismiss(animated: true)
                            }
                        } else {
                            let replyTo = try await ATProtoTools().createReplyReference(
                                from: ComAtprotoLexicon.Repository.StrongReference(recordURI: post.uri, cidHash: post.cid),
                                session: session
                            )
                            if allImages.isEmpty {
                                let post = try await atProtoBluesky.createPostRecord(
                                    text: currentPostText,
                                    locales: [Locale(identifier: currentLocale)],
                                    replyTo: replyTo
                                )
                                _ = try await atProtoBluesky.createThreadgateRecord(
                                    postURI: post.recordURI,
                                    replyControls: whoCanReply
                                )
                                DispatchQueue.main.async {
                                    print("Created reply: \(post)")
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "fetchLatest"), object: nil)
                                    self.dismiss(animated: true)
                                }
                            } else {
                                if hasVideo {
                                    let post = try await atProtoBluesky.createPostRecord(
                                        text: currentPostText,
                                        locales: [Locale(identifier: currentLocale)],
                                        replyTo: replyTo,
                                        embed: .video(video: videoData, captions: nil, altText: mediaAltText.first ?? nil, aspectoRatio: nil)
                                    )
                                    _ = try await atProtoBluesky.createThreadgateRecord(
                                        postURI: post.recordURI,
                                        replyControls: whoCanReply
                                    )
                                    DispatchQueue.main.async {
                                        print("Created reply with video: \(post)")
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "fetchLatest"), object: nil)
                                        self.dismiss(animated: true)
                                    }
                                } else {
                                    let post = try await atProtoBluesky.createPostRecord(
                                        text: currentPostText,
                                        locales: [Locale(identifier: currentLocale)],
                                        replyTo: replyTo,
                                        embed: .images(images: allImages)
                                    )
                                    _ = try await atProtoBluesky.createThreadgateRecord(
                                        postURI: post.recordURI,
                                        replyControls: whoCanReply
                                    )
                                    DispatchQueue.main.async {
                                        print("Created reply with media: \(post)")
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "fetchLatest"), object: nil)
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                        }
                    } else {
                        if allImages.isEmpty {
                            let post = try await atProtoBluesky.createPostRecord(
                                text: currentPostText,
                                locales: [Locale(identifier: currentLocale)]
                            )
                            _ = try await atProtoBluesky.createThreadgateRecord(
                                postURI: post.recordURI,
                                replyControls: whoCanReply
                            )
                            DispatchQueue.main.async {
                                print("Created post: \(post)")
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "fetchLatest"), object: nil)
                                self.dismiss(animated: true)
                            }
                        } else {
                            if hasVideo {
                                let post = try await atProtoBluesky.createPostRecord(
                                    text: currentPostText,
                                    locales: [Locale(identifier: currentLocale)],
                                    embed: .video(video: videoData, captions: nil, altText: mediaAltText.first ?? nil, aspectoRatio: nil)
                                )
                                _ = try await atProtoBluesky.createThreadgateRecord(
                                    postURI: post.recordURI,
                                    replyControls: whoCanReply
                                )
                                DispatchQueue.main.async {
                                    print("Created post with video: \(post)")
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "fetchLatest"), object: nil)
                                    self.dismiss(animated: true)
                                }
                            } else {
                                let post = try await atProtoBluesky.createPostRecord(
                                    text: currentPostText,
                                    locales: [Locale(identifier: currentLocale)],
                                    embed: .images(images: allImages)
                                )
                                _ = try await atProtoBluesky.createThreadgateRecord(
                                    postURI: post.recordURI,
                                    replyControls: whoCanReply
                                )
                                DispatchQueue.main.async {
                                    print("Created post with media: \(post)")
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "fetchLatest"), object: nil)
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error posting: \(error)")
                enablePosting()
            }
        }
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height - ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0) - 4
            self.keyHeight = CGFloat(keyboardHeight)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                cell.post.frame.size.height = self.view.bounds.height - (self.navigationController?.navigationBar.bounds.size.height ?? 0) - self.keyHeight - self.formatToolbar.frame.size.height - 68
                cell.frame.size.height = cell.post.frame.size.height
                cell.frame.size.width = self.view.bounds.width
                self.mediaContainer1.frame.origin.y = self.view.bounds.height - self.formatToolbar.bounds.size.height - self.keyHeight - 70
                self.mediaContainer2.frame.origin.y = self.view.bounds.height - self.formatToolbar.bounds.size.height - self.keyHeight - 74
                self.mediaContainer3.frame.origin.y = self.view.bounds.height - self.formatToolbar.bounds.size.height - self.keyHeight - 70
                self.mediaContainer4.frame.origin.y = self.view.bounds.height - self.formatToolbar.bounds.size.height - self.keyHeight - 74
            }
        }
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(PostsCell.self, forCellReuseIdentifier: "PostsCell")
        tableView.register(ComposeCell.self, forCellReuseIdentifier: "ComposeCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        DispatchQueue.main.async {
            self.createToolbar()
            self.tableView.reloadData()
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                if self.allPosts.isEmpty {} else {
                    if self.isQuote {
                        cell.post.placeholder = "Quoting @\(self.allPosts.first?.author.actorHandle ?? "")..."
                    } else {
                        cell.post.placeholder = "Replying to @\(self.allPosts.first?.author.actorHandle ?? "")..."
                    }
                }
                cell.post.becomeFirstResponder()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if allPosts.isEmpty {
                return 0
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
            let post = allPosts[indexPath.row]
            configurePostCell(cell, with: post, showActionButtons: false)
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.accessoryView = nil
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComposeCell", for: indexPath) as! ComposeCell
            if let avatar = self.currentUser?.avatarImageURL {
                cell.avatar.sd_setImage(with: avatar, for: .normal)
            }
            cell.post.delegate = self
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = UIColor.clear
            cell.hoverStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
            return cell
        }
    }
    
    // account picker
    
    func fetchAccounts() {
        Task {
            do {
                if let atProto = self.atProto {
                    for user in GlobalStruct.allUsers {
                        let y = try await atProto.getProfile(for: user.username)
                        allAccounts.append(y)
                    }
                    allAccounts = allAccounts.sorted(by: { x, y in
                        x.actorHandle < y.actorHandle
                    })
                    accountPicker()
                }
            } catch {
                print("Error fetching accounts: \(error)")
            }
        }
    }
    
    func accountPicker() {
        if GlobalStruct.allUsers.count > 1 {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                var menuActions: [UIAction] = []
                for user in allAccounts {
                    if let url = user.avatarImageURL {
                        let theImage = UIImageView()
                        theImage.sd_setImage(with: url)
                        let account = UIAction(title: user.displayName ?? "", subtitle: "@\(user.actorHandle)", image: theImage.image?.withRoundedCorners() ?? UIImage(systemName: ""), identifier: nil) { action in
                            self.currentSelectedUser = user.actorHandle
                            self.accountPicker()
                            self.createToolbar()
                            Task {
                                await self.authenticate()
                            }
                        }
                        if user.actorHandle == currentSelectedUser {
                            account.state = .on
                        } else {
                            account.state = .off
                        }
                        menuActions.append(account)
                    }
                }
                let menu = UIMenu(title: "Select an account to post from...", options: [.displayInline], children: menuActions)
                cell.avatar.menu = menu
                cell.avatar.showsMenuAsPrimaryAction = true
            }
        }
    }
    
    func authenticate() async {
        let user = GlobalStruct.allUsers.first { x in
            x.username == self.currentSelectedUser
        }
        do {
            try await config.authenticate(with: user?.username ?? "", password: user?.password ?? "")
            self.atProto = await ATProtoKit(sessionConfiguration: config)
            let y = try await self.atProto?.getProfile(for: user?.username ?? "")
            self.currentUser = y
        } catch {
            print("Error authenticating: \(error)")
        }
    }
    
    // text handling
    
    func textViewDidChange(_ textView: UITextView) {
        currentPostText = textView.text
        parseText()
        
        var inSearch1: Bool = false
        var inSearch2: Bool = false
        
        // find @ mentions
        let trimmedToCursor = textView.text[..<(textView.cursorIndex ?? textView.text.endIndex)]
        let trimSpot = trimmedToCursor.lastIndex(of: "@") ?? textView.text.endIndex
        if trimSpot <= (textView.cursorIndex ?? textView.text.endIndex) {
            let trimmed = trimmedToCursor[trimSpot..<(textView.cursorIndex ?? textView.text.endIndex)]
            if !trimmed.contains(" ") && (trimmed.contains("@")) {
                inSearch1 = true
                // search for users
                self.trimmedAtString = String(trimmed.dropFirst())
                self.pendingRequestWorkItem?.cancel()
                let requestWorkItem = DispatchWorkItem { [weak self] in
                    self?.searchForUsers(self?.trimmedAtString ?? "")
                }
                self.pendingRequestWorkItem = requestWorkItem
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: requestWorkItem)
            } else {
                inSearch1 = false
                // show default toolbar
                if inSearch1 == false && inSearch2 == false {
                    self.pendingRequestWorkItem?.cancel()
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                        cell.post.inputAccessoryView = self.formatToolbar
                        cell.post.reloadInputViews()
                    }
                }
            }
        } else {
            inSearch1 = false
            // show default toolbar
            if inSearch1 == false && inSearch2 == false {
                self.pendingRequestWorkItem?.cancel()
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                    cell.post.inputAccessoryView = self.formatToolbar
                    cell.post.reloadInputViews()
                }
            }
        }
        
        // find # tags
        let trimSpot2 = trimmedToCursor.lastIndex(of: "#") ?? textView.text.endIndex
        if trimSpot2 <= (textView.cursorIndex ?? textView.text.endIndex) {
            let trimmed = trimmedToCursor[trimSpot2..<(textView.cursorIndex ?? textView.text.endIndex)]
            if !trimmed.contains(" ") && (trimmed.contains("#")) {
                inSearch2 = true
            } else {
                inSearch2 = false
            }
        } else {
            inSearch2 = false
        }
    }
    
    func searchForUsers(_ user0: String) {
        Task {
            do {
                if let atProto = self.atProto {
                    let x = try await atProto.searchActors(matching: user0)
                    let zz = x.actors
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.formatToolbar2.items = []
                        var allWidths: CGFloat = 0
                        self.userItemsAll = zz
                        for (c,_) in zz.enumerated() {
                            let view = UIButton()
                            
                            let im = UIButton()
                            im.isUserInteractionEnabled = false
                            im.frame = CGRect(x: 0, y: 10, width: (self.formatToolbar2.frame.size.height) - 20, height: (self.formatToolbar2.frame.size.height) - 20)
                            im.layer.cornerRadius = ((self.formatToolbar2.frame.size.height) - 20)/2
                            im.imageView?.contentMode = .scaleAspectFill
                            if let ur = zz[c].avatarImageURL {
                                im.sd_setImage(with: ur, for: .normal)
                            }
                            im.layer.masksToBounds = true
                            view.addSubview(im)
                            
                            let titl = UILabel()
                            titl.text = "@\(zz[c].actorHandle)"
                            titl.textColor = GlobalStruct.baseTint
                            titl.frame = CGRect(x: (self.formatToolbar2.frame.size.height) - 10, y: 0, width: (self.view.bounds.width) - (self.formatToolbar2.frame.size.height), height: (self.formatToolbar2.frame.size.height))
                            titl.sizeToFit()
                            titl.frame.size.height = self.formatToolbar2.frame.size.height
                            titl.frame.origin.x = (self.formatToolbar2.frame.size.height) - 10
                            view.addSubview(titl)
                            
                            let wid = im.frame.size.width + titl.frame.size.width + 30
                            view.frame = CGRect(x: 0, y: 0, width: wid, height: (self.formatToolbar2.frame.size.height))
                            view.tag = c
                            view.addTarget(self, action: #selector(self.tapAccount(_:)), for: .touchUpInside)
                            let x0 = UIBarButtonItem(customView: view)
                            x0.width = wid
                            allWidths += wid
                            x0.accessibilityLabel = "@\(zz[c].actorHandle)"
                            self.formatToolbar2.items?.append(x0)
                        }
                        self.formatToolbar2.sizeToFit()
                        if (allWidths + 40) < self.view.bounds.width {
                            self.formatToolbar2.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: (self.formatToolbar2.frame.size.height) + 1)
                        } else {
                            self.formatToolbar2.frame = CGRect(x: 0, y: 0, width: allWidths + 40, height: (self.formatToolbar2.frame.size.height) + 1)
                        }
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
                            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.formatToolbar2.frame.height + 1))
                            containerView.backgroundColor = GlobalStruct.backgroundTint

                            self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height))
                            self.scrollView.backgroundColor = GlobalStruct.backgroundTint
                            self.scrollView.showsVerticalScrollIndicator = false
                            self.scrollView.showsHorizontalScrollIndicator = false
                            self.scrollView.contentSize = self.formatToolbar2.frame.size
                            self.scrollView.addSubview(self.formatToolbar2)
                            containerView.addSubview(self.scrollView)
                            
                            let border = UIView(frame: CGRect(x: 0, y: 0, width: containerView.bounds.width, height: 0.5))
                            border.backgroundColor = UIColor.separator
                            containerView.addSubview(border)

                            cell.post.inputAccessoryView = containerView
                            cell.post.reloadInputViews()
                        }
                    }
                }
            } catch {
                print("Error fetching users: \(error)")
            }
        }
    }
    
    @objc func tapAccount(_ sender: UIButton) {
        defaultHaptics()
        self.pendingRequestWorkItem?.cancel()
        let searchItem1 = self.userItemsAll[sender.tag].actorHandle
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            if let selectedRange = cell.post.selectedTextRange {
                let cursorPosition = cell.post.offset(from: cell.post.beginningOfDocument, to: selectedRange.start)
                if let currPosition = cell.post.position(from: cell.post.beginningOfDocument, offset: cursorPosition) {
                    let tag = self.getCurrentTagOrUser(isTag: false) ?? ""
                    if let currTagPosition = cell.post.position(from: cell.post.beginningOfDocument, offset: cursorPosition - tag.count) {
                        if let textRange = cell.post.textRange(from: currTagPosition, to: currPosition) {
                            if let range = cell.post.text.rangeFromNSRange(nsRange: self.rangeFromTextRange(textRange: textRange, textView: cell.post)) {
                                cell.post.text.replaceSubrange(range, with: "\(searchItem1) ")
                            }
                        }
                    }
                    self.parseText()
                }
                let cursorDiff = Array(searchItem1).count - Array(self.trimmedAtString).count + 1
                if let newPosition = cell.post.position(from: cell.post.beginningOfDocument, offset: cursorPosition + cursorDiff) {
                    if newPosition != cell.post.endOfDocument {
                        cell.post.selectedTextRange = cell.post.textRange(from: newPosition, to: newPosition)
                    }
                }
            }
            // show default toolbar
            cell.post.inputAccessoryView = self.formatToolbar
            cell.post.reloadInputViews()
        }
    }
    
    func getCurrentTagOrUser(isTag: Bool) -> String? {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            let selectedRange: UITextRange? = cell.post.selectedTextRange
            var cursorOffset: Int? = nil
            if let aStart = selectedRange?.start {
                cursorOffset = cell.post.offset(from: cell.post.beginningOfDocument, to: aStart)
            }
            let text = cell.post.text
            let substring = (text as NSString?)?.substring(to: cursorOffset!)
            if isTag {
                let tag = substring?.components(separatedBy: "#").last
                return tag
            } else {
                let user = substring?.components(separatedBy: "@").last
                return user
            }
        } else {
            return nil
        }
    }
    
    func rangeFromTextRange(textRange: UITextRange, textView: UITextView) -> NSRange {
        let location: Int = textView.offset(from: textView.beginningOfDocument, to: textRange.start)
        let length: Int = textView.offset(from: textRange.start, to: textRange.end)
        return NSMakeRange(location, length)
    }
    
    func parseText() {
        if currentPostText == "" {
            disablePosting()
        } else {
            enablePosting()
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            remainingCharacters = GlobalStruct.currentMaxChars - currentPostText.count
            updateCharacterCounter()
            var cursorPosition: Int = 0
            if let selectedRange = cell.post.selectedTextRange {
                cursorPosition = cell.post.offset(from: cell.post.beginningOfDocument, to: selectedRange.start)
            }
            let pattern = "(?:|$)#[\\p{L}0-9_]*|\\B\\@([a-zA-Z0-9_.-]*)([\\w@a-zA-Z0-9_.-]+)|\\@|(https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|www\\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\\.[^\\s]{2,}|https?:\\/\\/(?:www\\.|(?!www))[a-zA-Z0-9]+\\.[^\\s]{2,}|www\\.[a-zA-Z0-9]+\\.[^\\s]{2,})"
            let inString = cell.post.text ?? ""
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSMakeRange(0, inString.count)
            let matches = (regex?.matches(in: inString, options: [], range: range))!
            let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular), NSAttributedString.Key.foregroundColor : UIColor.label]
            let attrString = NSMutableAttributedString(string: inString, attributes: attrs)
            for match in matches.reversed() {
                attrString.addAttribute(NSAttributedString.Key.foregroundColor , value: GlobalStruct.baseTint, range: match.range(at: 0))
            }
            cell.post.attributedText = attrString
            if let newPosition = cell.post.position(from: cell.post.beginningOfDocument, offset: cursorPosition) {
                cell.post.selectedTextRange = cell.post.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    func updateCharacterCounter() {
        counterButton.title = "\(remainingCharacters)"
        counterButton.accessibilityLabel = "Remaining characters: \(remainingCharacters)"
        if remainingCharacters < 0 {
            counterButton.tintColor = UIColor.systemRed
            disablePosting()
        } else if remainingCharacters < 11 {
            counterButton.tintColor = UIColor.systemOrange
        } else {
            counterButton.tintColor = UIColor.placeholderText
        }
    }
    
    func characterBeforeCursor() -> String? {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ComposeCell {
            if let cursorRange = cell.post.selectedTextRange {
                if let newPosition = cell.post.position(from: cursorRange.start, offset: -1) {
                    let range = cell.post.textRange(from: newPosition, to: cursorRange.start)
                    return cell.post.text(in: range!)
                }
            }
        }
        return nil
    }
    
    // post and toolbar handling
    
    func enablePosting() {
        canPost = true
        let button = CustomButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(GlobalStruct.baseTint, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(self.submitPost), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func disablePosting() {
        canPost = false
        let button = CustomButton(type: .system)
        button.setTitle("Post", for: .normal)
        button.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.removeTarget(self, action: #selector(self.submitPost), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func createToolbar() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        let fixedSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedSpacer.width = 10
        let flexibleSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        formatToolbar.tintColor = GlobalStruct.baseTint
        formatToolbar.barStyle = UIBarStyle.default
        formatToolbar.isTranslucent = false
        formatToolbar.barTintColor = GlobalStruct.backgroundTint
        
        formatToolbar2.tintColor = GlobalStruct.baseTint
        formatToolbar2.barStyle = UIBarStyle.default
        formatToolbar2.isTranslucent = false
        formatToolbar2.barTintColor = GlobalStruct.backgroundTint
        
        // media buttons
        
        var photoButton = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.galleryTapped))
        photoButton.accessibilityLabel = "Add Media"
        
        var cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.cameraTapped))
        cameraButton.accessibilityLabel = "Add from Camera"
        
        var gifButton = UIBarButtonItem(image: UIImage(systemName: "paperclip", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
        gifButton.accessibilityLabel = "Add GIF"
        
        if isQuote || attachedMedia.count == 4 {
            photoButton = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint.withAlphaComponent(0.38), renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
            photoButton.isEnabled = false
            cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint.withAlphaComponent(0.38), renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
            cameraButton.isEnabled = false
            gifButton = UIBarButtonItem(image: UIImage(systemName: "paperclip", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint.withAlphaComponent(0.38), renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
            gifButton.isEnabled = false
        }
        
        // visibility button
        
        let visibilityButton = UIBarButtonItem(image: UIImage(systemName: "questionmark.bubble", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
        visibilityButton.accessibilityLabel = "Who can reply?"
        
        let visibilityOption2 = UIAction(title: "Mentioned Users", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            if let index = whoCanReply.firstIndex(of: .allowMentions) {
                whoCanReply.remove(at: index)
            } else {
                whoCanReply.append(.allowMentions)
            }
            createToolbar()
        }
        if let _ = whoCanReply.firstIndex(of: .allowMentions) {
            visibilityOption2.state = .on
        } else {
            visibilityOption2.state = .off
        }
        let visibilityOption3 = UIAction(title: "Users You Follow", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            if let index = whoCanReply.firstIndex(of: .allowFollowing) {
                whoCanReply.remove(at: index)
            } else {
                whoCanReply.append(.allowFollowing)
            }
            createToolbar()
        }
        if let _ = whoCanReply.firstIndex(of: .allowFollowing) {
            visibilityOption3.state = .on
        } else {
            visibilityOption3.state = .off
        }
        let visibilityOption4 = UIAction(title: "Your Followers", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            if let index = whoCanReply.firstIndex(of: .allowFollowers) {
                whoCanReply.remove(at: index)
            } else {
                whoCanReply.append(.allowFollowers)
            }
            createToolbar()
        }
        if let _ = whoCanReply.firstIndex(of: .allowFollowers) {
            visibilityOption4.state = .on
        } else {
            visibilityOption4.state = .off
        }
        let itemMenu2b = UIMenu(title: "", options: [.displayInline], children: [visibilityOption2, visibilityOption3, visibilityOption4])
        
        let visibilityOption5 = UIAction(title: "Everybody", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            whoCanReply = [.allowMentions, .allowFollowing, .allowFollowers]
            createToolbar()
        }
        if Set(whoCanReply) == Set([.allowMentions, .allowFollowing, .allowFollowers]) {
            visibilityOption5.state = .on
        } else {
            visibilityOption5.state = .off
        }
        let visibilityOption6 = UIAction(title: "Nobody", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            whoCanReply = []
            createToolbar()
        }
        if whoCanReply == [] {
            visibilityOption6.state = .on
        } else {
            visibilityOption6.state = .off
        }
        let itemMenu2c = UIMenu(title: "", options: [.displayInline, .singleSelection], children: [visibilityOption5, visibilityOption6])
        let itemMenu2 = UIMenu(title: "Who can reply?", options: [.displayInline], children: [itemMenu2b, itemMenu2c])
        
        visibilityButton.menu = itemMenu2
        
        // language button
        
        let languageButton = UIBarButtonItem(image: UIImage(systemName: "globe", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
        languageButton.accessibilityLabel = "Post language"
        
        let languageOption1 = UIAction(title: "English", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            currentLocale = "en_EN"
            createToolbar()
        }
        if currentLocale == "en_EN" {
            languageOption1.state = .on
        } else {
            languageOption1.state = .off
        }
        let languageOption2 = UIAction(title: "Japanese", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            currentLocale = "ja_JP"
            createToolbar()
        }
        if currentLocale == "ja_JP" {
            languageOption2.state = .on
        } else {
            languageOption2.state = .off
        }
        let languageOption3 = UIAction(title: "Portuguese", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            currentLocale = "pt_PT"
            createToolbar()
        }
        if currentLocale == "pt_PT" {
            languageOption3.state = .on
        } else {
            languageOption3.state = .off
        }
        let languageOption4 = UIAction(title: "German", image: UIImage(systemName: ""), identifier: nil) { [weak self] action in
            guard let self else { return }
            currentLocale = "de_DE"
            createToolbar()
        }
        if currentLocale == "de_DE" {
            languageOption4.state = .on
        } else {
            languageOption4.state = .off
        }
        let itemMenu3 = UIMenu(title: "Post language", options: [.displayInline], children: [languageOption1, languageOption2, languageOption3, languageOption4])
        languageButton.menu = itemMenu3
        
        // drafts button
        
        let draftsButton = UIBarButtonItem(image: UIImage(systemName: "doc.text", withConfiguration: symbolConfig)!.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(self.draftsTapped))
        draftsButton.accessibilityLabel = "Drafts"
        
        // counter
        
        counterButton = UIBarButtonItem(title: "\(remainingCharacters)", style: .plain, target: self, action: nil)
        if remainingCharacters < 0 {
            counterButton.tintColor = UIColor.systemRed
            disablePosting()
        } else if remainingCharacters < 11 {
            counterButton.tintColor = UIColor.systemOrange
        } else {
            counterButton.tintColor = UIColor.placeholderText
        }
        counterButton.accessibilityLabel = "Remaining characters: \(remainingCharacters)"
        
        // layout toolbar
        
        var theItems: [UIBarButtonItem] = []
        theItems.append(contentsOf: [photoButton, fixedSpacer, cameraButton, fixedSpacer, visibilityButton, fixedSpacer, languageButton, fixedSpacer])
        if GlobalStruct.drafts.count > 0 {
            theItems.append(contentsOf: [draftsButton, fixedSpacer])
        }
        theItems.append(contentsOf: [flexibleSpacer, counterButton])
        formatToolbar.items = theItems
        formatToolbar.sizeToFit()
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            cell.post.inputAccessoryView = formatToolbar
        }
        
        // media
        
        mediaContainer2.frame.origin.x = 74
        mediaContainer2.frame.origin.y = view.bounds.height - formatToolbar.bounds.size.height - self.keyHeight - 70
        mediaContainer2.frame.size.width = 60
        mediaContainer2.frame.size.height = 60
        mediaContainer2.backgroundColor = .white
        mediaContainer2.layer.cornerRadius = 10
        mediaContainer2.layer.cornerCurve = .continuous
        mediaContainer2.layer.shadowColor = UIColor.black.cgColor
        mediaContainer2.layer.shadowOffset = CGSize(width: 0, height: 6)
        mediaContainer2.layer.shadowRadius = 12
        mediaContainer2.layer.shadowOpacity = 0.32
        if attachedMedia.isEmpty {
            mediaContainer2.alpha = 0
        }
        mediaContainer2.isUserInteractionEnabled = true
        view.addSubview(mediaContainer2)
        
        mediaImage2.frame = CGRect(x: 2, y: 2, width: 56, height: 56)
        mediaImage2.contentMode = .scaleAspectFill
        mediaImage2.layer.masksToBounds = true
        mediaImage2.layer.cornerRadius = 7
        mediaImage2.layer.cornerCurve = .continuous
        mediaImage2.isUserInteractionEnabled = false
        mediaContainer2.addSubview(mediaImage2)
        
        mediaContainer1.frame.origin.x = 16
        mediaContainer1.frame.origin.y = view.bounds.height - formatToolbar.bounds.size.height - self.keyHeight - 70
        mediaContainer1.frame.size.width = 60
        mediaContainer1.frame.size.height = 60
        mediaContainer1.backgroundColor = .white
        mediaContainer1.layer.cornerRadius = 10
        mediaContainer1.layer.cornerCurve = .continuous
        mediaContainer1.layer.shadowColor = UIColor.black.cgColor
        mediaContainer1.layer.shadowOffset = CGSize(width: 0, height: 6)
        mediaContainer1.layer.shadowRadius = 12
        mediaContainer1.layer.shadowOpacity = 0.32
        if attachedMedia.isEmpty {
            mediaContainer1.alpha = 0
        }
        mediaContainer1.isUserInteractionEnabled = true
        view.addSubview(mediaContainer1)
        
        mediaImage1.frame = CGRect(x: 2, y: 2, width: 56, height: 56)
        mediaImage1.contentMode = .scaleAspectFill
        mediaImage1.layer.masksToBounds = true
        mediaImage1.layer.cornerRadius = 7
        mediaImage1.layer.cornerCurve = .continuous
        mediaImage1.isUserInteractionEnabled = false
        mediaContainer1.addSubview(mediaImage1)
        
        mediaContainer4.frame.origin.x = 190
        mediaContainer4.frame.origin.y = view.bounds.height - formatToolbar.bounds.size.height - self.keyHeight - 70
        mediaContainer4.frame.size.width = 60
        mediaContainer4.frame.size.height = 60
        mediaContainer4.backgroundColor = .white
        mediaContainer4.layer.cornerRadius = 10
        mediaContainer4.layer.cornerCurve = .continuous
        mediaContainer4.layer.shadowColor = UIColor.black.cgColor
        mediaContainer4.layer.shadowOffset = CGSize(width: 0, height: 6)
        mediaContainer4.layer.shadowRadius = 12
        mediaContainer4.layer.shadowOpacity = 0.32
        if attachedMedia.isEmpty {
            mediaContainer4.alpha = 0
        }
        mediaContainer4.isUserInteractionEnabled = true
        view.addSubview(mediaContainer4)
        
        mediaImage4.frame = CGRect(x: 2, y: 2, width: 56, height: 56)
        mediaImage4.contentMode = .scaleAspectFill
        mediaImage4.layer.masksToBounds = true
        mediaImage4.layer.cornerRadius = 7
        mediaImage4.layer.cornerCurve = .continuous
        mediaImage4.isUserInteractionEnabled = false
        mediaContainer4.addSubview(mediaImage4)
        
        mediaContainer3.frame.origin.x = 132
        mediaContainer3.frame.origin.y = view.bounds.height - formatToolbar.bounds.size.height - self.keyHeight - 70
        mediaContainer3.frame.size.width = 60
        mediaContainer3.frame.size.height = 60
        mediaContainer3.backgroundColor = .white
        mediaContainer3.layer.cornerRadius = 10
        mediaContainer3.layer.cornerCurve = .continuous
        mediaContainer3.layer.shadowColor = UIColor.black.cgColor
        mediaContainer3.layer.shadowOffset = CGSize(width: 0, height: 6)
        mediaContainer3.layer.shadowRadius = 12
        mediaContainer3.layer.shadowOpacity = 0.32
        if attachedMedia.isEmpty {
            mediaContainer3.alpha = 0
        }
        mediaContainer3.isUserInteractionEnabled = true
        view.addSubview(mediaContainer3)
        
        mediaImage3.frame = CGRect(x: 2, y: 2, width: 56, height: 56)
        mediaImage3.contentMode = .scaleAspectFill
        mediaImage3.layer.masksToBounds = true
        mediaImage3.layer.cornerRadius = 7
        mediaImage3.layer.cornerCurve = .continuous
        mediaImage3.isUserInteractionEnabled = false
        mediaContainer3.addSubview(mediaImage3)
    }
    
    func addMediaOptions(_ index: Int = 0) {
        var imageView = UIImageView()
        if index == 0 {
            imageView = mediaImage1
        } else if index == 1 {
            imageView = mediaImage2
        } else if index == 2 {
            imageView = mediaImage3
        } else if index == 3 {
            imageView = mediaImage4
        }
        let view01 = UIAction(title: "Alt Text", image: UIImage(systemName: "applepencil.and.scribble"), identifier: nil) { [weak self] action in
            guard let self else { return }
            let vc = AddAltTextViewController()
            GlobalStruct.composerMediaIndex = index
            vc.imageIndex = GlobalStruct.composerMediaIndex
            vc.theImage = imageView.image
            if mediaAltText[GlobalStruct.composerMediaIndex] != nil {
                vc.fromEdit = true
                vc.imageAltText = mediaAltText[GlobalStruct.composerMediaIndex] ?? ""
            }
            vc.fromVideo = hasVideo
            show(SloppySwipingNav(rootViewController: vc), sender: self)
        }
        view01.accessibilityLabel = "Alt Text"
        let view02 = UIAction(title: "View", image: UIImage(systemName: "eye"), identifier: nil) { [weak self] action in
        guard let self else { return }
            if hasVideo {
                var player: AVPlayer?
                player = AVPlayer(url: self.videoURL)
                let playerView = PlayerView()
                playerView.player = player
                playerView.playerLayer?.videoGravity = .resizeAspectFill
                let player2 = playerView.player
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player2
                playerViewController.allowsPictureInPicturePlayback = true
                playerViewController.delegate = self
                getTopMostViewController()?.present(playerViewController, animated: true) {
                    player2?.play()
                }
            } else {
                GlobalStruct.fromComposerMedia = true
                if index == 0 {
                    GlobalStruct.composerMediaIndex = 0
                    let resetRotation = CABasicAnimation(keyPath: "transform.rotation.z")
                    resetRotation.fromValue = mediaContainer1.layer.presentation()?.value(forKeyPath: "transform.rotation.z") ?? 0
                    resetRotation.toValue = 0
                    resetRotation.duration = 0.2
                    resetRotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    resetRotation.fillMode = .forwards
                    resetRotation.isRemovedOnCompletion = false
                    mediaContainer1.layer.add(resetRotation, forKey: "resetRotation")
                } else if index == 1 {
                    GlobalStruct.composerMediaIndex = 1
                    let resetRotation = CABasicAnimation(keyPath: "transform.rotation.z")
                    resetRotation.fromValue = mediaContainer2.layer.presentation()?.value(forKeyPath: "transform.rotation.z") ?? 0
                    resetRotation.toValue = 0
                    resetRotation.duration = 0.2
                    resetRotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    resetRotation.fillMode = .forwards
                    resetRotation.isRemovedOnCompletion = false
                    mediaContainer2.layer.add(resetRotation, forKey: "resetRotation")
                } else if index == 2 {
                    GlobalStruct.composerMediaIndex = 2
                    let resetRotation = CABasicAnimation(keyPath: "transform.rotation.z")
                    resetRotation.fromValue = mediaContainer3.layer.presentation()?.value(forKeyPath: "transform.rotation.z") ?? 0
                    resetRotation.toValue = 0
                    resetRotation.duration = 0.2
                    resetRotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    resetRotation.fillMode = .forwards
                    resetRotation.isRemovedOnCompletion = false
                    mediaContainer3.layer.add(resetRotation, forKey: "resetRotation")
                } else if index == 3 {
                    GlobalStruct.composerMediaIndex = 3
                    let resetRotation = CABasicAnimation(keyPath: "transform.rotation.z")
                    resetRotation.fromValue = mediaContainer4.layer.presentation()?.value(forKeyPath: "transform.rotation.z") ?? 0
                    resetRotation.toValue = 0
                    resetRotation.duration = 0.2
                    resetRotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    resetRotation.fillMode = .forwards
                    resetRotation.isRemovedOnCompletion = false
                    mediaContainer4.layer.add(resetRotation, forKey: "resetRotation")
                }
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(imageView.image ?? UIImage())
                photo.shouldCachePhotoURLImage = true
                photo.contentMode = .scaleAspectFill
                images.append(photo)
                let originImage = imageView.image ?? UIImage()
                let browser = SKPhotoBrowser(originImage: originImage, photos: images, animatedFromView: imageView, imageText: "", imageText2: 0, imageText3: 0, imageText4: "")
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
        view02.accessibilityLabel = "View"
        let view03 = UIAction(title: "Remove", image: UIImage(systemName: "trash"), identifier: nil) { [weak self] action in
        guard let self else { return }
            defaultHaptics()
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 1.0
            fade.toValue = 0.0
            let group = CAAnimationGroup()
            group.animations = [fade]
            group.duration = 0.01
            group.timingFunction = CAMediaTimingFunction(name: .default)
            group.fillMode = .forwards
            group.isRemovedOnCompletion = false
            if attachedMedia.count == 4 {
                mediaContainer4.layer.add(group, forKey: "rotateScaleFade")
            } else if attachedMedia.count == 3 {
                mediaContainer3.layer.add(group, forKey: "rotateScaleFade")
            } else if attachedMedia.count == 2 {
                mediaContainer2.layer.add(group, forKey: "rotateScaleFade")
            } else if attachedMedia.count == 1 {
                mediaContainer1.layer.add(group, forKey: "rotateScaleFade")
            }
            if hasVideo {
                videoData = Data()
                mediaAltText.removeAll()
                mediaContainer1.layer.add(group, forKey: "rotateScaleFade")
                mediaImage1.image = UIImage()
            } else {
                if index == 0 {
                    attachedMedia.remove(at: 0)
                    mediaAltText.remove(at: 0)
                    mediaImage1.image = mediaImage2.image
                    mediaImage2.image = mediaImage3.image
                    mediaImage3.image = mediaImage4.image
                    mediaImage4.image = UIImage()
                } else if index == 1 {
                    attachedMedia.remove(at: 1)
                    mediaAltText.remove(at: 1)
                    mediaImage2.image = mediaImage3.image
                    mediaImage3.image = mediaImage4.image
                    mediaImage4.image = UIImage()
                } else if index == 2 {
                    attachedMedia.remove(at: 2)
                    mediaAltText.remove(at: 2)
                    mediaImage3.image = mediaImage4.image
                    mediaImage4.image = UIImage()
                } else if index == 3 {
                    attachedMedia.remove(at: 3)
                    mediaAltText.remove(at: 3)
                    mediaImage4.image = UIImage()
                }
            }
            createToolbar()
        }
        view03.accessibilityLabel = "Remove"
        view03.attributes = .destructive
        let itemMenu1 = UIMenu(title: "", options: [.displayInline], children: [view01, view02, view03])
        if index == 0 {
            mediaContainer1.menu = itemMenu1
            mediaContainer1.showsMenuAsPrimaryAction = true
        } else if index == 1 {
            mediaContainer2.menu = itemMenu1
            mediaContainer2.showsMenuAsPrimaryAction = true
        } else if index == 2 {
            mediaContainer3.menu = itemMenu1
            mediaContainer3.showsMenuAsPrimaryAction = true
        } else if index == 3 {
            mediaContainer4.menu = itemMenu1
            mediaContainer4.showsMenuAsPrimaryAction = true
        }
    }
    
    @objc func rotateComposerMedia() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        if GlobalStruct.composerMediaIndex == 0 {
            rotation.toValue = -CGFloat.pi / 26
        } else if GlobalStruct.composerMediaIndex == 1 {
            rotation.toValue = CGFloat.pi / 20
        } else if GlobalStruct.composerMediaIndex == 2 {
            rotation.toValue = -CGFloat.pi / 44
        } else {
            rotation.toValue = CGFloat.pi / 16
        }
        let group = CAAnimationGroup()
        group.animations = [rotation]
        group.duration = 0.3
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        if GlobalStruct.composerMediaIndex == 0 {
            mediaContainer1.layer.add(group, forKey: "rotateScaleFade")
        } else if GlobalStruct.composerMediaIndex == 1 {
            mediaContainer2.layer.add(group, forKey: "rotateScaleFade")
        } else if GlobalStruct.composerMediaIndex == 2 {
            mediaContainer3.layer.add(group, forKey: "rotateScaleFade")
        } else {
            mediaContainer4.layer.add(group, forKey: "rotateScaleFade")
        }
    }
    
    @objc func galleryTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = GlobalStruct.currentMaxMediaCount
                configuration.filter = .any(of: [.images, .screenshots, .depthEffectPhotos, .videos, .screenRecordings, .cinematicVideos, .slomoVideos, .timelapseVideos])
                self.photoPickerView = PHPickerViewController(configuration: configuration)
                self.photoPickerView.modalPresentationStyle = .popover
                self.photoPickerView.delegate = self
                if let presenter = self.photoPickerView.popoverPresentationController {
                    presenter.sourceView = self.view
                    presenter.sourceRect = self.view.bounds
                }
                if let sheet = self.photoPickerView.popoverPresentationController?.adaptiveSheetPresentationController {
                    sheet.detents = [.large()]
                }
                self.present(self.photoPickerView, animated: true, completion: nil)
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        self.disablePosting()
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            cell.post.becomeFirstResponder()
        }
        _ = results.map({ x in
            if x.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                x.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.gif.identifier) { data, error in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.hasGIF = true
                        self.hasVideo = false
                    }
                }
            } else {
                if x.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    x.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            self.hasGIF = false
                            self.hasVideo = false
                            if let photoToAttach = image as? UIImage {
                                let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
                                rotation.fromValue = 0
                                if attachedMedia.count == 0 {
                                    rotation.toValue = -CGFloat.pi / 26
                                } else if attachedMedia.count == 1 {
                                    rotation.toValue = CGFloat.pi / 20
                                } else if attachedMedia.count == 2 {
                                    rotation.toValue = -CGFloat.pi / 44
                                } else if attachedMedia.count == 3 {
                                    rotation.toValue = CGFloat.pi / 16
                                }
                                let scale = CABasicAnimation(keyPath: "transform.scale")
                                scale.fromValue = 0.4
                                scale.toValue = 1.0
                                let fade = CABasicAnimation(keyPath: "opacity")
                                fade.fromValue = 0.0
                                fade.toValue = 1.0
                                let group = CAAnimationGroup()
                                group.animations = [rotation, scale, fade]
                                group.duration = 0.5
                                group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                                group.fillMode = .forwards
                                group.isRemovedOnCompletion = false
                                if attachedMedia.count == 0 {
                                    mediaContainer1.layer.add(group, forKey: "rotateScaleFade")
                                    mediaImage1.image = photoToAttach
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.mediaContainer1.alpha = 1
                                        self.addMediaOptions(0)
                                    }
                                } else if attachedMedia.count == 1 {
                                    mediaContainer2.layer.add(group, forKey: "rotateScaleFade")
                                    mediaImage2.image = photoToAttach
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.mediaContainer2.alpha = 1
                                        self.addMediaOptions(1)
                                    }
                                } else if attachedMedia.count == 2 {
                                    mediaContainer3.layer.add(group, forKey: "rotateScaleFade")
                                    mediaImage3.image = photoToAttach
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.mediaContainer3.alpha = 1
                                        self.addMediaOptions(2)
                                    }
                                } else if attachedMedia.count == 3 {
                                    mediaContainer4.layer.add(group, forKey: "rotateScaleFade")
                                    mediaImage4.image = photoToAttach
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.mediaContainer4.alpha = 1
                                        self.addMediaOptions(3)
                                    }
                                }
                                if attachedMedia.count < 4 {
                                    attachedMedia.append(photoToAttach)
                                    mediaAltText.append(nil)
                                    createToolbar()
                                }
                            }
                        }
                    }
                }
                if x.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    x.itemProvider.loadDataRepresentation(forTypeIdentifier: "public.movie") { data, error in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            self.hasGIF = false
                            self.hasVideo = true
                            self.videoData = data ?? Data()
                            self.removeAllMedia()
                            self.mediaAltText.append(nil)
                            self.createToolbar()
                            self.saveMovieDataToFile(dataRepresentation: data ?? Data()) { fileURL in
                                if let url = fileURL {
                                    self.videoURL = url
                                    self.tryDisplayThumbnail(url: url as URL)
                                }
                            }
                        }
                    }
                    x.itemProvider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: [:]) { [self] (videoURL, error) in
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            self.hasGIF = false
                            self.hasVideo = true
                            self.removeAllMedia()
                            self.mediaAltText.append(nil)
                            self.createToolbar()
                            if let url = videoURL as? URL {
                                self.videoURL = url
                                Task {
                                    do {
                                        let videoData = try NSData(contentsOf: url as URL, options: .mappedIfSafe)
                                        self.videoData = videoData as Data
                                        self.tryDisplayThumbnail(url: url as URL)
                                    } catch {
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    @objc func cameraTapped() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.photoPickerView2.delegate = self
                        self.photoPickerView2.sourceType = .camera
                        self.photoPickerView2.mediaTypes = [UTType.movie.identifier, UTType.image.identifier]
                        self.photoPickerView2.allowsEditing = false
                        self.photoPickerView2.videoQuality = .typeHigh
                        self.present(self.photoPickerView2, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let alert = UIAlertController(title: "Oops!", message: "Looks like camera access is denied. Please enable it again via Settings to attach media via the camera.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                                
                            })
                        }
                    })
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        self.disablePosting()
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ComposeCell {
            cell.post.becomeFirstResponder()
        }
        if let _ = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if let photoToAttach = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.hasGIF = false
                    self.hasVideo = false
                    let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
                    rotation.fromValue = 0
                    if attachedMedia.count == 0 {
                        rotation.toValue = -CGFloat.pi / 26
                    } else if attachedMedia.count == 1 {
                        rotation.toValue = CGFloat.pi / 20
                    } else if attachedMedia.count == 2 {
                        rotation.toValue = -CGFloat.pi / 44
                    } else if attachedMedia.count == 3 {
                        rotation.toValue = CGFloat.pi / 16
                    }
                    let scale = CABasicAnimation(keyPath: "transform.scale")
                    scale.fromValue = 0.4
                    scale.toValue = 1.0
                    let fade = CABasicAnimation(keyPath: "opacity")
                    fade.fromValue = 0.0
                    fade.toValue = 1.0
                    let group = CAAnimationGroup()
                    group.animations = [rotation, scale, fade]
                    group.duration = 0.5
                    group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    group.fillMode = .forwards
                    group.isRemovedOnCompletion = false
                    if attachedMedia.count == 0 {
                        mediaContainer1.layer.add(group, forKey: "rotateScaleFade")
                        mediaImage1.image = photoToAttach
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.mediaContainer1.alpha = 1
                            self.addMediaOptions(0)
                        }
                    } else if attachedMedia.count == 1 {
                        mediaContainer2.layer.add(group, forKey: "rotateScaleFade")
                        mediaImage2.image = photoToAttach
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.mediaContainer2.alpha = 1
                            self.addMediaOptions(1)
                        }
                    } else if attachedMedia.count == 2 {
                        mediaContainer3.layer.add(group, forKey: "rotateScaleFade")
                        mediaImage3.image = photoToAttach
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.mediaContainer3.alpha = 1
                            self.addMediaOptions(2)
                        }
                    } else if attachedMedia.count == 3 {
                        mediaContainer4.layer.add(group, forKey: "rotateScaleFade")
                        mediaImage4.image = photoToAttach
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.mediaContainer4.alpha = 1
                            self.addMediaOptions(3)
                        }
                    }
                    if attachedMedia.count < 4 {
                        attachedMedia.append(photoToAttach)
                        mediaAltText.append(nil)
                        createToolbar()
                    }
                }
            } else {
                if let url = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.hasGIF = false
                        self.hasVideo = true
                        self.removeAllMedia()
                        self.mediaAltText.append(nil)
                        self.createToolbar()
                        self.videoURL = url as URL
                        do {
                            let videoData = try NSData(contentsOf: url as URL, options: .mappedIfSafe)
                            self.videoData = videoData as Data
                            self.tryDisplayThumbnail(url: url as URL)
                        } catch {
                            return
                        }
                    }
                }
            }
        }
    }
    
    func removeAllMedia() {
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.0
        let group = CAAnimationGroup()
        group.animations = [fade]
        group.duration = 0.01
        group.timingFunction = CAMediaTimingFunction(name: .default)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        mediaContainer4.layer.add(group, forKey: "rotateScaleFade")
        mediaContainer3.layer.add(group, forKey: "rotateScaleFade")
        mediaContainer2.layer.add(group, forKey: "rotateScaleFade")
        mediaContainer1.layer.add(group, forKey: "rotateScaleFade")
        attachedMedia.removeAll()
        mediaAltText.removeAll()
        mediaImage1.image = UIImage()
        mediaImage2.image = UIImage()
        mediaImage3.image = UIImage()
        mediaImage4.image = UIImage()
    }
    
    func tryDisplayThumbnail(url: URL) {
        thumbnailAttempt = 0
        getThumbnailImageFromVideoUrl(url: url)
    }
    
    func getThumbnailImageFromVideoUrl(url: URL) {
        if thumbnailAttempt < 10 {
            DispatchQueue.global().async {
                let asset = AVAsset(url: url)
                let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                avAssetImageGenerator.appliesPreferredTrackTransform = true
                let thumnailTime = CMTimeMake(value: 1, timescale: 60)
                do {
                    let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                    let thumbImage = UIImage(cgImage: cgThumbImage)
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.mediaImage1.image = thumbImage
                        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
                        rotation.fromValue = 0
                        rotation.toValue = -CGFloat.pi / 26
                        let scale = CABasicAnimation(keyPath: "transform.scale")
                        scale.fromValue = 0.4
                        scale.toValue = 1.0
                        let fade = CABasicAnimation(keyPath: "opacity")
                        fade.fromValue = 0.0
                        fade.toValue = 1.0
                        let group = CAAnimationGroup()
                        group.animations = [rotation, scale, fade]
                        group.duration = 0.5
                        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                        group.fillMode = .forwards
                        group.isRemovedOnCompletion = false
                        mediaContainer1.layer.add(group, forKey: "rotateScaleFade")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.mediaContainer1.alpha = 1
                            self.addMediaOptions(0)
                        }
                    }
                } catch {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        guard let self else { return }
                        self.thumbnailAttempt += 1
                        self.getThumbnailImageFromVideoUrl(url: url)
                    }
                }
            }
        }
    }
    
    func saveMovieDataToFile(dataRepresentation: Data, completion: @escaping (URL?) -> Void) {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let uniqueFileName = UUID().uuidString + ".mov"
        let fileURL = temporaryDirectory.appendingPathComponent(uniqueFileName)
        do {
            try dataRepresentation.write(to: fileURL)
            completion(fileURL)
        } catch {
            print("Error saving movie data to file: \(error)")
            completion(nil)
        }
    }
    
    @objc func draftsTapped() {
        let vc = DraftsViewController()
        present(SloppySwipingNav(rootViewController: vc), animated: true, completion: nil)
    }
    
}

extension ATProtoBluesky.ThreadgateAllowRule: @retroactive Equatable, @retroactive Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.allowMentions, .allowMentions),
             (.allowFollowers, .allowFollowers),
             (.allowFollowing, .allowFollowing):
            return true
        case let (.allowList(uri1), .allowList(uri2)):
            return uri1 == uri2
        default:
            return false
        }
    }
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .allowMentions:
            hasher.combine("allowMentions")
        case .allowFollowers:
            hasher.combine("allowFollowers")
        case .allowFollowing:
            hasher.combine("allowFollowing")
        case .allowList(let uri):
            hasher.combine("allowList")
            hasher.combine(uri)
        }
    }
}
