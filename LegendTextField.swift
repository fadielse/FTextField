//
//  LegendTextField.swift
//  FTextField
//
//  Created by fadielse on 03/07/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

/**
 A LegendTextField is a subclass of the TextFieldEffects object, is a control that displays an UITextField with a customizable visual effect around the edges of the control.
 */
@IBDesignable open class LegendTextField: TextFieldEffects {
    /**
     The color of the placeholder text.
     
     This property applies a color to the complete placeholder string. The default value for this property is a black color.
     */
    @IBInspectable dynamic open var placeholderColor: UIColor = .black {
        didSet {
            updatePlaceholder()
        }
    }
    
    @IBInspectable dynamic open var placeholderActiveColor: UIColor = .black
    
    /**
     The color of the border.
     
     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    /**
     The scale of the placeholder font.
     
     This property determines the size of the placeholder label relative to the font size of the text field.
     */
    @IBInspectable dynamic open var placeholderFontScale: CGFloat = 0.65 {
        didSet {
            updatePlaceholder()
        }
    }
    
    /**
     The Padding between text and left side of textfield
    */
    
    @IBInspectable dynamic open var paddingLeft: CGFloat = 16.0
    
    override open var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }
    
    override open var bounds: CGRect {
        didSet {
            updateBorder()
            updatePlaceholder()
        }
    }
    
    private let borderThickness: CGFloat = 1
    private let placeholderInsets = CGPoint(x: 6, y: 6)
    private let textFieldInsets = CGPoint(x: 6, y: 6)
    private let borderLayer = CAShapeLayer()
    private var backgroundLayerColor: UIColor?
    
    // MARK: - TextFieldEffects
    
    override open func drawViewsForRect(_ rect: CGRect) {
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: rect.size.width, height: rect.size.height))
        
        placeholderLabel.frame = frame.insetBy(dx: placeholderInsets.x, dy: placeholderInsets.y)
        placeholderLabel.adjustsFontSizeToFitWidth = true
        placeholderLabel.font = placeholderFontFromFont(font!)
        placeholderLabel.backgroundColor = .white
        
        borderView.isUserInteractionEnabled = false
        
        updateBorder()
        updatePlaceholder()
        
        addSubview(borderView)
        borderView.layer.addSublayer(borderLayer)
        addSubview(placeholderLabel)
    }
    
    override open func animateViewsForTextEntry() {
        if !text!.isEmpty {
            return
        }
        
        borderLayer.strokeEnd = 1
        if let placeholderText = placeholder {
            self.placeholderLabel.text = "  \(placeholderText)  "
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            let translate = CGAffineTransform(translationX: self.placeholderInsets.x, y: -(self.frame.height - (self.placeholderLabel.frame.origin.y + (self.placeholderLabel.frame.height / 3))))
            let scale = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            self.placeholderLabel.transform = translate.concatenating(scale)
        }) { _ in
            self.animationCompletionHandler?(.textEntry)
            self.placeholderLabel.textColor = self.placeholderActiveColor
        }
    }
    
    override open func animateViewsForTextDisplay() {
        if text!.isEmpty {
            updateStyle()
            placeholderLabel.text = placeholder
            
            UIView.animate(withDuration: 0.3, animations: {
                self.placeholderLabel.transform = .identity
            }) { _ in
                self.animationCompletionHandler?(.textDisplay)
                self.placeholderLabel.textColor = self.placeholderColor
            }
        }
    }
    
    // MARK: - Private
    
    private func updateBorder() {
        let rect = rectForBorder(bounds)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight, .topRight, .topLeft], cornerRadii: CGSize(width: 4.0, height: 4.0))
        path.close()
        borderLayer.path = path.cgPath
        borderLayer.lineCap = .square
        borderLayer.lineWidth = borderThickness
        borderLayer.fillColor = nil
        borderLayer.strokeColor = borderColor?.cgColor
        
        updateStyle()
    }
    
    private func updatePlaceholder() {
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.sizeToFit()
        layoutPlaceholderInTextRect()
        
        if isFirstResponder || text!.isNotEmpty {
            animateViewsForTextEntry()
        }
    }
    
    private func placeholderFontFromFont(_ font: UIFont) -> UIFont! {
        let smallerFont = UIFont(name: font.fontName, size: font.pointSize * placeholderFontScale)
        return smallerFont
    }
    
    private func rectForBorder(_ bounds: CGRect) -> CGRect {
        let newRect = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        
        return newRect
    }
    
    private func layoutPlaceholderInTextRect() {
        placeholderLabel.transform = CGAffineTransform.identity
        
        let textRect = self.textRect(forBounds: bounds)
        var originX = textRect.origin.x
        switch textAlignment {
        case .center:
            originX += textRect.size.width/2 - placeholderLabel.bounds.width/2
        case .right:
            originX += textRect.size.width - placeholderLabel.bounds.width
        default:
            break
        }
        
        placeholderLabel.frame = CGRect(x: originX, y: (frame.height / 2) - (placeholderLabel.bounds.height / 2),
                                        width: placeholderLabel.bounds.width, height: placeholderLabel.bounds.height)
    }
    
    private func updateStyle() {
        borderLayer.strokeEnd = 0
    }
    
    // MARK: - Overrides
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = rectForBorder(bounds)
        return newBounds.insetBy(dx: paddingLeft, dy: 0)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = rectForBorder(bounds)
        return newBounds.insetBy(dx: paddingLeft, dy: 0)
    }
}
