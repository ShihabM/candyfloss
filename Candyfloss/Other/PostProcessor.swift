//
//  PostProcessor.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit
import Photos
import ATProtoKit

func configurePostCell(_ cell: PostsCell, with post: AppBskyLexicon.Feed.PostViewDefinition, reason: ATUnion.ReasonRepostUnion? = nil, isNestedQuote: Bool = false, isNestedReply: Bool = false, showActionButtons: Bool = true) {
    // post avatar
    if let url = post.author.avatarImageURL {
        cell.avatar.sd_setImage(with: url, for: .normal)
    } else {
        cell.avatar.setImage(UIImage(), for: .normal)
    }
    
    // post user details
    cell.username.text = post.author.displayName ?? ""
    if cell.username.text == "" {
        cell.username.text = " "
    }
    cell.usertag.text = "@\(post.author.actorHandle)"
    
    // post record details
    if let record = post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
        cell.text.text = record.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let timeSince = record.createdAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalStruct.dateFormatter
        
        if GlobalStruct.dateFormat == 0 {
            cell.time.text = timeSince.toStringWithRelativeTime()
        } else {
            cell.time.text = timeSince.toString(dateStyle: .short, timeStyle: .short)
        }
    }
    
    // pinned and repost
    var isPinned: Bool = false
    var reposter: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil
    if let reason = reason {
        switch reason {
        case .reasonPin( _):
            isPinned = true
        case .reasonRepost(let repost):
            reposter = repost.by
        }
    }
    
    // post action buttons
    cell.repliesCount = post.replyCount ?? 0
    cell.likesCount = post.likeCount ?? 0
    cell.repostsCount = post.repostCount ?? 0
    
    // action buttons
    var actionButtons: Bool = GlobalStruct.showActionButtons
    if showActionButtons == false {
        actionButtons = false
    }
    
    // cell configuration
    cell.configure(post: post, showActionButtons: actionButtons, isRepost: reposter, isNestedQuote: isNestedQuote, isNestedReply: isNestedReply, isPinned: isPinned)
}

func configureDetailCell(_ cell: DetailCell, with post: AppBskyLexicon.Feed.PostViewDefinition) {
    // post avatar
    if let url = post.author.avatarImageURL {
        cell.avatar.sd_setImage(with: url, for: .normal)
    } else {
        cell.avatar.setImage(UIImage(), for: .normal)
    }
    
    // post user details
    cell.username.text = post.author.displayName ?? ""
    if cell.username.text == "" {
        cell.username.text = " "
    }
    cell.usertag.text = "@\(post.author.actorHandle)"
    
    // post record details
    if let record = post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
        cell.text.text = record.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let createdOn = record.createdAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalStruct.dateFormatter
        let createdDate = createdOn.toString(dateStyle: .long, timeStyle: .none)
        let createdTime = createdOn.toString(dateStyle: .none, timeStyle: .short)
        
        // threadgate
        if let threadgate = post.threadgate {
            do {
                let data = try threadgate.record.toJSON()
                let json = try JSONDecoder().decode(AppBskyLexicon.Feed.ThreadgateRecord.self, from: data ?? Data())
                DispatchQueue.main.async {
                    var repliesText: String = ""
                    if let allowedTypes = json.allow {
                        if allowedTypes.isEmpty {
                            repliesText = "Replies are disabled"
                        } else {
                            repliesText = "Replies allowed for "
                            for rule in allowedTypes {
                                switch rule {
                                case .mentionRule(_):
                                    repliesText = "\(repliesText)mentioned users, "
                                case .followerRule(_):
                                    repliesText = "\(repliesText)followers, "
                                case .followingRule(_):
                                    repliesText = "\(repliesText)followed users, "
                                default:
                                    break
                                }
                            }
                            repliesText = "\(repliesText.dropLast(2))"
                        }
                    }
                    cell.time.text = "\(createdDate) at \(createdTime)  •  \(repliesText)"
                }
            } catch {
                cell.time.text = "\(createdDate) at \(createdTime)"
            }
        } else {
            cell.time.text = "\(createdDate) at \(createdTime)"
        }
    }
    
    // cell configuration
    cell.configure(post: post)
}

