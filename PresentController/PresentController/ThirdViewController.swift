//
//  ThirdViewController.swift
//  PresentController
//
//  Created by HongXiangWen on 2018/3/26.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeBtnClicked() {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: -  只需遵守PresentControllerType协议，设置contentSize就行了
extension ThirdViewController: PresentControllerType {
    
    var contentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 300)
    }
    
}
