//
//  Utilities++.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 07/03/2025.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import NaturalLanguage
import CoreHaptics
import SwiftUI
import SafariServices
import Photos
import Translation
import Vision
import ATProtoKit

extension String {
    func ranges(of searchString: String, options: CompareOptions = .literal) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
              let range = self.range(of: searchString, options: options, range: searchStartIndex..<self.endIndex),
              !range.isEmpty {
            
            ranges.append(range)
            searchStartIndex = range.upperBound
        }
        
        return ranges
    }
    
    func nsRange(from range: Range<String.Index>) -> NSRange? {
        guard let from = range.lowerBound.samePosition(in: utf16),
              let to = range.upperBound.samePosition(in: utf16) else {
            return nil
        }
        
        let location = utf16.distance(from: utf16.startIndex, to: from)
        let length = utf16.distance(from: from, to: to)
        return NSRange(location: location, length: length)
    }
    
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        return Range(nsRange, in: self)
    }
    
    private static let breakLineRegex = try! NSRegularExpression(pattern: "<br ?/?>|</p><p>", options: [])
    private static let tagRegex = try! NSRegularExpression(pattern: "<[^>]+>", options: [])
    private static let bulletRegex = try! NSRegularExpression(pattern: "(?m)(^[\\-•]\\s.*?)(\\n{2,})(?=[\\-•]\\s)", options: [])
    private static let multipleNewlinesRegex = try! NSRegularExpression(pattern: "\n{3,}", options: [])
    
    func stripHTML() -> String {
        var z = self
        let entities: [String: String] = [
            "&apos;": "'",
            "&quot;": "\"",
            "&amp;": "&",
            "&nbsp;": " ",
            "&lt;": "<",
            "&gt;": ">",
            "&#39;": "'",
            "<br> <br>": "\n\n"
        ]
        for (entity, replacement) in entities {
            z = z.replacingOccurrences(of: entity, with: replacement)
        }
        z = String.breakLineRegex.stringByReplacingMatches(in: z, options: [], range: NSRange(z.startIndex..., in: z), withTemplate: "\n\n")
        z = String.multipleNewlinesRegex.stringByReplacingMatches(in: z, options: [], range: NSRange(z.startIndex..., in: z), withTemplate: "\n\n")
        z = String.tagRegex.stringByReplacingMatches(in: z, options: [], range: NSRange(z.startIndex..., in: z), withTemplate: "")
        z = String.bulletRegex.stringByReplacingMatches(in: z, options: [], range: NSRange(location: 0, length: z.utf16.count), withTemplate: "$1\n")
        return z.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removeWordsBetweenColonsAndTrimSpaces() -> String {
        let pattern = ":[^:]+:"
        let regex = try? NSRegularExpression(pattern: pattern)
        var result = regex?.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(self.startIndex..., in: self),
            withTemplate: ""
        ) ?? self
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func removingUrls() -> String {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return self
        }
        return detector.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count), withTemplate: "")
    }
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        for subview in arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
}

extension UIApplication {
    func pushToCurrentNavigationController(_ viewController: UIViewController, animated: Bool = true) {
        if let tabBarController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController,
           let selectedNavController = tabBarController.selectedViewController as? UINavigationController {
            selectedNavController.pushViewController(viewController, animated: animated)
        } else if let navController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
            navController.pushViewController(viewController, animated: animated)
        }
    }
    
    func windowMode() -> String {
        let screenRect = UIScreen.main.bounds
        let appRect = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            return "iPhone fullscreen"
        } else if (screenRect == appRect) {
            return "iPad fullscreen"
        } else {
            return "iPad slide over"
        }
    }
}

internal extension UIApplication {
    var preferredApplicationWindow: UIWindow? {
#if !os(visionOS)
        if let appWindow = UIApplication.shared.delegate?.window, let window = appWindow {
            return window
        } else if let window = UIApplication.shared.keyWindow {
            return window
        }
        #else
        if let appWindow = UIApplication.shared.delegate?.window, let window = appWindow {
            return window
        } else {
            return nil
        }
        #endif

        return nil
    }
}

func getTopMostViewController() -> UIViewController? {
    var topMostViewController = UIApplication.shared.preferredApplicationWindow?.rootViewController
    while let presentedViewController = topMostViewController?.presentedViewController {
        topMostViewController = presentedViewController
    }
    return topMostViewController
}

extension UITableViewCell {
    func getMinutesDifferenceFromTwoDates(start: Date, end: Date) -> Int {
        let diffSeconds = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
        let minutes = diffSeconds / 60
        return minutes
    }
}

