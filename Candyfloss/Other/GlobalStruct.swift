//
//  GlobalStruct.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit
import ATProtoKit

struct GlobalStruct {
    static var atProto: ATProtoKit? = nil
    static var currentUser: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = nil
    
    static var allUsers: [UserStruct] = []
    static var currentSelectedUser: String = ""
    
    // tints
    static var baseTint: UIColor = UIColor(named: "baseTint")!
    static var backgroundTint: UIColor = (UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false == true) ? UIColor(named: "fullBlack")! : UIColor(named: "bg")!
    static var raisedBackgroundTint: UIColor = UIColor(named: "bg2")!
    static var cellBackgroundTint: UIColor = UIColor(named: "bgInset")!
    static var backgroundTintHighlight: UIColor = UIColor(named: "bgHighlight")!
    static var followBG: UIColor = UIColor(named: "followBG")!
    static var threadLines: UIColor = UIColor(named: "threadLines")!
    static var groupBG: UIColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false == true) ? UIColor(named: "groupSepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "groupBG2")! : UIColor(named: "groupBG")!)
    static var spoilerBG: UIColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false == true) ? UIColor(named: "groupSepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false) ? UIColor(named: "spoilerBGFullBlack")! : UIColor(named: "spoilerBG")!)
    static var pollBar: UIColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false == true) ? UIColor(named: "sepiaBG")! : ((UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false == true) ? UIColor(named: "spoilerBGFullBlack")! : UIColor(named: "pollBar")!)
    static var textColor: UIColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false == true) ? UIColor(named: "sepiaPrimary")! : UIColor(named: "textColor")!
    static var secondaryTextColor: UIColor = (UserDefaults.standard.value(forKey: "sepiaBG") as? Bool ?? false == true) ? UIColor(named: "sepiaSecondary")! : UIColor(named: "secondaryTextColor")!
    static var detailCell: UIColor = UIColor(named: "detailCell")!
    static var detailQuoteCell: UIColor = UIColor(named: "detailQuoteCell")!
    static var blueskyBlue: UIColor = UIColor(named: "blueskyBlue")!
    static var modalBackground: UIColor = (UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false == true) ? UIColor(named: "fullBlackModal")! : UIColor(named: "modalBG")!
    static var separator: UIColor = UIColor(named: "separatorColor")!
    
    // defaults
    static var dateFormatter = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static var detailImages: [URL] = []
    static var detailVideoAspectRatioWidth: CGFloat = 0
    static var detailVideoAspectRatioHeight: CGFloat = 0
    static var detailImageWidth: Int = 0
    static var detailImageHeight: Int = 0
    // 0: all media, 1: profile avatar, 2: profile header and details
    static var mediaBrowserRadiusType: Int = 0
    static var fromHeaderTap: Bool = false
    static var quoteTable: [String: AppBskyLexicon.Feed.PostViewDefinition] = [:]
    static var quoteTableHeights: [String: CGFloat] = [:]
    static var originalTranslationText: String = ""
    static var currentMaxChars: Int = 300
    static var bookmarks: [AppBskyLexicon.Feed.PostViewDefinition] = []
    static var drafts: [PostDrafts] = []
    static var currentDraft: PostDrafts? = nil
    
    // feeds / lists
    static var isShowingFeeds: Bool = true
    static var currentFeedURI: String = ""
    static var currentFeedDisplayName: String = "Following"
    static var displayFeedDescriptions: Bool = true
    static var listName: String = ""
    static var listDescription: String = ""
    static var listURI: String = ""
    static var allFeeds: [AppBskyLexicon.Feed.GeneratorViewDefinition] = []
    static var allLists: [AppBskyLexicon.Graph.ListViewDefinition] = []
    static var allFetchedPosts: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    static var currentFetchedCursor: String = ""
    static var pinnedFeeds: [PinnedItems] = []
    static var pinnedLists: [PinnedItems] = []
    static var currentFeed: AppBskyLexicon.Feed.GeneratorViewDefinition? = nil
    static var currentList: AppBskyLexicon.Graph.ListViewDefinition? = nil
    static var listURIToDelete: String = ""
    static var inVCFromList: Bool = false
    
    // settings
    static var fullBlackBG: Bool = false
    static var overrideTheme: Int = 0
    static var currentTab: Int = 0
    static var switchHaptics: Bool = true
    static var showMedia: Bool = true
    static var showActionButtons: Bool = true
    static var showActionButtonCounts: Bool = true
    static var twentyFourHourFormat: Bool = true
    static var profilePagePicAlignment: CGFloat = 1
    static var customTextSize: CGFloat = 0
    static var customLineSize: CGFloat = 0
    static var maxLines: Int = 0
    static var dateFormat: Int = 0
    static var readerMode: Bool = false
    static var startLocation: Int = 0
    static var showAltTags: Bool = true
    static var openLinksInApp: Bool = true
    static var inPiP: Bool = false
    static var keyboardStyle: Int = 0
    static var isPostButtonInNavBar: Bool = true
    static var showNextReplyButton: Bool = true
    static var nextReplyButtonState: Int = 0
    static var switchMedia: Bool = true
    static var switchQuotePreviews: Bool = true
    static var switchLinkPreviews: Bool = true
    static var switchAutoplay: Bool = true
    static var currentMaxMediaCount: Int = 4
    static var animateTabSelection: Bool = true
    
    static var fromComposerMedia: Bool = false
    static var composerMediaIndex: Int = 0
    static var currentMediaAltText: String = ""
    
    static var updatedPost: AppBskyLexicon.Feed.PostViewDefinition? = nil
    
    // iPad views
    static var padScrollViewController = PadScrollViewController.shared
    static var vc1 = TabBarController()
    
    // views
    static var currentSwitchableViewAtSpot3 = SwitchableViews(title: "Explore", icon: "magnifyingglass", iconSelected: "magnifyingglass", view: ExploreViewController())
    static var currentSwitchableViewAtSpot4 = SwitchableViews(title: "Bookmarks", icon: "bookmark", iconSelected: "bookmark.fill", view: BookmarksViewController())
    static var currentSwitchableViewAtSpot5 = SwitchableViews(title: "Profile", icon: "person", iconSelected: "person.fill", view: ProfileViewController())
    static var switchableViews: [SwitchableViews] = [
        SwitchableViews(title: "Bookmarks", icon: "bookmark", iconSelected: "bookmark.fill", view: BookmarksViewController()),
        SwitchableViews(title: "Explore", icon: "magnifyingglass", iconSelected: "magnifyingglass", view: ExploreViewController()),
        SwitchableViews(title: "Likes", icon: "heart", iconSelected: "heart.fill", view: LikesViewController()),
        SwitchableViews(title: "Lists", icon: "list.bullet", iconSelected: "list.bullet", view: FeedsListsViewController()),
        SwitchableViews(title: "Messages", icon: "message", iconSelected: "message.fill", view: MessagesListViewController()),
        SwitchableViews(title: "Profile", icon: "person", iconSelected: "person.fill", view: ProfileViewController())
    ]
    static var switchableView: SwitchableViews = SwitchableViews(title: "Explore", icon: "magnifyingglass", iconSelected: "magnifyingglass", view: ExploreViewController())
    static var switchableIndex: Int = 0
    
    // action buttons
    static var bookmarkImage1 = UIImage(systemName: "bookmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
    static var bookmarkImage2 = UIImage(systemName: "bookmark.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal)
    static var moreImage1 = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
    static var replyImage1 = UIImage(systemName: "arrowshape.turn.up.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
    static var repostImage1 = UIImage(systemName: "arrow.2.squarepath", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
    static var repostImage2 = UIImage(systemName: "arrow.2.squarepath", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
    static var likeImage1 = UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
    static var likeImage2 = UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular))?.withTintColor(GlobalStruct.secondaryTextColor, renderingMode: .alwaysOriginal)
    
    // starter packs
    static var starterPacks: [String] = [
        "at://did:plc:jcoy7v3a2t4rcfdh6i4kza25/app.bsky.graph.list/3kvvsi4qacz2p",
        "at://did:plc:cofmcscsguqskfiyrieo7tpf/app.bsky.graph.list/3lbpx52ewki22",
        "at://did:plc:wnt62siviv5qdnhslpz2jjmr/app.bsky.graph.list/3lc4ignapzy22",
        "at://did:plc:wi7bstljuyjgn26su62xdg2j/app.bsky.graph.list/3lg3zaxppsp2a",
        "at://did:plc:2buz4gf5sew3rdwzbxsvcd4s/app.bsky.graph.list/3lbuvraefoe23",
        "at://did:plc:m7h633sxyqlzwlhdubecv4uy/app.bsky.graph.list/3lggcx32mgu23",
        "at://did:plc:v7gngzva22rilmcp6fiypowf/app.bsky.graph.list/3lbcrdrart42l",
        "at://did:plc:xh7adzforauzsj3gt32lzkyo/app.bsky.graph.list/3lbv2fdcl4m2k",
        "at://did:plc:th2nqtejav7bhlcmg6qti53b/app.bsky.graph.list/3l7v2f4lap72a",
        "at://did:plc:lglsul6dikvl67sfuwsi73a2/app.bsky.graph.list/3lbn4rb7vx42p",
        "at://did:plc:mjj3u6pljmb7wbtzgul5ds3y/app.bsky.graph.list/3laxjrrf6al2v",
        "at://did:plc:j3qij7oqe6gie2x56gk5s6tx/app.bsky.graph.list/3lfinrwznmh2w",
        "at://did:plc:5vzgjins5recitzoov4rby3y/app.bsky.graph.list/3l6vez3xaus27",
        "at://did:plc:uz5apa2z3jrxhjjzqw5qik65/app.bsky.graph.list/3lcx37fpmqo2d",
        "at://did:plc:uz5apa2z3jrxhjjzqw5qik65/app.bsky.graph.list/3lb57so2f5j25",
        "at://did:plc:6c4u6lxoc6chgcfb6nqfawlw/app.bsky.graph.list/3lccxtemh5w2f",
        "at://did:plc:denuvqodvvnzxtuitumle4vs/app.bsky.graph.list/3l73krxhwvq2y",
        "at://did:plc:icdkhpdjn4o6rd5zlnir6a6n/app.bsky.graph.list/3layvlx76sw2z",
        "at://did:plc:ornn7ykerjxqp7qrigu4sbf4/app.bsky.graph.list/3ldegyigv562l",
        "at://did:plc:chugy2mhbqau2itmchcx4nvy/app.bsky.graph.list/3lkvu6loxy726",
        "at://did:plc:ylvjkvcjyosjqhn7lsoxbf3x/app.bsky.graph.list/3l5fwa5xmvw2n",
        "at://did:plc:dpjtfmiav5v7fucsz6n3wr3y/app.bsky.graph.list/3ldwvl3twxg2a",
        "at://did:plc:na44tnnzcxmrmgxohiwueh4n/app.bsky.graph.list/3lawnq5azwn2e",
    ]
}
