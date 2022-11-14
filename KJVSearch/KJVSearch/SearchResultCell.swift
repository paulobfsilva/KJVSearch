//
//  SearchResultCell.swift
//  KJVSearch
//
//  Created by Paulo Silva on 11/11/2022.
//

import UIKit

public final class SearchResultCell: UITableViewCell {
    @IBOutlet private(set) var percentageImage: UIImageView!
    @IBOutlet private(set) var scriptureVerseLabel: UILabel!
    @IBOutlet private(set) var scriptureTextLabel: UILabel!
    @IBOutlet private(set) var scriptureContainer: UIView!

    public override func awakeFromNib() {
        super.awakeFromNib()
        
        scriptureTextLabel.alpha = 0
        scriptureContainer.startShimmering()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        scriptureTextLabel.alpha = 0
        scriptureContainer.startShimmering()
    }
    
    func fadeIn(_ text: String) {
        scriptureTextLabel.text = text
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            animations: {
                self.scriptureTextLabel.alpha = 1
            }, completion: { completed in
                if completed {
                    self.scriptureContainer.stopShimmering()
                }
            })
    }
}

private extension UIView {
    private var shimmerAnimationKey: String {
        return "shimmer"
    }
    
    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.25
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }
    
    func stopShimmering() {
        layer.mask = nil
    }
}
