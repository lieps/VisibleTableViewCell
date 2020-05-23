//
//  VisibleTableViewCell.swift
//  visibleTableViewCellExam
//
//  Created by lieps Yie on 2020/05/24.
//  Copyright © 2020 lieps. All rights reserved.
//

import UIKit

class VisibleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblText: UILabel!
    
    override func prepareForReuse() {
        self.lblText.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ title: String) {
        self.lblText.text = title
    }
}
