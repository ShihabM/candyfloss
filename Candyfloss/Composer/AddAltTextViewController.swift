//
//  AddAltTextViewController.swift
//  Candyfloss
//
//  Created by Shihab Mehboob on 01/05/2025.
//

import UIKit
import AVFoundation
import AVKit
import Vision

class AddAltTextViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVPlayerViewControllerDelegate, UITextViewDelegate {
    
    var tableView = UITableView()
    var keyHeight: CGFloat = 0
    var fromVideo: Bool = false
    var fromEdit: Bool = false
    var theImage: UIImage? = nil
    var imageIndex: Int = 0
    var imageAltText: String = ""
    var currentText: String = ""
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GlobalStruct.backgroundTint
        if fromEdit {
            navigationItem.title = "Edit Alt Text"
        } else {
            navigationItem.title = "Add Alt Text"
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = view.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
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
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let button2 = CustomButton(type: .system)
        button2.setTitle("Add", for: .normal)
        button2.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button2.addTarget(self, action: #selector(self.addNote), for: .touchUpInside)
        let barButtonItem2 = UIBarButtonItem(customView: button2)
        barButtonItem2.accessibilityLabel = "Add"
        self.navigationItem.rightBarButtonItem = barButtonItem2
        
        setUpTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.imageAltText != "" {
            self.fromEdit = true
        }
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NoteCell {
            cell.post.becomeFirstResponder()
        }
    }
    
    @objc func dismissView() {
        defaultHaptics()
        self.dismiss(animated: true)
    }
    
    //
    
    func setUpTable() {
        tableView.removeFromSuperview()
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(NoteCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell1")
        tableView.register(PlainCell.self, forCellReuseIdentifier: "PlainCell2")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = GlobalStruct.groupBG
        tableView.layer.masksToBounds = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView()
        view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if fromVideo {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
            
            cell.post.placeholder = "Alt text..."
            if self.fromEdit {
                cell.post.text = self.imageAltText
            }
            cell.post.delegate = self
            
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            cell.hoverStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath) as! PlainCell
            
            cell.theTitle.text = "Add Text From Image"
            
            cell.accessoryType = .none
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            cell.backgroundColor = GlobalStruct.backgroundTint
            cell.hoverStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            defaultHaptics()
            if let img = theImage?.cgImage {
                let requestHandler = VNImageRequestHandler(cgImage: img, options: [:])
                let request = VNRecognizeTextRequest { (request, error) in
                    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                    var str: String = ""
                    for observation in observations {
                        let topCandidate: [VNRecognizedText] = observation.topCandidates(1)
                        if let recognizedText: VNRecognizedText = topCandidate.first {
                            let mess = recognizedText.string
                            str = "\(str) \(mess)"
                        }
                    }
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NoteCell {
                        cell.post.text = str
                        self.currentText = str
                        self.updateAddButton()
                    }
                }
                request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
                try? requestHandler.perform([request])
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.currentText = textView.text
        if textView.text == "" && self.fromEdit == false {
            let button = CustomButton(type: .system)
            button.setTitle("Add", for: .normal)
            button.setTitleColor(GlobalStruct.secondaryTextColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(self.addNote), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButtonItem
        } else if textView.text == "" && self.fromEdit {
            let button = CustomButton(type: .system)
            button.setTitle("Remove", for: .normal)
            button.setTitleColor(GlobalStruct.baseTint, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(self.addNote), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButtonItem
        } else {
            let button = CustomButton(type: .system)
            button.setTitle("Add", for: .normal)
            button.setTitleColor(GlobalStruct.baseTint, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.addTarget(self, action: #selector(self.addNote), for: .touchUpInside)
            let barButtonItem = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    
    func updateAddButton() {
        let button = CustomButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.setTitleColor(GlobalStruct.baseTint, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(self.addNote), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func addNote() {
        defaultHaptics()
        GlobalStruct.currentMediaAltText = currentText
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateMediaAltText"), object: nil)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            if fromVideo {
                return "\nAlternate video text descriptions provide more context about the video, and helps with accessibility."
            } else {
                return "\nAlternate image text descriptions provide more context about the image, and helps with accessibility."
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
