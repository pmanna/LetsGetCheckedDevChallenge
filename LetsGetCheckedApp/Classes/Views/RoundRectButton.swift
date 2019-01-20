//
//  RoundRectButton.swift
//
//  Created by Paolo on 10/09/2016.
//

import UIKit
import QuartzCore

@IBDesignable

class RoundRectButton: UIButton {
	@IBInspectable var borderColor: UIColor	= UIColor.lightGray
	@IBInspectable var borderWidth: CGFloat	= 1.0
	@IBInspectable var borderRadius: CGFloat = 0.0
	
	var realBackgroundColor: UIColor?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		commonSetup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonSetup()
	}
	
	func commonSetup() {
		clipsToBounds		= false
		
		layer.shadowColor	= titleShadowColor(for: .normal)?.cgColor
		layer.shadowOffset	= CGSize(width:3.0, height: 3.0)
		layer.shadowOpacity	= 0.8
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		if realBackgroundColor  == nil {
			realBackgroundColor	= backgroundColor
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
        if realBackgroundColor  == nil {
            realBackgroundColor	= backgroundColor
        }
        
		layer.cornerRadius	= borderRadius >= 1.0 && borderRadius < frame.height / 2.0 ? borderRadius : frame.height / 2.0
		layer.borderColor	= borderColor.cgColor
		layer.borderWidth	= borderWidth
	}
	
	override var isHighlighted: Bool {
		didSet {
			if isHighlighted || isSelected {
				self.backgroundColor	= self.titleColor(for: .normal)
			} else {
				self.backgroundColor	= self.realBackgroundColor
			}
		}
	}
	
	override var isSelected: Bool {
		didSet {
			if isSelected || isHighlighted {
				self.backgroundColor	= self.titleColor(for: .normal)
			} else {
				self.backgroundColor	= self.realBackgroundColor
			}
		}
	}
}