extension UIColor {
    func toHexString() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension Int {
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    func withCommas() -> String {
        if self < 1000 {
            return "\(self)"
        }
        return Int.numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    func formatUsingAbbreviation() -> String {
        let number = Double(self)
        switch number {
        case 1_000_000...:
            let million = number / 1_000_000
            return "\(roundToOneDecimalPlace(million))M"
        case 1_000...:
            let thousand = number / 1_000
            return "\(roundToOneDecimalPlace(thousand))K"
        default:
            return "\(self)"
        }
    }
    
    private func roundToOneDecimalPlace(_ value: Double) -> String {
        return String(format: "%.1f", value).replacingOccurrences(of: ".0", with: "")
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    mutating func removeAllDuplicates() {
        self = self.removingDuplicates()
    }
    var orderedSet: Self {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
    mutating func removeDuplicates() {
        var set = Set<Element>()
        removeAll { !set.insert($0).inserted }
    }
}

extension UITextView {
#if targetEnvironment(macCatalyst)
    @objc(_focusRingType)
    override var focusRingType: UInt {
        return 1 //NSFocusRingTypeNone
    }
#endif
    
    var cursorOffset: Int? {
        guard let range = selectedTextRange else { return nil }
        return offset(from: beginningOfDocument, to: range.start)
    }
    var cursorIndex: String.Index? {
        guard let location = cursorOffset else { return nil }
        return Range(.init(location: location, length: 0), in: text)?.lowerBound
    }
    var cursorDistance: Int? {
        guard let cursorIndex = cursorIndex else { return nil }
        return text.distance(from: text.startIndex, to: cursorIndex)
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexSanitized)
        
        if hexSanitized.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x0000FF) / 255
            
            self.init(red: r, green: g, blue: b, alpha: alpha)
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
        }
    }
}

extension UIImage {
    public func withRoundedCorners(_ roundingFactor: CGFloat = 2) -> UIImage? {
        let maxRadius = min(size.width, size.height) / roundingFactor
        let cornerRadius: CGFloat
        cornerRadius = maxRadius
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    func withInset(_ insets: UIEdgeInsets) -> UIImage? {
        let cgSize = CGSize(width: self.size.width + insets.left * self.scale + insets.right * self.scale,
                            height: self.size.height + insets.top * self.scale + insets.bottom * self.scale)
        
        UIGraphicsBeginImageContextWithOptions(cgSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        let origin = CGPoint(x: insets.left * self.scale, y: insets.top * self.scale)
        self.draw(at: origin)
        
        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
    }
}

extension UIColor {
    var simd3Color: SIMD3<Float> {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SIMD3(Float(red), Float(green), Float(blue))
    }
}

extension UserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var colorReturnded: UIColor?
        if let colorData = data(forKey: key) {
            do {
                if let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                    colorReturnded = color
                }
            } catch {
                print("Error UserDefaults")
            }
        }
        return colorReturnded
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData?
                colorData = data
            } catch {
                print("Error UserDefaults")
            }
        }
        set(colorData, forKey: key)
    }
    
    func color(forKey key: String) -> UIColor? {
        guard let colorData = data(forKey: key) else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } catch let error {
            print("color error \(error.localizedDescription)")
            return nil
        }
    }
}

func createImageWithCircularBackground(icon: UIImage, backgroundColor: UIColor, diameter: CGFloat) -> UIImage? {
    let frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
    var scale: CGFloat = 1
    scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    context.interpolationQuality = .high
    let path = UIBezierPath(ovalIn: frame)
    backgroundColor.setFill()
    path.fill()
    path.addClip()
    let iconSize = icon.size
    let iconRect = CGRect(
        x: (diameter - iconSize.width) / 2,
        y: (diameter - iconSize.height) / 2,
        width: iconSize.width,
        height: iconSize.height
    )
    icon.draw(in: iconRect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

class CustomButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -30, dy: -30).contains(point)
    }
}

class PollTextField: UITextField {
    let padding = UIEdgeInsets(top: 9, left: 10, bottom: 9, right: 10)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

class TextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

class PlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    var player: AVPlayer? {
        willSet {
            if let currentPlayer = player {
                currentPlayer.pause()
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentPlayer.currentItem)
            }
        }
        didSet {
            guard let newPlayer = player else { return }
            newPlayer.isMuted = true
            newPlayer.currentItem?.preferredForwardBufferDuration = TimeInterval(1)
            playerLayer?.player = newPlayer
            playerLayer?.videoGravity = .resizeAspectFill
            NotificationCenter.default.addObserver(self,
                                                  selector: #selector(playerItemDidReachEnd(_:)),
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: newPlayer.currentItem)
        }
    }
    
    var playerLayer: AVPlayerLayer? {
        return layer as? AVPlayerLayer
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        player?.play()
    }
    
    deinit {
        if let playerItem = player?.currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        }
    }
}

class CustomVideoPlayer: AVPlayerViewController {
    var scrubbingBeginTime: CMTime?
    var showShare: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoGravity = .resizeAspect
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player?.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player?.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.showsPlaybackControls = true
        super.touchesBegan(touches, with: event)
    }
}

class LoadingView: UIView {
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.layer.cornerRadius = 16
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubview(blurEffectView)
        blurEffectView.contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            blurEffectView.centerXAnchor.constraint(equalTo: centerXAnchor),
            blurEffectView.centerYAnchor.constraint(equalTo: centerYAnchor),
            blurEffectView.widthAnchor.constraint(equalToConstant: 100),
            blurEffectView.heightAnchor.constraint(equalToConstant: 100)
        ])
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: blurEffectView.contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: blurEffectView.contentView.centerYAnchor)
        ])
    }
    
    func show(on view: UIView) {
        frame = view.bounds
        view.addSubview(self)
        activityIndicator.startAnimating()
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        removeFromSuperview()
    }
}

