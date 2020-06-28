//
//  Note.swift
//  Challenge7
//
//  Created by Rohit Lunavara on 6/17/20.
//  Copyright © 2020 Rohit Lunavara. All rights reserved.
//

import Foundation

class Note : Codable {
    var title : String
    var content : String
    init(title : String, content : String) {
        self.title = title
        self.content = content
    }
}

var notes = [Note]()
