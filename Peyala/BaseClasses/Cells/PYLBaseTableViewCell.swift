//
//  PYLBaseTableViewCell.swift
//  Peyala
//
//  Created by Chinmay Das on 19/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLBaseTableViewCell: UITableViewCell {

    var datasource: AnyObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func didMoveToSuperview() {
        self.layoutIfNeeded()
    }
    func configureCell(){
      self.layoutSubviews()
    }
}
