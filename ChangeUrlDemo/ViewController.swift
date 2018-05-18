//
//  ViewController.swift
//  ChangeUrlDemo
//
//  Created by huangyuchen on 2018/5/18.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.isUserInteractionEnabled = true

        print(MJChangeNetworkEnvironment.shared.getCacheEnvironmentFlag())
        
        MJChangeNetworkEnvironment.shared.appId = "1291221326"
        MJChangeNetworkEnvironment.shared.environments = [("生产环境", "1"),("debug环境", "2"),("测试环境", "3")]
        MJChangeNetworkEnvironment.shared.targetController = self
        MJChangeNetworkEnvironment.shared.setUpChangeNetworkEnvironment()
 
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