//class CurvedLineView: UIView {
//    private var shapeLayer: CAShapeLayer!
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    private func setupView() {
//        shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = GlobalStruct.threadLines.cgColor
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineWidth = 3.0
//        
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: bounds.midX, y: 0))
//        path.addLine(to: CGPoint(x: bounds.midX, y: 28))
//        path.addArc(withCenter: CGPoint(x: bounds.midX + 12, y: 28), radius: 12, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)
//        path.addLine(to: CGPoint(x: bounds.midX + 26, y: 40))
//        
//        shapeLayer.path = path.cgPath
//        layer.addSublayer(shapeLayer)
//    }
//    
//    private func updateStrokeColor() {
//        shapeLayer.strokeColor = GlobalStruct.threadLines.cgColor
//    }
//    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            updateStrokeColor()
//        }
//    }
//}

class HapticManager {
    private var hapticEngine: CHHapticEngine?

    init() {
        createEngine()
    }

    private func createEngine() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }

    func playSoftPulse() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        var events = [CHHapticEvent]()

        // Define the ramp-up phase
        let rampUp = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.25),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.12)
            ],
            relativeTime: 0.0,
            duration: 0.2
        )

        // Define the peak phase
        let peak = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.35)
            ],
            relativeTime: 0.1,
            duration: 0.2
        )

        // Define the fade-out phase
        let fadeOut = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0.2,
            duration: 0.5
        )

        events.append(rampUp)
        events.append(peak)
        events.append(fadeOut)

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}

class URLMatcher {
    
    // https://mastodon.social/@jaypeters/110215506077438196
    // https://www.threads.net/@halideapp/post/C_LzZWbS_SJ
    // https://www.threads.net/@reckless1280/post/C_dOV7vxdLi
    
    private let regex: NSRegularExpression

    init?() {
        let URLPattern = "https?:\\/\\/[\\w.-]+\\/(?:@|users\\/)[\\w-]+(?:\\/\\d+|\\/post\\/[\\w-]+)?"
        guard let regex = try? NSRegularExpression(pattern: URLPattern, options: []) else {
            return nil
        }
        self.regex = regex
    }

    func match(in text: String) -> String? {
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        if let match = regex.firstMatch(in: text, options: [], range: range) {
            if let range = Range(match.range, in: text) {
                let str = String(text[range])
                if (str.split(separator: "/").last ?? "").contains("@") {
                    return nil
                } else {
                    return str
                }
            }
        }
        return nil
    }
}

class CopyTextVC: UIViewController {
    static let shared = CopyTextVC()
    
    var selectTextBG = UIButton()
    var selectTextFG = UIView()
    let textView = CustomUITextView()
    var textToUse: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        self.selectTextBG.frame = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds ?? UIScreen.main.bounds)
        self.textView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 60, height: 240)
        self.textView.sizeToFit()
        self.selectTextFG.frame = textView.frame
        
        var fullWidth = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds.width ?? UIScreen.main.bounds.width)
        var fullHeight = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds.height ?? UIScreen.main.bounds.height)
#if targetEnvironment(macCatalyst)
        self.selectTextBG.frame = windowFrame ?? .zero
        fullWidth = windowFrame?.size.width ?? 0
        fullHeight = windowFrame?.size.height ?? 0
#else
        self.selectTextBG.frame = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds ?? UIScreen.main.bounds)
#endif
        self.selectTextFG.center = CGPoint(x: fullWidth/2, y: fullHeight/2 + 55)
    }
    
    func selectText() {
        let windowFrame = UIApplication.shared.connectedScenes
            .compactMap({ scene -> UIWindow? in
                (scene as? UIWindowScene)?.windows.first
            }).first?.frame
        
        var fullWidth = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds.width ?? UIScreen.main.bounds.width)
        var fullHeight = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds.height ?? UIScreen.main.bounds.height)
#if targetEnvironment(macCatalyst)
        self.selectTextBG.frame = windowFrame ?? .zero
        fullWidth = windowFrame?.size.width ?? 0
        fullHeight = windowFrame?.size.height ?? 0
#else
        self.selectTextBG.frame = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds ?? UIScreen.main.bounds)
