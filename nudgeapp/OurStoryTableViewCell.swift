//
//  OurStoryTableViewCell.swift
//  nudgeapp
//
//  Created by Diana on 8/28/16.
//  Copyright © 2016 diana. All rights reserved.
//

import UIKit

class OurStoryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        storyImageView.layer.cornerRadius = 8
        storyImageView.layer.masksToBounds = true
    }

    // MARK: - Outlets
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var storyDateLabel: UILabel!
    @IBOutlet weak var storyEntryLabel: UILabel!
    @IBOutlet weak var storyLocationLabel: UILabel!


}