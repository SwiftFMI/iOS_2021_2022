//
//  HighlitedButton.swift
//  SwiftFMI-Auto
//
//  Created by Spas Bilyarski on 3.11.17.
//  Copyright © 2017 spasbilyarski. All rights reserved.
//

import UIKit

// IBDesignable ни позволяват да виждаме промените на IBInspectable променливите в Interface Builder
@IBDesignable

class HighlightedButton: UIButton {

    // IBInspectable ни позволяват манипулацията на променливи през Interface Builder
    
    @IBInspectable var highlitedColor: UIColor? = nil {
        didSet {
            adjustBackgroundColor()
        }
    }
    
    @IBInspectable var selectedColor: UIColor? = nil {
        didSet {
            adjustBackgroundColor()
        }
    }
    
    @IBInspectable var normalColor: UIColor? = nil {
        didSet {
            adjustBackgroundColor()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var icon: UIImage? = nil {
        didSet {
            setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    // Override-ваме highlited и selected статусите на бутона
    
    override open var isHighlighted: Bool {
        didSet {
            adjustBackgroundColor()
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            adjustBackgroundColor()
        }
    }
    
    private func adjustBackgroundColor() {
        if (isHighlighted) {
            backgroundColor = highlitedColor
        }
        else if (isSelected) {
            backgroundColor = selectedColor
        }
        else {
            backgroundColor = normalColor
        }
    }

}
