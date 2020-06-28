//
//  DetailViewController.swift
//  Challenge7
//
//  Created by Rohit Lunavara on 6/17/20.
//  Copyright © 2020 Rohit Lunavara. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    let defaults = UserDefaults.standard
    
    var note : Note!
    var noteIndex : Int!
    
    @IBOutlet var noteContent: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadNoteContent()
        addKeyboardNotificationObservers()
        addButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        customizeNavbar()
        noteContent.becomeFirstResponder()
    }
    
    func customizeNavbar() {
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)]
    }
    
    //MARK: - Stop editing when touched outside of UITextView

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

//MARK: - Load and Save notes

extension DetailViewController {
    
    func loadNoteContent() {
        title = note.title
        noteContent.text = note.content
    }
    
    func saveNoteChanges(remove : Bool = false) {
        if !remove {
            note.title = title ?? "New Note"
            note.content = noteContent.text
            notes[noteIndex] = note
        }

        let jsonEncoder = JSONEncoder()
        if let savedNotes = try? jsonEncoder.encode(notes) {
            defaults.set(savedNotes, forKey: "Notes")
        }
    }
}

//MARK: - Add buttons and their actions

extension DetailViewController {
    
    func addButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(goBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(changeTitle))
        let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeNote))
        toolbarItems = [shareItem, spacer, deleteItem]
    }
    
    @objc func changeTitle() {
        let ac = UIAlertController(title: "Enter new note title", message: nil, preferredStyle: .alert)
        ac.addTextField { (textfield) in
            textfield.placeholder = self.note.title
        }
        let okAction = UIAlertAction(title: "Okay", style: .default) { [weak self, weak ac] (_) in
            guard let newTitle = ac?.textFields?[0].text else { return }
            self?.note.title = newTitle
            self?.title = newTitle
            self?.saveNoteChanges()
            self?.view.endEditing(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (_) in
            self?.view.endEditing(true)
        }
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    @objc func shareNote() {
        let ac = UIActivityViewController(activityItems: [note.title + "\n" + note.content], applicationActivities: [])
        ac.popoverPresentationController?.barButtonItem = navigationController?.toolbar.items?[0]
        present(ac, animated: true)
    }
    
    @objc func removeNote() {
        let ac = UIAlertController(title: "Delete Note?", message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = navigationController?.toolbar.items?[1]
        let okAction = UIAlertAction(title: "Okay", style: .destructive) { [weak self] (_) in
            notes.remove(at: (self?.noteIndex)!)
            self?.goBack(remove: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    @objc func goBack(remove : Bool = false) {
        saveNoteChanges(remove: remove)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Adjust Note Content View

extension DetailViewController {
    func addKeyboardNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(_ notification : Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            noteContent.contentInset = .zero
        } else {
            noteContent.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        noteContent.scrollIndicatorInsets = noteContent.contentInset
        noteContent.scrollRangeToVisible(noteContent.selectedRange)
    }
    
    
}