#endif
        
        // bg
        self.selectTextBG.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.selectTextBG.addTarget(self, action: #selector(self.dismissSelectText), for: .touchUpInside)
        self.selectTextBG.alpha = 0
        getTopMostViewController()?.view.addSubview(self.selectTextBG)
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) { [weak self] in
            guard let self else { return }
            self.selectTextBG.alpha = 1
        }
        
        // text view
        self.textView.frame = CGRect(x: 0, y: 0, width: fullWidth - 60, height: 240)
        self.textView.text = self.textToUse
        self.textView.textColor = UIColor.label
        self.textView.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .regular)
        self.textView.backgroundColor = GlobalStruct.backgroundTint
        self.textView.layer.cornerCurve = .continuous
        self.textView.layer.cornerRadius = 12
        self.textView.isEditable = false
        self.textView.isSelectable = true
        self.textView.textContainerInset = UIEdgeInsets(top: 8, left: 9, bottom: 8, right: 9)
        self.textView.sizeToFit()
        self.selectTextFG.addSubview(self.textView)
        
        // fg
        self.selectTextFG.frame = textView.frame
        self.selectTextFG.layer.shadowColor = UIColor.black.cgColor
        self.selectTextFG.layer.shadowOffset = CGSize(width: 0, height: 15)
        self.selectTextFG.layer.shadowRadius = 14
        self.selectTextFG.layer.shadowOpacity = 0.22
        self.selectTextFG.center = CGPoint(x: fullWidth/2, y: fullHeight/2 + 55)
        self.selectTextFG.backgroundColor = GlobalStruct.backgroundTint
        self.selectTextFG.layer.cornerCurve = .continuous
        self.selectTextFG.layer.cornerRadius = 12
        self.selectTextFG.alpha = 0
        self.selectTextBG.addSubview(self.selectTextFG)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) { [weak self] in
            guard let self else { return }
            self.selectTextFG.center = CGPoint(x: fullWidth/2, y: fullHeight/2)
            self.selectTextFG.alpha = 1
        } completion: { x in
            self.textView.selectAll(self)
        }
    }
    
    @objc func dismissSelectText() {
        let windowFrame = UIApplication.shared.connectedScenes
            .compactMap({ scene -> UIWindow? in
                (scene as? UIWindowScene)?.windows.first
            }).first?.frame
        
        var fullWidth = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds.width ?? UIScreen.main.bounds.width)
        var fullHeight = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds.height ?? UIScreen.main.bounds.height)
#if targetEnvironment(macCatalyst)
        self.selectTextBG.frame = windowFrame ?? .zero
        fullWidth = windowFrame?.size.width ?? 0
        fullHeight = windowFrame?.size.height ?? 0
#else
        self.selectTextBG.frame = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow })?.bounds ?? UIScreen.main.bounds)
#endif
        
        self.textView.selectedTextRange = nil
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveLinear]) { [weak self] in
            guard let self else { return }
            self.selectTextBG.alpha = 0
            self.selectTextFG.center = CGPoint(x: fullWidth/2, y: fullHeight/2 + 55)
        }
    }
}

class CustomUITextView: UITextView, UIEditMenuInteractionDelegate {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(filterPhrase) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func editMenu(for textRange: UITextRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        let filterAction = UIAction(title: "Filter Phrase") { (action) in
            self.filterPhrase()
        }
        let translateAction = UIAction(title: "Translate") { (action) in
            self.translate()
        }
        var actions = suggestedActions
        actions.insert(translateAction, at: 0)
        actions.insert(filterAction, at: 0)
        return UIMenu(children: actions)
    }
    
    @objc func filterPhrase() {
//        if let range = self.selectedTextRange, let selectedText = self.text(in: range) {
//            let areas: [Int] = [0, 1, 2, 3, 4]
//            let duration: String = "Forever"
//            let filter = FilterModel(content: selectedText.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines), areas: areas, duration: duration, expiry: nil)
//            if GlobalStruct.keywordFilters.contains(where: { x in
//                x.content ?? "" == selectedText
//            }) {
//                
//            } else {
//                GlobalStruct.keywordFilters.append(filter)
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateFilters"), object: nil)
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateFilters2"), object: nil)
//            }
//        }
    }
    
    @objc func translate() {
        if let range = self.selectedTextRange, let selectedText = self.text(in: range) {
            translateText(selectedText)
        }
    }
}

// translations

struct TranslateSwiftUI: View {
    @State private var showTranslation = true
    var body: some View {
        if #available(iOS 17.4, *) {
            VStack {
                
            }
            .background(.clear)
            .translationPresentation(isPresented: $showTranslation, text: GlobalStruct.originalTranslationText)
            .navigationTitle("Translate")
        }
    }
}

func translateText(_ text: String) {
    GlobalStruct.originalTranslationText = text
    let swiftUIView = TranslateSwiftUI()
    let hostingController = UIHostingController(rootView: swiftUIView)
    getTopMostViewController()?.addChild(hostingController)
    getTopMostViewController()?.view.addSubview(hostingController.view)
    hostingController.view.backgroundColor = .clear
    hostingController.didMove(toParent: getTopMostViewController())
    hostingController.popoverPresentationController?.sourceView = getTopMostViewController()?.view
}

// resolve users

func resolveUser(_ author: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil) -> String {
    if let user = author?.displayName {
        if user == "" {
            return author?.actorHandle ?? ""
        } else {
            return user
        }
    } else {
        return author?.actorHandle ?? ""
    }
}

func resolveUser(_ author: AppBskyLexicon.Actor.ProfileViewDefinition? = nil) -> String {
    if let user = author?.displayName {
        if user == "" {
            return author?.actorHandle ?? ""
        } else {
            return user
        }
    } else {
        return author?.actorHandle ?? ""
    }
}

func resolvePostURL(_ authorHandle: String, uri: String) -> String {
    let id = uri.split(separator: "/").last ?? ""
    return "https://bsky.app/profile/\(authorHandle)/post/\(id)"
}

extension UIView {
    func findSuperview<T: UIView>(ofType type: T.Type) -> T? {
        var view: UIView? = self
        while view != nil {
            if let typedView = view as? T {
                return typedView
            }
            view = view?.superview
        }
        return nil
    }
}

