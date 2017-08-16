//
//  PYLTextField.swift
//  Peyala
//
//  Created by Chinmay Das on 20/07/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 8, y: bounds.origin.y, width: bounds.size.width-8, height: bounds.size.height);
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
}
