//
//  api.swift
//  nudgeapp
//
//  Created by Diana on 8/31/16.
//  Copyright © 2016 diana. All rights reserved.
//

import Foundation

class Api {
    
    /**
     * @return a list of the most recent nudges stored on the server
     */
    func getNudges() -> [Entity] {
        return []
    }
    
    /**
     * Save a nudge to the server.
     */
    func saveNudge (entry: String, date: NSDate, location: String?, image: NSData) -> Void {
    
    }
    
}