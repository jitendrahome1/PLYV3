//
//  PYLFAQTableViewCell.swift
//  Peyala
//
//  Created by Soumen Das on 12/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLFAQTableViewCell: PYLBaseTableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelSeparator: UILabel!
    
    override var datasource: AnyObject! {
        
        didSet {
            
             if let title = datasource["faq_question"] as? String {
             labelTitle.text = title
             }
             if let description = datasource["faq_answer"] as? String {
             labelDescription.text = description
             }
            
        }
    }
}
