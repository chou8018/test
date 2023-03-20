//
//  CAProfileCell.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/29.
//

import UIKit

class CAProfileCell: UITableViewCell ,InitializableFromNib {
    static var nibName: String = "CAProfileCell"

    @IBOutlet weak var titleLabel: UILabel!
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
