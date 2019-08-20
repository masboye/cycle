//
//  CollectionViewCell.swift
//  cycle
//
//  Created by boy setiawan on 19/08/19.
//  Copyright © 2019 boy setiawan. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell{
    
    @IBOutlet var viewCell: UIView!
    @IBOutlet var label: UILabel!
    
    func displayContent(title:String){
        self.label.text = title
    }
}
