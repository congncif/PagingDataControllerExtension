//
//  ViewController.swift
//  PagingDataControllerExtension
//
//  Created by NGUYEN CHI CONG on 09/29/2016.
//  Copyright (c) 2016 NGUYEN CHI CONG. All rights reserved.
//

import UIKit
import PagingDataController
import PagingDataControllerExtension
import SVPullToRefresh

struct Provider: PagingProviderProtocol {
    func loadData(parameters: String?, page: Int, completion: (([String], Error?) -> ())?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            completion?([], nil)
        }
    }
}

class ViewController: UIViewController, PagingControllerProtocol {
    var provider = Provider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.red
        
        setupForPaging(nativeRefreshControl: true, firstLoadstyle: .autoTrigger)
    }
    
    @IBAction func buttonClicked(_ sender: AnyObject) {
        print("Clicked")
    }
    
}

