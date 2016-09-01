//
//  Nudge.swift
//  nudgeapp
//
//  Created by Qiming Fang on 8/31/16.
//  Copyright © 2016 diana. All rights reserved.
//

import Foundation

public class Nudge {
    public let date: NSDate?
    public let image: NSData?
    public let location: String?
    public let entry: String?

    init(entry:String, location:String, date:NSDate, image:NSData) {
        self.date = date
        self.image = image
        self.entry = entry
        self.location = location
    }
}