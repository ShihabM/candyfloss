//
//  AllStarterPacksViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 22/04/2025.
//

import UIKit
import ATProtoKit

class AllStarterPacksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var tableView = UITableView()
    var starterPacks: [AppBskyLexicon.Graph.StarterPackViewBasicDefinition] = []
    var currentCursor: String? = nil
    var isFetching: Bool = false
    var currentActorHandle: String = ""
    
    // inline search
    var searchView: UIView = UIView()
    var searchController = UISearchController()
    var searchResults: [AppBskyLexicon.Graph.StarterPackViewBasicDefinition] = []
    var isSearching: Bool = false
    var searchFirstTime: Bool = true
    
    override func viewDidLayoutSubviews() {
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = searchView.frame.size.width
        searchController.searchBar.frame.size.height = searchView.frame.size.height
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchResults.isEmpty {} else {
            starterPacks = searchResults
        }
        if let theText = searchController.searchBar.text?.lowercased() {
            if theText.isEmpty {
                isSearching = false
                if searchFirstTime {
                    searchFirstTime = false
                    searchResults = starterPacks
                } else {
                    starterPacks = searchResults
                    tableView.reloadData()
                }
            } else {
                let x = searchResults.filter {
                    if let record = $0.record.getRecord(ofType: AppBskyLexicon.Graph.StarterpackRecord.self) {
                        return record.name.lowercased().contains(theText) || (record.description ?? "").lowercased().contains(theText)
                    }
                    return false
                }
                starterPacks = x
                tableView.reloadData()
                isSearching = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        if !searchResults.isEmpty {
            starterPacks = self.searchResults
            tableView.reloadData()
        }
        searchFirstTime = true
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
            let defaultFontSize = UIFont.preferredFont(forTextStyle: .title3).pointSize
            let smallerFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let smallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 2
            let mostSmallestFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize - 4
            for x in self.tableView.visibleCells {
                if let y = x as? StarterPackListCell {
                    y.backgroundColor = GlobalStruct.backgroundTint
                    y.theTitle.font = UIFont.systemFont(ofSize: defaultFontSize + GlobalStruct.customTextSize, weight: .bold)
                    y.theAuthor.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                    y.theDescription.font = UIFont.systemFont(ofSize: smallerFontSize + GlobalStruct.customTextSize, weight: .regular)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        navigationItem.title = "Starter Packs"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTint), name: NSNotification.Name(rawValue: "updateTint"), object: nil)
        
        setUpNavigationBar()
        setUpTable()
        if starterPacks.isEmpty {
            fetchStarterPacks()
        }
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
    }
    
    func fetchStarterPacks() {
        Task {
            do {
                if let atProto = GlobalStruct.atProto {
                    let x = try await atProto.getActorStarterPacks(by: currentActorHandle, cursor: currentCursor)
                    starterPacks += x.starterPacks
                    currentCursor = x.cursor
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.isFetching = false
                    }
                }
            } catch {
                print("Error fetching starter packs: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isFetching = false
                }
            }
        }
    }
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView.tableHeaderView?.frame.size.height = 56
        tableView.register(StarterPackListCell.self, forCellReuseIdentifier: "StarterPackListCell")
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
            controller.searchBar.placeholder = "Search Starter Packs"
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
        return starterPacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StarterPackListCell", for: indexPath) as! StarterPackListCell
        
        cell.configureCell()
        if let url = starterPacks[indexPath.row].creator.avatarImageURL {
            cell.avatar.sd_imageTransition = .fade
            cell.avatar.sd_setImage(with: url, for: .normal)
        } else {
            cell.avatar.setImage(UIImage(), for: .normal)
        }
        cell.avatar.backgroundColor = .systemBlue
        cell.theAuthor.text = "by @\(starterPacks[indexPath.row].creator.actorHandle)"
        if let record = starterPacks[indexPath.row].record.getRecord(ofType: AppBskyLexicon.Graph.StarterpackRecord.self) {
            cell.theTitle.text = record.name
            cell.theDescription.text = record.description
        }
        cell.theDescription.numberOfLines = 2
        
        if indexPath.row == starterPacks.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
        }
        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = GlobalStruct.backgroundTint
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = StarterPackViewController()
        vc.showingMembers = true
        if let record = starterPacks[indexPath.row].record.getRecord(ofType: AppBskyLexicon.Graph.StarterpackRecord.self) {
            vc.starterPackURI = record.listURI
            vc.starterPackDisplayName = record.name
            vc.starterPack = starterPacks[indexPath.row]
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
