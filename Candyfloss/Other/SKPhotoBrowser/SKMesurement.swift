//
//  SKMesurement.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation
import UIKit

struct SKMesurement {
    static let isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    static let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    static var statusBarH: CGFloat {
        let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    static var screenHeight: CGFloat {
#if !os(visionOS)
        return UIApplication.shared.preferredApplicationWindow2?.rootViewController?.view.bounds.height ?? UIScreen.main.bounds.height
        #else
        return UIApplication.shared.preferredApplicationWindow2?.rootViewController?.view.bounds.height ?? 1
        #endif
    }
    static var screenWidth: CGFloat {
#if !os(visionOS)
        return UIApplication.shared.preferredApplicationWindow2?.rootViewController?.view.bounds.width ?? UIScreen.main.bounds.width
#else
        return UIApplication.shared.preferredApplicationWindow2?.rootViewController?.view.bounds.width ?? 1
#endif
    }
    static var screenScale: CGFloat {
#if !os(visionOS)
        return UIScreen.main.scale
#else
        return 1
#endif
    }
    static var screenRatio: CGFloat {
        return screenWidth / screenHeight
    }
    static var isPhoneX: Bool {
#if !os(visionOS)
        let iPhoneXHeights: [CGFloat] = [2436, 2688, 1792]
        if isPhone, iPhoneXHeights.contains(UIScreen.main.nativeBounds.height) {
           return true
        }
        return false
        #else
        return false
        #endif
    }
}