// favicons

struct FavIcon {
    enum Size: Int, CaseIterable { case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512 }
    private let domain: String
    init(_ domain: String) { self.domain = domain }
    subscript(_ size: Size) -> String {
        "https://www.google.com/s2/favicons?sz=\(size.rawValue)&domain=\(domain)"
    }
}

// drafts

struct PostDrafts: Codable {
    let text: String
    let createdAt: Date
    let media: [Data]?
    let reply: PostDraftsQuoteReply?
    let quote: PostDraftsQuoteReply?
}

struct PostDraftsQuoteReply: Codable {
    let uri: String
    let cid: String
}

// other

struct PinnedItems: Codable {
    let name: String
    let uri: String
    let feedItem: AppBskyLexicon.Feed.GeneratorViewDefinition?
    let listItem: AppBskyLexicon.Graph.ListViewDefinition?
}

func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
    let aspectWidth = newSize.width / image.size.width
    let aspectHeight = newSize.height / image.size.height
    let aspectRatio = min(aspectWidth, aspectHeight)
    let scaledImageSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let newImage = renderer.image { context in
        let xPos = (newSize.width - scaledImageSize.width) / 2
        let yPos = (newSize.height - scaledImageSize.height) / 2
        image.draw(in: CGRect(x: xPos, y: yPos, width: scaledImageSize.width, height: scaledImageSize.height))
    }
    return newImage
}

// haptics

func defaultHaptics() {
    if GlobalStruct.switchHaptics {
        let haptics = UIImpactFeedbackGenerator(style: .medium)
        haptics.impactOccurred()
    }
}

// quotes

class QuoteCacheManager {
    static let shared = QuoteCacheManager()
    private var cache = [String: AppBskyLexicon.Feed.PostViewDefinition]()
    private var inflightTasks = [String: Task<AppBskyLexicon.Feed.PostViewDefinition?, Never>]()
    
    func getQuote(for uri: String, fetcher: @escaping () async throws -> AppBskyLexicon.Feed.PostViewDefinition?) async -> AppBskyLexicon.Feed.PostViewDefinition? {
        if let cached = QuoteCacheManager.shared.cache[uri] {
            return cached
        }
        if let task = QuoteCacheManager.shared.inflightTasks[uri] {
            return await task.value
        }
        let task = Task { () -> AppBskyLexicon.Feed.PostViewDefinition? in
            defer {
                QuoteCacheManager.shared.inflightTasks[uri] = nil
            }
            do {
                if let quote = try await fetcher() {
                    QuoteCacheManager.shared.cache[uri] = quote
                    return quote
                }
            } catch {
                print("Error fetching quote: \(error.localizedDescription)")
            }
            return nil
        }
        QuoteCacheManager.shared.inflightTasks[uri] = task
        return await task.value
    }
}

// context menus

func makePostContextMenu(_ indexPathRow: Int, post: AppBskyLexicon.Feed.PostViewDefinition? = nil, reason: ATUnion.ReasonRepostUnion? = nil) -> UIMenu {
    let topMenu = [createActionButtonsMenu(post)]
    if GlobalStruct.readerMode {
        let fullMenu = UIMenu(title: "", options: [.displayInline], children: [createExtrasMenu(post, reason: reason, showBookmark: true)] + [createViewMenu(post)] + [createShareMenu(post)] + [createReportMenu(post)])
        return UIMenu(title: "", options: [], children: [fullMenu])
    } else {
        let fullMenu = UIMenu(title: "", options: [.displayInline], children: topMenu + [createExtrasMenu(post, reason: reason, showBookmark: true)] + [createViewMenu(post)] + [createShareMenu(post)] + [createReportMenu(post)])
        return UIMenu(title: "", options: [], children: [fullMenu])
    }
}

func createActionButtonsMenu(_ post: AppBskyLexicon.Feed.PostViewDefinition? = nil) -> UIMenu {
    var menuActions: [UIAction] = []
    let menuItem1 = UIAction(title: "", image: UIImage(systemName: "arrowshape.turn.up.left"), identifier: nil) { action in
        defaultHaptics()
        let vc = ComposerViewController()
        if let post = post {
            vc.allPosts = [post]
        }
        let nvc = SloppySwipingNav(rootViewController: vc)
        nvc.isModalInPresentation = true
        getTopMostViewController()?.present(nvc, animated: true, completion: nil)
    }
    if post?.viewer?.areRepliesDisabled ?? false {
        menuItem1.attributes = .disabled
    }
    menuActions.append(menuItem1)
    
    let menuItem2 = UIAction(title: "", image: UIImage(systemName: "quote.bubble"), identifier: nil) { action in
        defaultHaptics()
        let vc = ComposerViewController()
        vc.isQuote = true
        if let post = post {
            vc.allPosts = [post]
        }
        let nvc = SloppySwipingNav(rootViewController: vc)
        nvc.isModalInPresentation = true
        getTopMostViewController()?.present(nvc, animated: true, completion: nil)
    }
    if post?.viewer?.isEmbeddingDisabled ?? false {
        menuItem2.attributes = .disabled
    }
    menuActions.append(menuItem2)
    let menuItem3 = UIAction(title: "", image: UIImage(systemName: "arrow.2.squarepath"), identifier: nil) { action in
        
    }
    menuActions.append(menuItem3)
    let menuItem4 = UIAction(title: "", image: UIImage(systemName: "heart"), identifier: nil) { action in
        
    }
    menuActions.append(menuItem4)
    let menu = UIMenu(title: "", options: [.displayInline], children: menuActions)
    menu.preferredElementSize = .small
    return menu
}

