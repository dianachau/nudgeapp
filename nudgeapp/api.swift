//
//  api.swift
//  nudgeapp
//
//  Created by Diana on 8/31/16.
//  Copyright © 2016 diana. All rights reserved.
//

import Foundation

let API_URL = "http://dq-todo.herokuapp.com/v1/nudge"

class Api {

    let DATE_FORMATTER = NSDateFormatter()

    init() {
        self.DATE_FORMATTER.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    }

    /**
     * @return a list of the most recent nudges stored on the server
     */
    func getNudges() -> [Nudge] {
        let myURL = NSURL(string: API_URL)
        let request = NSMutableURLRequest(URL: myURL!)
        request.HTTPMethod = "GET"

        var returnNudges: [Nudge] = []
        let semaphore = dispatch_semaphore_create(0)

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            do {
                let nudges = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray

                var index = 0
                while index < nudges.count {
                    let nudge = nudges.objectAtIndex(index)

                    returnNudges.append(Nudge(
                        entry: nudge["imageUrl"] as? String ?? "",
                        location: nudge["location"] as? String ?? "",
                        date: self.DATE_FORMATTER.dateFromString(nudge["date"] as? String ?? "")!,
                        image:  NSData(contentsOfURL: NSURL(string: nudge["imageUrl"] as! String)!)!
                    ))

                    index += 1
                }

            }
            catch let error as NSError {
                print(error)
            }

            dispatch_semaphore_signal(semaphore)
        }

        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        return returnNudges
    }
    
    /**
     * Save a nudge to the server.
     */
    func saveNudge (entry: String, date: NSDate, location: String?, image: NSData) -> Void {
        var sharedAccessURL = ""

        let imgName = NSUUID().UUIDString + ".png"

        // get url to upload to
        let myURL = NSURL(string: API_URL + "/sharedAccessUrl?imgName=" + imgName)
        print(myURL)
        let sharedAccessURLRequest = NSMutableURLRequest(URL: myURL!)
        sharedAccessURLRequest.HTTPMethod = "GET"
        let sem1 = dispatch_semaphore_create(0)
        NSURLSession.sharedSession().dataTaskWithRequest(sharedAccessURLRequest) {
            data, resposne, error in
            do {
                let url: AnyObject  = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                sharedAccessURL = url["url"] as? String ?? ""
            } catch let error as NSError {
                print(error)
            }

            dispatch_semaphore_signal(sem1)
        }.resume()
        dispatch_semaphore_wait(sem1, DISPATCH_TIME_FOREVER)

        print(sharedAccessURL)

        // get url to upload to
        let putUrl = NSURL(string: sharedAccessURL)
        let putImageRequest = NSMutableURLRequest(URL: putUrl!)
        putImageRequest.HTTPMethod = "PUT"
//        putImageRequest.addValue("image/png", forHTTPHeaderField: "Content-Type")
        let sem2 = dispatch_semaphore_create(0)

        NSURLSession.sharedSession().uploadTaskWithRequest(putImageRequest, fromData: image) {
            data, resposne, error in
            print(data)
            print(resposne)
            print(error)
            dispatch_semaphore_signal(sem2)
        }.resume()
        dispatch_semaphore_wait(sem2, DISPATCH_TIME_FOREVER)

        // save this to db
        let saveNudgeUrl = NSURL(string: API_URL + "/add")
        let saveNudgeRequest = NSMutableURLRequest(URL: saveNudgeUrl!)
        saveNudgeRequest.HTTPMethod = "POST"
        saveNudgeRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        saveNudgeRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        // step 1 set title
        do {
            let params = [
                "location": "\(location)",
                "imageUrl": "https://dq-nudge.s3-us-west-1.amazonaws.com/" + imgName,
                "date": DATE_FORMATTER.stringFromDate(date),
                "entry": entry
            ]
            saveNudgeRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let error as NSError {
            print(error)
        }
        let sem3 = dispatch_semaphore_create(0)
        NSURLSession.sharedSession().dataTaskWithRequest(saveNudgeRequest) {
            data, resposne, error in

            print("done")

            dispatch_semaphore_signal(sem3)
            }.resume()
        dispatch_semaphore_wait(sem3, DISPATCH_TIME_FOREVER)
    }
    
}