func configureActivityCell(_ cell: ActivityCell, with notification: [AppBskyLexicon.Notification.Notification], text: String) {
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    
    // activity avatars
    var user = resolveUser(notification.first?.author)
    var followersText: String = ""
    if notification.count == 1 {
        followersText = "1 new follower"
    } else {
        followersText = "\(notification.count) new followers"
    }
    if let url = notification.first?.author.avatarImageURL {
        cell.avatar1.sd_setImage(with: url, for: .normal)
        cell.avatar1.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
    } else {
        let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let avatarImage = UIImage(systemName: "person.fill", withConfiguration: symbolConfig1)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.avatar1.setImage(avatarImage, for: .normal)
        cell.avatar1.backgroundColor = GlobalStruct.baseTint
    }
    if notification.count > 1 {
        if let url = notification[1].author.avatarImageURL {
            cell.avatar2.sd_setImage(with: url, for: .normal)
            cell.avatar2.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        } else {
            let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            let avatarImage = UIImage(systemName: "person.fill", withConfiguration: symbolConfig1)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.avatar2.setImage(avatarImage, for: .normal)
            cell.avatar2.backgroundColor = GlobalStruct.baseTint
        }
        user = "\(resolveUser(notification.first?.author)) and \(resolveUser(notification[1].author))"
    }
    if notification.count > 2 {
        if let url = notification[2].author.avatarImageURL {
            cell.avatar3.sd_setImage(with: url, for: .normal)
            cell.avatar3.backgroundColor = GlobalStruct.pollBar.withAlphaComponent(0.25)
        } else {
            let symbolConfig1 = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            let avatarImage = UIImage(systemName: "person.fill", withConfiguration: symbolConfig1)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            cell.avatar3.setImage(avatarImage, for: .normal)
            cell.avatar3.backgroundColor = GlobalStruct.baseTint
        }
        user = "\(resolveUser(notification.first?.author)), \(resolveUser(notification[1].author)), and \(resolveUser(notification[2].author))"
    }
    if notification.count > 3 {
        cell.avatar4.setTitle("+\(notification.count - 3)", for: .normal)
        user = "\(resolveUser(notification.first?.author)), \(resolveUser(notification[1].author)), \(resolveUser(notification[2].author)), and others"
    }
    
    // details
    cell.postContents.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // activity header and icons
    if notification.first?.reason.rawValue ?? .none == "like" {
        cell.username.text = "\(user) liked:"
        cell.typeIndicator.setImage(UIImage(systemName: "heart.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemPink, renderingMode: .alwaysOriginal), for: .normal)
    }
    if notification.first?.reason.rawValue ?? .none == "repost" {
        cell.username.text = "\(user) reposted:"
        cell.typeIndicator.setImage(UIImage(systemName: "arrow.2.squarepath", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemGreen, renderingMode: .alwaysOriginal), for: .normal)
    }
    if notification.first?.reason.rawValue ?? .none == "follow" {
        cell.username.text = followersText
        cell.typeIndicator.setImage(UIImage(systemName: "person.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        cell.postContents.text = user
    }
    if notification.first?.reason.rawValue ?? .none == "quote" {
        cell.username.text = "\(user) quoted:"
        cell.typeIndicator.setImage(UIImage(systemName: "quote.bubble.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemMint, renderingMode: .alwaysOriginal), for: .normal)
    }
    if notification.first?.reason.rawValue ?? .none == "starterpackjoined" {
        cell.username.text = "\(user) joined your starter pack"
        cell.typeIndicator.setImage(UIImage(systemName: "star.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.systemOrange, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    // activity timestamp
    if let timeSince = notification.first?.indexedAt {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalStruct.dateFormatter
        if GlobalStruct.dateFormat == 0 {
            cell.time.text = timeSince.toStringWithRelativeTime()
        } else {
            cell.time.text = timeSince.toString(dateStyle: .short, timeStyle: .short)
        }
    }
    
    // cell configuration
    cell.configure(notification)
}

func configureMessageCell(_ cell: MessageCell, with message: ChatBskyLexicon.Conversation.MessageViewDefinition, members: [ChatBskyLexicon.Actor.ProfileViewBasicDefinition]) {
    // message details
    cell.text.text = message.text.trimmingCharacters(in: .whitespacesAndNewlines)
    let timeSince = message.sentAt
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = GlobalStruct.dateFormatter
    
    if GlobalStruct.dateFormat == 0 {
        cell.time.text = timeSince.toStringWithRelativeTime()
    } else {
        cell.time.text = timeSince.toString(dateStyle: .short, timeStyle: .short)
    }
    
    // cell configuration
    cell.configure(post: message)
}

// bookmark

func bookmark(_ post: AppBskyLexicon.Feed.PostViewDefinition) {
    do {
        GlobalStruct.bookmarks = try Disk.retrieve("bookmarks", from: .documents, as: [AppBskyLexicon.Feed.PostViewDefinition].self)
        GlobalStruct.bookmarks.insert(post, at: 0)
        try Disk.save(GlobalStruct.bookmarks, to: .documents, as: "bookmarks")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: nil)
    } catch {
        print("error fetching from Disk")
        GlobalStruct.bookmarks.insert(post, at: 0)
        do {
            try Disk.save(GlobalStruct.bookmarks, to: .documents, as: "bookmarks")
        } catch {
            print("error saving to Disk")
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: nil)
    }
}

func removeBookmark(_ post: AppBskyLexicon.Feed.PostViewDefinition) {
    do {
        GlobalStruct.bookmarks = try Disk.retrieve("bookmarks", from: .documents, as: [AppBskyLexicon.Feed.PostViewDefinition].self)
        GlobalStruct.bookmarks = GlobalStruct.bookmarks.filter({ thePost in
            thePost != post
        })
        try Disk.save(GlobalStruct.bookmarks, to: .documents, as: "bookmarks")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: nil)
    } catch {
        print("error fetching from Disk")
        GlobalStruct.bookmarks = GlobalStruct.bookmarks.filter({ thePost in
            thePost != post
        })
        do {
            try Disk.save(GlobalStruct.bookmarks, to: .documents, as: "bookmarks")
        } catch {
            print("error saving to Disk")
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTables"), object: nil)
    }
}
