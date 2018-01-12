//
//  PhotoCell.swift
//  Tumblr
//
//  Created by Joey Dafforn on 1/11/18.
//  Copyright © 2018 Joey Dafforn. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {

    @IBOutlet weak var pictureView: UIImageView!
    var ogFrame: CGRect!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        }

}
