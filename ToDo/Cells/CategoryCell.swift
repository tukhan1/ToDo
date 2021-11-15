//
//  CategoryCell.swift
//  ToDo
//
//  Created by Egor Tushev on 11.11.2021.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var itemsCount: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getIdentifier() -> String {
        return "CategoryCellId" 
    }
    
}
