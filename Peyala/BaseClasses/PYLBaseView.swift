//
//  PYLBaseView.swift
//  Peyala
//
//  Created by Pradip Paul on 15/09/16.
//  Copyright © 2016 Indusnet. All rights reserved.
//

import UIKit

class PYLBaseView: UIView {

    @IBInspectable var enableFooterLine : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var AllSideBorder : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var RightBorder : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var BorderWidth : CGFloat = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var LeftBorder : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var BottomBorder : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }

    
    @IBInspectable var RoundedTopOnly : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var RoundedBottomOnly : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.lightGray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if enableFooterLine {
                self.layoutIfNeeded()
                let footer:UILabel = UILabel()
                footer.frame = CGRect(x: 0, y: self.frame.height-5, width: self.frame.width, height: 5)
                footer.backgroundColor = DEFAULT_COLOR
                self.addSubview(footer)
                self.bringSubview(toFront: footer)
        }
        self.layer.borderColor = borderColor.cgColor;
        if RoundedTopOnly {
            let maskPath = UIBezierPath(roundedRect: self.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 5.0, height: 5.0))
            maskPath.lineWidth = self.layer.borderWidth + 0.5
            borderColor.setStroke()
            self.backgroundColor?.setFill()
            maskPath.fill()
            maskPath.stroke()
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            self.layer.mask = shape
        }
        if RoundedBottomOnly {
            
            let rect = self.frame;
            
            
            
            let maskPath = UIBezierPath(roundedRect: self.bounds,
                                        byRoundingCorners: [.bottomLeft, .bottomRight],
                                        cornerRadii: CGSize(width: 5.0, height: 5.0))
            maskPath.lineWidth = self.layer.borderWidth + 0.5
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            //shape.strokeColor = borderColor.CGColor
            self.layer.mask = shape
            
            
            
            let linePath  =  UIBezierPath()
            
            linePath.move(to: CGPoint(x: 0, y: 0))
            linePath.addLine(to: CGPoint(x: 0, y: rect.size.height))
            linePath.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
            linePath.addLine(to: CGPoint(x: rect.size.width, y: 0))
            
            // create a layer that uses your defined path
            let Line = CAShapeLayer()
            Line.frame = rect
            Line.path = linePath.cgPath
            Line.lineWidth = BorderWidth + 0.5;
            self.layer.mask = Line
            Line.strokeColor = borderColor.cgColor
            Line.fillColor   = UIColor.clear.cgColor;
            Line.fillColor = nil;
            self.layer.addSublayer(Line)
            
            self.layer.masksToBounds = true
            
            
        }
        if AllSideBorder {
            self.layer.borderWidth = 0.5
            self.layer.masksToBounds = true
        }
      
        
        
    }
   

}
