//
//  secondCustomCell.swift
//  jenniferbuur_pset5
//
//  Created by Jennifer Buur on 16-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit

class secondCustomCell: UITableViewCell {

    @IBOutlet var doneSwitch: UISwitch!
    @IBOutlet var todoName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
