//
//  MessageChatViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 13/05/2025.
//

import Foundation
import UIKit
import ATProtoKit
import MessageKit
import InputBarAccessoryView

class MessageChatViewController: MessagesViewController {
    
    var messages: [Message] = []
    var displayName: String = ""
    var actorDID: String = ""
    var avatar: URL? = nil
    var isMuted: Bool = false
    var conversation: [ChatBskyLexicon.Conversation.ConversationViewDefinition] = []
    var allMessages: [ATUnion.GetMessagesOutputMessagesUnion] = []
    
    // loading indicator
    let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = displayName
        
        setupNavigation()
        
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        messagesCollectionView.backgroundColor = view.backgroundColor
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        layout?.setMessageIncomingAvatarSize(.zero)
        layout?.setMessageOutgoingAvatarSize(.zero)
        
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = view.backgroundColor
        messageInputBar.inputTextView.placeholder = "Message..."
        
        fetchMessages()
    }
    
    func setupNavigation() {
        let avatarButton = UIButton(type: .custom)
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarButton.widthAnchor.constraint(equalToConstant: 28),
            avatarButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        avatarButton.layer.cornerRadius = 14
        avatarButton.clipsToBounds = true
        if let url = avatar {
            avatarButton.sd_setImage(with: url, for: .normal)
        }
        avatarButton.imageView?.contentMode = .scaleAspectFill
        let menuItem1 = UIAction(title: "View Profile", image: UIImage(systemName: "person"), identifier: nil) { [weak self] action in
            guard let self else { return }
            let vc = ProfileViewController()
            vc.profile = actorDID
            navigationController?.pushViewController(vc, animated: true)
        }
        var muteText: String = "Mute Chat"
        var muteImage: String = "speaker.slash"
        if isMuted {
            muteText = "Unmute Chat"
            muteImage = "speaker.wave.1"
        }
        let menuItem2 = UIAction(title: muteText, image: UIImage(systemName: muteImage), identifier: nil) { [weak self] action in
            guard let self else { return }
            if isMuted {
                unmuteChat()
            } else {
                muteChat()
            }
            isMuted = !isMuted
            setupNavigation()
        }
        if !isMuted {
            menuItem2.attributes = .destructive
        }
        let menuItem3 = UIAction(title: "Leave Chat", image: UIImage(systemName: "arrow.left"), identifier: nil) { [weak self] action in
            guard let self else { return }
            leaveChat()
            navigationController?.popViewController(animated: true)
        }
        menuItem3.attributes = .destructive
        let subMenu = UIMenu(title: "", options: [.displayInline], children: [menuItem2, menuItem3])
        let menu = UIMenu(title: "", options: [.displayInline], children: [menuItem1] + [subMenu])
        avatarButton.menu = menu
        avatarButton.showsMenuAsPrimaryAction = true
        let avatarBarButtonItem = UIBarButtonItem(customView: avatarButton)
        avatarBarButtonItem.accessibilityLabel = displayName
        navigationItem.rightBarButtonItem = avatarBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideNewPostButton"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "showNewPostButton"), object: nil)
    }
    
    func fetchMessages() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let atProtoBluesky = ATProtoBlueskyChat(atProtoKitInstance: atProto)
                    let y = try await atProtoBluesky.getMessages(from: conversation.first?.conversationID ?? "")
                    DispatchQueue.main.async {
                        self.allMessages = y.messages
                        for message in self.allMessages {
                            switch message {
                            case .messageView(let message):
                                self.messages.insert(Message(sender: Sender(senderId: message.sender.authorDID, displayName: message.sender.authorDID), messageId: message.messageID, sentDate: message.sentAt, kind: .text(message.text)), at: 0)
                            default:
                                break
                            }
                        }
                        self.loadingIndicator.stopAnimating()
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(animated: false)
                    }
                }
            } catch {
                print("Error fetching messages: \(error.localizedDescription)")
            }
        }
    }
    
    func muteChat() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let atProtoBluesky = ATProtoBlueskyChat(atProtoKitInstance: atProto)
                    let y = try await atProtoBluesky.muteConversation(from: conversation.first?.conversationID ?? "")
                    DispatchQueue.main.async {
                        
                    }
                }
            } catch {
                print("Error muting conversation: \(error.localizedDescription)")
            }
        }
    }
    
    func unmuteChat() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let atProtoBluesky = ATProtoBlueskyChat(atProtoKitInstance: atProto)
                    let y = try await atProtoBluesky.unmuteConversation(by: conversation.first?.conversationID ?? "")
                    DispatchQueue.main.async {
                        
                    }
                }
            } catch {
                print("Error unmuting conversation: \(error.localizedDescription)")
            }
        }
    }
    
    func leaveChat() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let atProtoBluesky = ATProtoBlueskyChat(atProtoKitInstance: atProto)
                    let y = try await atProtoBluesky.leaveConversation(from: conversation.first?.conversationID ?? "")
                    DispatchQueue.main.async {
                        
                    }
                }
            } catch {
                print("Error leaving conversation: \(error.localizedDescription)")
            }
        }
    }
}

extension MessageChatViewController: MessagesDataSource {
    var currentSender: SenderType {
        return Sender(senderId: GlobalStruct.currentUser?.actorDID ?? "", displayName: GlobalStruct.currentUser?.actorDID ?? "")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension MessageChatViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? GlobalStruct.baseTint : GlobalStruct.raisedBackgroundTint
    }
    
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in _: MessagesCollectionView)
    {
        avatarView.isHidden = true
    }
}

extension MessageChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newMessage = Message(sender: currentSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem()
    }
}

struct Message: MessageType {
    let sender: SenderType
    let messageId: String
    let sentDate: Date
    let kind: MessageKind
}

struct Sender: SenderType {
    let senderId: String
    let displayName: String
}
