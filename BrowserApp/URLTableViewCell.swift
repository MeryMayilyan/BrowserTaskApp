//
//  URLTableViewCell.swift
//  BrowserApp
//
//  Created by Shahen on 3/8/19.
//  Copyright © 2019 Shahen. All rights reserved.
//

import UIKit

class URLTableViewCell: UITableViewCell {

    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var urlNameLabel: UILabel!
    @IBOutlet weak var isReachableView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiUpdates()
    }
    
    func uiUpdates() {
        isReachableView.layer.cornerRadius = isReachableView.frame.height / 2
        isReachableView.layer.borderColor = UIColor.white.cgColor
        isReachableView.layer.borderWidth = 2.0
    }

}
