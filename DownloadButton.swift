//
//  DownloadButton.swift
//  test
//
//  Created by apple on 2018/6/1.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class DownloadButton: UIButton {
    //next step interface builder
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.red.cgColor
        
        layer.cornerRadius = 8.0
        setTitleColor(UIColor.blue, for: .normal)
        setTitleColor(UIColor.lightGray, for: .highlighted)

        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    @objc func onPress() {
        print("Pressed")
    }
}
