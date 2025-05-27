//
//  NewListViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 27/05/2025.
//

import UIKit
import ATProtoKit

class NewListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    var tableView = UITableView()
    var currentTitle: String = ""
    var currentDescription: String? = nil
    var isEditingList: Bool = false
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.modalBackground
        navigationItem.title = "New List"
        
        setUpNavBar()
        setUpTable()
    }
    
    func setUpNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = GlobalStruct.backgroundTint
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = UIColor.separator
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        let button = CustomButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(GlobalStruct.baseTint, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(self.dismissView), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.accessibilityLabel = "Dismiss"
        navigationItem.leftBarButtonItem = barButtonItem
        
        let doneButton = CustomButton(type: .system)
        if isEditingList {
            doneButton.setTitle("Update", for: .normal)
        } else {
            doneButton.setTitle("Create", for: .normal)
        }
        if currentTitle != "" {
            doneButton.setTitleColor(GlobalStruct.baseTint, for: .normal)
        } else {
            doneButton.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
        }
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        doneButton.addTarget(self, action: #selector(self.saveList), for: .touchUpInside)
        let doneBarButtonItem = UIBarButtonItem(customView: doneButton)
        doneBarButtonItem.accessibilityLabel = "Done"
        navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NoteCell {
            cell.post.becomeFirstResponder()
        }
    }
    
    @objc func dismissView() {
        defaultHaptics()
        self.dismiss(animated: true)
    }
    
    @objc func saveList() {
        if currentTitle != "" {
            Task {
                do {
                    if let atProto = GlobalStruct.atProto {
                        let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                        let _ = try await atProtoBluesky.createListRecord(named: self.currentTitle, ofType: .curation, description: self.currentDescription)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshLists"), object: nil)
                            self.dismiss(animated: true)
                        }
                    }
                } catch {
                    print("error creating list: \(error)")
                }
            }
        }
    }
    
    //
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TitleInputCell.self, forCellReuseIdentifier: "TitleInputCell")
        tableView.register(NoteCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = GlobalStruct.modalBackground
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView()
        view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleInputCell", for: indexPath) as! TitleInputCell
            
            cell.post.text = self.currentTitle
            cell.post.tag = 0
            cell.post.delegate = self
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.detailQuoteCell
            cell.hoverStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
            
            cell.post.text = self.currentDescription ?? ""
            cell.post.tag = 1
            cell.post.delegate = self
            cell.post.placeholder = "List description..."
            cell.post.accessibilityLabel = "List description..."
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.detailQuoteCell
            cell.hoverStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 0 {
            self.currentTitle = textView.text
        } else {
            self.currentDescription = textView.text
        }
        setUpNavBar()
    }
    
}
