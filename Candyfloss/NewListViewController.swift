//
//  NewListViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 27/05/2025.
//

import UIKit
import ATProtoKit
import PhotosUI

class NewListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, PHPickerViewControllerDelegate {
    
    var tableView = UITableView()
    var currentListAvatar: URL? = nil
    var currentListURI: String = ""
    var currentTitle: String = ""
    var currentDescription: String? = nil
    var isEditingList: Bool = false
    var photoPickerView: PHPickerViewController!
    var photoData: Data? = nil
    var canCreate: Bool = true
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.modalBackground
        if isEditingList {
            navigationItem.title = "Edit List"
        } else {
            navigationItem.title = "New List"
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
        if isEditingList {
            doneButton.setTitle("Update", for: .normal)
        } else {
            doneButton.setTitle("Create", for: .normal)
        }
        if currentTitle != "" && canCreate {
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
        if canCreate {
            if currentTitle != "" {
                canCreate = false
                setUpNavBar()
                Task {
                    do {
                        if let atProto = GlobalStruct.atProto {
                            let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProto)
                            if self.isEditingList {
                                let _ = try await atProtoBluesky.updateListRecord(listURI: self.currentListURI, replace: [.name(with: self.currentTitle), .description(with: self.currentDescription), .listAvatarImage(with: .init(imageData: self.photoData ?? Data(), fileName: "\(UUID().uuidString)-listImage", altText: nil, aspectRatio: nil))])
                            } else {
                                let _ = try await atProtoBluesky.createListRecord(named: self.currentTitle, ofType: .curation, description: self.currentDescription, listAvatarImage: .init(imageData: self.photoData ?? Data(), fileName: "\(UUID().uuidString)-listImage", altText: nil, aspectRatio: nil))
                            }
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshLists"), object: nil)
                                self.dismiss(animated: true)
                            }
                        }
                    } catch {
                        print("error creating list: \(error)")
                        canCreate = true
                        setUpNavBar()
                    }
                }
            }
        }
    }
    
    //
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(AvatarInputCell.self, forCellReuseIdentifier: "AvatarInputCell")
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarInputCell", for: indexPath) as! AvatarInputCell
            
            if currentListAvatar != nil {
                cell.avatar.sd_setImage(with: currentListAvatar, for: .normal)
            }
            cell.avatar.addTarget(self, action: #selector(avatarTapped(_:)), for: .touchUpInside)
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = .clear
            cell.hoverStyle = .none
            return cell
        } else if indexPath.section == 1 {
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
    
    @objc func avatarTapped(_ sender: UIButton) {
        defaultHaptics()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .any(of: [.images, .screenshots, .depthEffectPhotos])
                self.photoPickerView = PHPickerViewController(configuration: configuration)
                self.photoPickerView.modalPresentationStyle = .popover
                self.photoPickerView.delegate = self
                if let presenter = self.photoPickerView.popoverPresentationController {
                    presenter.sourceView = self.view
                    presenter.sourceRect = self.view.bounds
                }
                if let sheet = self.photoPickerView.popoverPresentationController?.adaptiveSheetPresentationController {
                    sheet.detents = [.large()]
                }
                self.present(self.photoPickerView, animated: true, completion: nil)
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        _ = results.map({ x in
            if x.itemProvider.canLoadObject(ofClass: UIImage.self) {
                x.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        if let photoToAttach = image as? UIImage {
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AvatarInputCell {
                                cell.avatar.setImage(photoToAttach, for: .normal)
                                self.photoData = photoToAttach.jpegData(compressionQuality: 0.4)
                            }
                        }
                    }
                }
            }
        })
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
