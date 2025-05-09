//
//  DraftsViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 29/04/2025.
//

import UIKit
import ATProtoKit

class DraftsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var postURI: String = ""
    var postCID: String = ""
    var currentCursor: String? = nil
    var isFetching: Bool = false
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [PostDrafts] = []
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
            GlobalStruct.drafts = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = GlobalStruct.drafts
                } else {
                    GlobalStruct.drafts = searchResults
                    tableView.reloadData()
                }
            } else {
                let z = GlobalStruct.drafts.filter({
                    return ($0.text ?? "").lowercased().contains(theText)
                })
                GlobalStruct.drafts = z
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            GlobalStruct.drafts = self.searchResults
            tableView.reloadData()
        }
        searchFirstTime = true
    }
    
    @objc func reloadTables() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Drafts"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTables), name: NSNotification.Name(rawValue: "reloadTables"), object: nil)
        
        setUpNavigationBar()
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
        let closeButton = CustomButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(GlobalStruct.baseTint, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        closeButton.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        let closeBarButtonItem = UIBarButtonItem(customView: closeButton)
        closeBarButtonItem.accessibilityLabel = "Dismiss"
        navigationItem.leftBarButtonItem = closeBarButtonItem
        let clearAllButton = CustomButton(type: .system)
        clearAllButton.setTitle("Clear All", for: .normal)
        if GlobalStruct.drafts.isEmpty {
            clearAllButton.setTitleColor(.secondaryLabel, for: .normal)
            clearAllButton.isUserInteractionEnabled = false
        } else {
            clearAllButton.addTarget(self, action: #selector(self.clearAll), for: .touchUpInside)
            clearAllButton.setTitleColor(.systemRed, for: .normal)
            clearAllButton.isUserInteractionEnabled = true
        }
        clearAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let clearAllBarButtonItem = UIBarButtonItem(customView: clearAllButton)
        clearAllBarButtonItem.accessibilityLabel = "Clear All"
        navigationItem.rightBarButtonItem = clearAllBarButtonItem
    }
    
    @objc func dismissView() {
        defaultHaptics()
        dismiss(animated: true)
    }
    
    @objc func clearAll() {
        defaultHaptics()
        let alert = UIAlertController(title: "Clear All", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (UIAlertAction) in
            
        }))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: { (UIAlertAction) in
            GlobalStruct.drafts.removeAll()
            do {
                try Disk.save(GlobalStruct.drafts, to: .documents, as: "drafts.json")
            } catch {
                print("error saving to Disk")
            }
            self.tableView.reloadData()
            self.setUpNavigationBar()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "createToolbar"), object: nil)
        }))
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = getTopMostViewController()?.view
            presenter.sourceRect = getTopMostViewController()?.view.bounds ?? .zero
        }
        getTopMostViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.register(PostsCell.self, forCellReuseIdentifier: "PostsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView)
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
            controller.searchBar.placeholder = "Search Drafts"
            self.definesPresentationContext = true
            searchView.addSubview(controller.searchBar)
            tableView.tableHeaderView = searchView
            return controller
        })()
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalStruct.drafts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
        
        if let url = GlobalStruct.currentUser?.avatarImageURL {
            cell.avatar.sd_setImage(with: url, for: .normal)
        }
        cell.username.text = GlobalStruct.currentUser?.displayName ?? ""
        if cell.username.text == "" {
            cell.username.text = " "
        }
        cell.usertag.text = "@\(GlobalStruct.currentUser?.actorHandle ?? "")"
        cell.text.text = GlobalStruct.drafts[indexPath.row].text
        let timeSince = GlobalStruct.drafts[indexPath.row].createdAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = GlobalStruct.dateFormatter
        if GlobalStruct.dateFormat == 0 {
            cell.time.text = timeSince.toStringWithRelativeTime()
        } else {
            cell.time.text = timeSince.toString(dateStyle: .short, timeStyle: .short)
        }
        cell.configure(post: nil, showActionButtons: false, isRepost: nil, isNestedQuote: false, isNestedReply: false, isPinned: false, fromPreview: true)
        
        if indexPath.row == GlobalStruct.drafts.count - 1 {
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        GlobalStruct.currentDraft = GlobalStruct.drafts[indexPath.row]
        GlobalStruct.drafts.remove(at: indexPath.row)
        do {
            try Disk.save(GlobalStruct.drafts, to: .documents, as: "drafts.json")
        } catch {
            print("error saving to Disk")
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "restoreFromDrafts"), object: nil)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
            GlobalStruct.drafts.remove(at: indexPath.row)
            do {
                try Disk.save(GlobalStruct.drafts, to: .documents, as: "drafts.json")
            } catch {
                print("error saving to Disk")
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "createToolbar"), object: nil)
            completionHandler(true)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let image = UIImage(systemName: "trash.fill", withConfiguration: symbolConfig)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal) ?? UIImage()
        if let circularImage = createImageWithCircularBackground(icon: image, backgroundColor: .systemRed, diameter: 40) {
            removeAction.image = circularImage
        }
        removeAction.backgroundColor = GlobalStruct.backgroundTint
        let configuration = UISwipeActionsConfiguration(actions: [removeAction])
        return configuration
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
    
}
