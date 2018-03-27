//
//  FirstViewController.swift
//  PresentController
//
//  Created by HongXiangWen on 2018/3/26.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeBtnClicked() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension FirstViewController: PresentControllerType {
    
    
    var contentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 200)
    }
    
    var position: PresentControllerPosition {
        return .top
    }
    
    var animateTime: CGFloat {
        return 0.5
    }
    
}
