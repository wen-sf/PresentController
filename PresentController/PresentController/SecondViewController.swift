//
//  SecondViewController.swift
//  PresentController
//
//  Created by HongXiangWen on 2018/3/26.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func closeBtnClicked() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SecondViewController: PresentControllerType {
    
    var contentSize: CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    var position: PresentControllerPosition {
        return .center
    }
    
}
