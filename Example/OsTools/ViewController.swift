//
//  ViewController.swift
//  OsTools
//
//  Created by osfunapps on 08/06/2020.
//  Copyright (c) 2020 osfunapps. All rights reserved.
//

import UIKit
import OsTools

class ViewController: UIViewController {

    @IBOutlet weak var exampleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exampleView.fadeOut(withDuration: 5){
            self.exampleView.fadeIn(withDuration: 10) {
                print("done!")
            }
        }
    }
    
}

