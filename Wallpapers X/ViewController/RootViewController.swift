//
//  RootViewController.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/12/2.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class RootViewController: SlideMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SlideMenuOptions.leftViewWidth = 220
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LeftViewController") as? LeftViewController {
            self.leftViewController = controller
        }

        self.slideMenuController()?.closeLeft()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
