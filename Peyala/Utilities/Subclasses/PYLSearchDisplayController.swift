//
//  PYLSearchDisplayController.swift
//  Peyala
//
//  Created by Pradip Paul on 17/11/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLSearchDisplayController: UISearchDisplayController {

    override func setActive(_ visible: Bool, animated: Bool) {
        super.setActive(visible, animated: animated)
        self.searchContentsController.navigationController?.setNavigationBarHidden(false, animated: false)

    }
}
