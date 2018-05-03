//
//  TableViewCell.swift
//  ARPViewer
//
//  Created by Kevin Scardina on 3/29/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var macLabel: UILabel!
    @IBOutlet weak var addrLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

