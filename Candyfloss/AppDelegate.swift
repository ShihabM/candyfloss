//
//  AppDelegate.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import UIKit
import ATProtoKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GlobalStruct.readerMode = UserDefaults.standard.value(forKey: "readerMode") as? Bool ?? false
        GlobalStruct.showActionButtons = !GlobalStruct.readerMode
        GlobalStruct.openLinksInApp = UserDefaults.standard.value(forKey: "openLinksInApp") as? Bool ?? true
        GlobalStruct.switchHaptics = UserDefaults.standard.value(forKey: "switchHaptics") as? Bool ?? true
        
        GlobalStruct.baseTint = UserDefaults.standard.color(forKey: "baseTint") ?? UIColor(named: "baseTint")!
        GlobalStruct.fullBlackBG = UserDefaults.standard.value(forKey: "fullBlackBG") as? Bool ?? false
        
        GlobalStruct.showNextReplyButton = UserDefaults.standard.value(forKey: "showNextReplyButton") as? Bool ?? true
        GlobalStruct.nextReplyButtonState = UserDefaults.standard.value(forKey: "nextReplyButtonState") as? Int ?? 0
        
        GlobalStruct.keyboardStyle = UserDefaults.standard.value(forKey: "keyboardStyle") as? Int ?? 0
        GlobalStruct.startLocation = UserDefaults.standard.value(forKey: "startLocation") as? Int ?? 0
        
        GlobalStruct.customTextSize = UserDefaults.standard.value(forKey: "customTextSize") as? CGFloat ?? 0
        GlobalStruct.customLineSize = UserDefaults.standard.value(forKey: "customLineSize") as? CGFloat ?? 0
        GlobalStruct.dateFormat = UserDefaults.standard.value(forKey: "dateFormat") as? Int ?? 0
        GlobalStruct.maxLines = UserDefaults.standard.value(forKey: "maxLines") as? Int ?? 0
        GlobalStruct.switchAutoplay = UserDefaults.standard.value(forKey: "switchAutoplay") as? Bool ?? true
        GlobalStruct.showActionButtons = UserDefaults.standard.value(forKey: "showActionButtons") as? Bool ?? true
        GlobalStruct.showActionButtonCounts = UserDefaults.standard.value(forKey: "showActionButtonCounts") as? Bool ?? true
        GlobalStruct.switchQuotePreviews = UserDefaults.standard.value(forKey: "switchQuotePreviews") as? Bool ?? true
        GlobalStruct.switchLinkPreviews = UserDefaults.standard.value(forKey: "switchLinkPreviews") as? Bool ?? true
        GlobalStruct.switchMedia = UserDefaults.standard.value(forKey: "switchMedia") as? Bool ?? true
        
        // fetch all feeds
        do {
            GlobalStruct.allFeeds = try Disk.retrieve("allFeeds.json", from: .documents, as: [AppBskyLexicon.Feed.GeneratorViewDefinition].self)
        } catch {
            print("error fetching from Disk")
        }
        // fetch pinned feeds
        do {
            GlobalStruct.pinnedFeeds = try Disk.retrieve("pinnedFeeds", from: .documents, as: [PinnedItems].self)
        } catch {
            print("error fetching from Disk")
        }
        // fetch pinned lists
        do {
            GlobalStruct.pinnedLists = try Disk.retrieve("pinnedLists", from: .documents, as: [PinnedItems].self)
        } catch {
            print("error fetching from Disk")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

