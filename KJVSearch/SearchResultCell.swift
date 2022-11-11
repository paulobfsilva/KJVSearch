//
//  SearchResultCell.swift
//  KJVSearch
//
//  Created by Paulo Silva on 11/11/2022.
//

import UIKit

final class SearchResultCell: UITableViewCell {
    @IBOutlet private(set) var percentageImage: UIImageView!
    @IBOutlet private(set) var scriptureVerseLabel: UILabel!
    @IBOutlet private(set) var scriptureTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        scriptureTextLabel.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        scriptureTextLabel.alpha = 0
    }
    
    func fadeIn(_ text: String) {
        scriptureTextLabel.text = text
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            animations: {
                self.scriptureTextLabel.alpha = 1
            })
        
    }
}
