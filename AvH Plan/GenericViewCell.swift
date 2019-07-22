//
//  GenericViewCell.swift
//  AvH Plan
//
//  Created by Deniz Duezgoeren on 21.07.19.
//  Copyright © 2019 Deniz Duezgoeren. All rights reserved.
//

import UIKit
import MagazineLayout

class GenericViewCell: MagazineLayoutCollectionViewCell {
    
    private var widthConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomConstraint.priority = .required - 1
        NSLayoutConstraint.activate(
            [
                leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                topAnchor.constraint(equalTo: contentView.topAnchor),
                bottomConstraint
            ]
        )
        
        widthConstraint = widthAnchor.constraint(equalToConstant: bounds.width)
        widthConstraint.priority = .required - 1
        widthConstraint.isActive = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomConstraint.priority = .required - 1
        NSLayoutConstraint.activate(
            [
                leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                topAnchor.constraint(equalTo: contentView.topAnchor),
                bottomConstraint
            ]
        )
        
        widthConstraint = widthAnchor.constraint(equalToConstant: bounds.width)
        widthConstraint.priority = .required - 1
        widthConstraint.isActive = true
    }
    
    override open func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes)
        -> UICollectionViewLayoutAttributes
    {
        guard let attributes = layoutAttributes as? MagazineLayoutCollectionViewLayoutAttributes else {
            assertionFailure("`layoutAttributes` must be an instance of `MagazineLayoutCollectionViewLayoutAttributes`")
            return super.preferredLayoutAttributesFitting(layoutAttributes)
        }
        
        let size: CGSize
        if attributes.shouldVerticallySelfSize {
            widthConstraint.constant = layoutAttributes.size.width
            
            size = super.preferredLayoutAttributesFitting(layoutAttributes).size
        } else {
            // No self-sizing is required; respect whatever size the layout determined.
            size = layoutAttributes.size
        }
        
        layoutAttributes.size = size
        
        return layoutAttributes
    }
    
}
