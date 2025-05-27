//
//  InputTextViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 27/05/2025.
//

import UIKit

class InputTextViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    var tableView = UITableView()
    var currentUser: String = ""
    var currentText: String = ""
    var prevText: String = ""
    var isEditingNote: Bool = false
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.modalBackground
        navigationItem.title = "Profile Notes"
        
        prevText = UserDefaults.standard.value(forKey: "profileNote-\(currentUser)") as? String ?? ""
        currentText = prevText
        if currentText != "" {
            isEditingNote = true
        }
        
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
        if isEditingNote {
            doneButton.setTitle("Update", for: .normal)
        } else {
            doneButton.setTitle("Add", for: .normal)
        }
        if (currentText == "" && !isEditingNote) || (currentText == prevText) {
            doneButton.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
        } else {
            doneButton.setTitleColor(GlobalStruct.baseTint, for: .normal)
        }
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        doneButton.addTarget(self, action: #selector(self.saveNote), for: .touchUpInside)
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
    
    @objc func saveNote() {
        if (currentText == "" && !isEditingNote) || (currentText == prevText) {
            
        } else {
            defaultHaptics()
            UserDefaults.standard.set(currentText, forKey: "profileNote-\(currentUser)")
            self.dismiss(animated: true)
        }
    }
    
    //
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView = UITableView(frame: .zero, style: .insetGrouped)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        
        cell.post.text = self.currentText
        cell.post.delegate = self
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        cell.backgroundColor = GlobalStruct.detailQuoteCell
        cell.hoverStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.currentText = textView.text
        setUpNavBar()
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "\nProfile notes help store useful information related to a person's profile. These notes are private and only viewable by you."
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