func createRepostButtonsMenu(_ post: AppBskyLexicon.Feed.PostViewDefinition? = nil) -> UIMenu {
    var menuActions: [UIAction] = []
    let menuItem1 = UIAction(title: "Repost", image: UIImage(systemName: "arrow.2.squarepath"), identifier: nil) { action in
        
    }
    menuActions.append(menuItem1)
    let menuItem2 = UIAction(title: "Quote Post", image: UIImage(systemName: "quote.bubble"), identifier: nil) { action in
        defaultHaptics()
        let vc = ComposerViewController()
        vc.isQuote = true
        if let post = post {
            vc.allPosts = [post]
        }
        let nvc = SloppySwipingNav(rootViewController: vc)
        nvc.isModalInPresentation = true
        getTopMostViewController()?.present(nvc, animated: true, completion: nil)
    }
    if post?.viewer?.isEmbeddingDisabled ?? false {
        menuItem2.attributes = .disabled
    }
    menuActions.append(menuItem2)
    let menu = UIMenu(title: "", options: [.displayInline], children: menuActions)
    return menu
}

func createExtrasMenu(_ post: AppBskyLexicon.Feed.PostViewDefinition? = nil, reason: ATUnion.ReasonRepostUnion? = nil, showBookmark: Bool = false) -> UIMenu {
    var menuActions: [UIAction] = []
//    if post?.author.actorDID ?? "" == GlobalStruct.currentUser?.actorDID ?? "" {
//        if let reason = reason {
//            switch reason {
//            case .reasonPin( _):
//                let menuItem1 = UIAction(title: "Unpin Post from Profile", image: UIImage(systemName: "pin.slash"), identifier: nil) { action in
//                    
//                }
//                menuActions.append(menuItem1)
//            default:
//                break
//            }
//        } else {
//            let menuItem1 = UIAction(title: "Pin Post to Profile", image: UIImage(systemName: "pin"), identifier: nil) { action in
//
//            }
//            menuActions.append(menuItem1)
//        }
//    }
    if showBookmark {
        if let post = post {
            if GlobalStruct.bookmarks.contains(post) {
                let menuItem1 = UIAction(title: "Remove Bookmark", image: UIImage(systemName: "bookmark.slash"), identifier: nil) { action in
                    defaultHaptics()
                    removeBookmark(post)
                }
                menuActions.append(menuItem1)
            } else {
                let menuItem1 = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark"), identifier: nil) { action in
                    defaultHaptics()
                    bookmark(post)
                }
                menuActions.append(menuItem1)
            }
        }
    }
    let menuItem2 = UIAction(title: "Translate Post", image: UIImage(systemName: "translate"), identifier: nil) { action in
        if let record = post?.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
            translateText(record.text)
        }
    }
    menuActions.append(menuItem2)
    return UIMenu(title: "", options: [.displayInline], children: menuActions)
}

func createViewMenu(_ post: AppBskyLexicon.Feed.PostViewDefinition? = nil) -> UIMenu {
    var menuActions: [UIAction] = []
    let menuItem1 = UIAction(title: "View Likes", image: UIImage(systemName: "heart"), identifier: nil) { action in
        let vc = LikesRepostsViewController()
        vc.postURI = post?.uri ?? ""
        vc.type = .likes
        UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
    }
    menuActions.append(menuItem1)
    let menuItem2 = UIAction(title: "View Reposts", image: UIImage(systemName: "arrow.2.squarepath"), identifier: nil) { action in
        let vc = LikesRepostsViewController()
        vc.postURI = post?.uri ?? ""
        vc.type = .reposts
        UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
    }
    menuActions.append(menuItem2)
    let menuItem3 = UIAction(title: "View Quotes", image: UIImage(systemName: "quote.bubble"), identifier: nil) { action in
        let vc = QuotesViewController()
        vc.postURI = post?.uri ?? ""
        vc.postCID = post?.cid ?? ""
        UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
    }
    menuActions.append(menuItem3)
    return UIMenu(title: "", options: [.displayInline], children: menuActions)
}

func createShareMenu(_ post: AppBskyLexicon.Feed.PostViewDefinition? = nil) -> UIMenu {
    var menuActions: [UIAction] = []
    let menuItem1 = UIAction(title: "Select Text", image: UIImage(systemName: "selection.pin.in.out"), identifier: nil) { action in
        if let x = post?.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
            CopyTextVC.shared.textToUse = x.text
            CopyTextVC.shared.selectText()
        }
    }
    menuActions.append(menuItem1)
    let menuItem2 = UIAction(title: "Share Link", image: UIImage(systemName: "link"), identifier: nil) { action in
        let link = resolvePostURL(post?.author.actorHandle ?? "", uri: post?.uri ?? "")
        if let text = URL(string: link) {
            let textToShare = [text]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = getTopMostViewController()?.view
            activityViewController.popoverPresentationController?.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
            getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
        }
    }
    menuActions.append(menuItem2)
