//
//  AllChatCell.swift
//  GoFeds
//
//  Created by Rohit Prajapati on 31/08/20.
//  Copyright © 2020 Novos. All rights reserved.
//

import UIKit

class AllChatCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
