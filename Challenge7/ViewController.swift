//
//  ViewController.swift
//  Challenge7
//
//  Created by Rohit Lunavara on 6/17/20.
//  Copyright © 2020 Rohit Lunavara. All rights reserved.
//

import UIKit
import NotificationCenter

class ViewController: UITableViewController {
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadNotes()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.reloadData()
        loadNotes()
        customizeNavbar()
    }
    
    func customizeNavbar() {
        title = "Notes"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 24)]
        navigationController?.isToolbarHidden = true
    }
}

//MARK: - Load and Add notes

extension ViewController {
    @objc func addNote() {
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailVC") as? DetailViewController {
            let newNote = Note(title: "New Note", content: "")
            detailVC.note = newNote
            detailVC.noteIndex = notes.count
            notes.append(newNote)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func loadNotes() {
        let jsonDecoder = JSONDecoder()
        if let savedNotes = defaults.object(forKey: "Notes") as? Data {
            notes = (try? jsonDecoder.decode([Note].self, from: savedNotes)) ?? [Note]()
        }
    }
}

//MARK: - TableView Delegate methods

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        cell.textLabel?.text = notes[indexPath.row].title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(identifier: "DetailVC") as? DetailViewController {
            detailVC.note = notes[indexPath.row]
            detailVC.noteIndex = indexPath.row
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