//    let menuItem3 = UIAction(title: "Share as Image", image: UIImage(systemName: "photo.on.rectangle.angled"), identifier: nil) { action in
//        
//    }
//    menuActions.append(menuItem3)
    return UIMenu(title: "", options: [.displayInline], children: menuActions)
}

func createReportMenu(_ post: AppBskyLexicon.Feed.PostViewDefinition? = nil) -> UIMenu {
    if post?.author.actorDID ?? "" == GlobalStruct.currentUser?.actorDID ?? "" {
        var menuActions: [UIAction] = []
        let menuItem1 = UIAction(title: "Delete...", image: UIImage(systemName: "trash"), identifier: nil) { action in
            
        }
        menuItem1.attributes = .destructive
        menuActions.append(menuItem1)
        return UIMenu(title: "", options: [.displayInline], children: menuActions)
    } else {
        var menuActions: [UIAction] = []
        let menuItem1 = UIAction(title: "Report...", image: UIImage(systemName: "exclamationmark.shield"), identifier: nil) { action in
            let vc = ReportViewController()
            vc.currentPost = post
            let nvc = SloppySwipingNav(rootViewController: vc)
            getTopMostViewController()?.present(nvc, animated: true, completion: nil)
        }
        menuItem1.attributes = .destructive
        menuActions.append(menuItem1)
        return UIMenu(title: "", options: [.displayInline], children: menuActions)
    }
}

