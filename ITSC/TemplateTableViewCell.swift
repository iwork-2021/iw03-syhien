//
//  TemplateTableViewCell.swift
//  ITSC
//
//  Created by nju on 2021/11/4.
//

import UIKit

class TemplateTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    var link: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.title.sizeToFit()
        self.detail.sizeToFit()
        if self.frame.size.width > self.title.frame.size.width + self.detail.frame.size.width + 30 {
            return
        }
        if let detail = self.detail {
            detail.sizeToFit()
            let rightMargin: CGFloat = 16
            let detailWidth = rightMargin + detail.frame.size.width
            detail.frame.origin.x = self.frame.size.width - detailWidth
            detail.textAlignment = .left
            if let text = self.title {
                if text.frame.origin.x + text.frame.size.width > self.frame.width - detailWidth {
                    text.frame.size.width = self.frame.width - detailWidth - text.frame.origin.x
                }
            }
        }
    }
}