func createLinkMenu(_ currentLink: String) -> UIMenu {
    var menuActions: [UIAction] = []
    let view = UIAction(title: "View Link", image: UIImage(systemName: "safari"), identifier: nil) { action in
        if let url = URL(string: currentLink) {
            if GlobalStruct.openLinksInApp {
                let safariVC = SFSafariViewController(url: url)
                getTopMostViewController()?.present(safariVC, animated: true, completion: nil)
            } else {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    menuActions.append(view)
    let copy = UIAction(title: "Copy Link", image: UIImage(systemName: "doc.on.doc"), identifier: nil) { action in
        if let url = URL(string: currentLink) {
            UIPasteboard.general.url = url
        }
    }
    menuActions.append(copy)
    let share = UIAction(title: "Share Link", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
        if let url = URL(string: currentLink) {
            let urlToShare = [url]
            let activityViewController = UIActivityViewController(activityItems: urlToShare,  applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = getTopMostViewController()?.view
            activityViewController.popoverPresentationController?.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
            getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
        }
    }
    menuActions.append(share)
    return UIMenu(title: "", options: [.displayInline], children: menuActions)
}

func createImageMenu(_ imageView: UIImageView? = nil, imageInstead: UIImage? = nil) -> UIMenu {
    var image: UIImage!
    if let imageToUse = imageView?.image {
        image = imageToUse
    } else {
        image = imageInstead
    }
    let translateImage = UIAction(title: "Translate Image Text", image: UIImage(systemName: "translate"), identifier: nil) { action in
        guard let img = image.cgImage else {
            return
        }
        let requestHandler = VNImageRequestHandler(cgImage: img, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            var imageText: String = ""
            for observation in observations {
                let topCandidate: [VNRecognizedText] = observation.topCandidates(1)
                if let recognizedText: VNRecognizedText = topCandidate.first {
                    let message = recognizedText.string
                    imageText = "\(imageText) \(message)"
                }
            }
            translateText(imageText)
        }
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        try? requestHandler.perform([request])
    }
    let subMenu = UIMenu(title: "", options: [.displayInline], children: [translateImage])
    let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc"), identifier: nil) { action in
        UIPasteboard.general.image = image
    }
    let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
        let imToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imToShare,  applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = getTopMostViewController()?.view
        activityViewController.popoverPresentationController?.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
        getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
    }
    let save = UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down")) { _ in
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    return UIMenu(title: "", children: [subMenu, copy, share, save])
}

func createVideoMenu(_ asset: AVAsset? = nil) -> UIMenu {
    let save = UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down")) { _ in
        if let x = ((asset) as? AVURLAsset)?.url {
            DispatchQueue.global(qos: .background).async {
                if let urlData = NSData(contentsOf: x) {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let filePath="\(documentsPath)/tempFile.mp4"
                    DispatchQueue.main.async {
                        urlData.write(toFile: filePath, atomically: true)
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { completed, error in
                            if completed {
                                print("Video is saved!")
                            }
                            if error != nil {
                                print("error saving video: \(String(describing: error?.localizedDescription))")
                            }
                        }
                    }
                }
            }
        }
    }
    return UIMenu(title: "", children: [save])
}

func createMoreProfileMenu(_ profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition? = nil, basicProfile: AppBskyLexicon.Actor.ProfileViewBasicDefinition? = nil, defaultProfile: AppBskyLexicon.Actor.ProfileViewDefinition? = nil) -> UIMenu {
    if profile?.actorDID ?? "" == GlobalStruct.currentUser?.actorDID ?? "" || basicProfile?.actorDID ?? "" == GlobalStruct.currentUser?.actorDID ?? "" || defaultProfile?.actorDID ?? "" == GlobalStruct.currentUser?.actorDID ?? "" {
        
        var viewsActions: [UIAction] = []
        let viewBookmarks = UIAction(title: "Bookmarks", image: UIImage(systemName: "bookmark"), identifier: nil) { action in
            let vc = BookmarksViewController()
            vc.fromNavigation = true
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
        }
        viewsActions.append(viewBookmarks)
        let viewLikes = UIAction(title: "Likes", image: UIImage(systemName: "heart"), identifier: nil) { action in
            let vc = LikesViewController()
            vc.fromNavigation = true
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
        }
        viewsActions.append(viewLikes)
        let lists = UIAction(title: "Lists", image: UIImage(systemName: "list.bullet"), identifier: nil) { action in
            let vc = FeedsListsViewController()
            vc.otherListUser = profile?.actorHandle ?? basicProfile?.actorHandle ?? defaultProfile?.actorHandle ?? ""
            UIApplication.shared.pushToCurrentNavigationController(vc)
        }
        viewsActions.append(lists)
        let viewMessages = UIAction(title: "Messages", image: UIImage(systemName: "bubble.left"), identifier: nil) { action in
            let vc = MessagesViewController()
            vc.fromNavigation = true
            UIApplication.shared.pushToCurrentNavigationController(vc, animated: true)
        }
        viewsActions.append(viewMessages)
        let viewsMenu = UIMenu(title: "", options: [.displayInline], children: viewsActions)
        
        var extraActions: [UIAction] = []
        let addToList = UIAction(title: "Edit Profile", image: UIImage(systemName: "pencil.and.scribble"), identifier: nil) { action in
            
        }
        extraActions.append(addToList)
        let extrasMenu = UIMenu(title: "", options: [.displayInline], children: extraActions)
        var menuActions: [UIAction] = []
        let share = UIAction(title: "Share Profile", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            if let url = URL(string: "https://bsky.app/profile/\(profile?.actorHandle ?? basicProfile?.actorHandle ?? defaultProfile?.actorHandle ?? "")") {
                let urlToShare = [url]
                let activityViewController = UIActivityViewController(activityItems: urlToShare,  applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = getTopMostViewController()?.view
                activityViewController.popoverPresentationController?.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
                getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
            }
        }
        menuActions.append(share)
        let shareMenu = UIMenu(title: "", options: [.displayInline], children: menuActions)
        return UIMenu(title: "", options: [.displayInline], children: [viewsMenu] + [extrasMenu] + [shareMenu])
    } else {
        var mentionActions: [UIAction] = []
        let mention = UIAction(title: "Mention...", image: UIImage(systemName: "at"), identifier: nil) { action in
            
        }
        mentionActions.append(mention)
        let message = UIAction(title: "Message...", image: UIImage(systemName: "bubble.left"), identifier: nil) { action in
            
        }
        mentionActions.append(message)
        let mentionMenu = UIMenu(title: "", options: [.displayInline], children: mentionActions)
        
        var extraActions: [UIAction] = []
        let lists = UIAction(title: "Lists", image: UIImage(systemName: "list.bullet"), identifier: nil) { action in
            let vc = FeedsListsViewController()
            vc.otherListUser = profile?.actorHandle ?? basicProfile?.actorHandle ?? defaultProfile?.actorHandle ?? ""
            UIApplication.shared.pushToCurrentNavigationController(vc)
        }
        extraActions.append(lists)
        let addToList = UIAction(title: "Add to List", image: UIImage(systemName: "text.badge.plus"), identifier: nil) { action in
            
        }
        extraActions.append(addToList)
        let extrasMenu = UIMenu(title: "", options: [.displayInline], children: extraActions)
        var profileActions: [UIAction] = []
        let mute = UIAction(title: "Mute Account", image: UIImage(systemName: "speaker.slash"), identifier: nil) { action in
            
        }
        mute.attributes = .destructive
        profileActions.append(mute)
        let block = UIAction(title: "Block Account", image: UIImage(systemName: "hand.raised"), identifier: nil) { action in
            
        }
        block.attributes = .destructive
        profileActions.append(block)
        let report = UIAction(title: "Report Account", image: UIImage(systemName: "exclamationmark.shield"), identifier: nil) { action in
            
        }
        report.attributes = .destructive
        profileActions.append(report)
        var menuActions: [UIAction] = []
        let share = UIAction(title: "Share Profile", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            if let url = URL(string: "https://bsky.app/profile/\(profile?.actorHandle ?? basicProfile?.actorHandle ?? defaultProfile?.actorHandle ?? "")") {
                let urlToShare = [url]
                let activityViewController = UIActivityViewController(activityItems: urlToShare,  applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = getTopMostViewController()?.view
                activityViewController.popoverPresentationController?.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
                getTopMostViewController()?.present(activityViewController, animated: true, completion: nil)
            }
        }
        menuActions.append(share)
        let shareMenu = UIMenu(title: "", options: [.displayInline], children: menuActions)
        return UIMenu(title: "", options: [.displayInline], children: [mentionMenu] + [extrasMenu] + profileActions + [shareMenu])
    }
}
