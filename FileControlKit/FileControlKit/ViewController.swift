//
//  ViewController.swift
//  FileControlKit
//
//  Created by zhoucz on 2021/06/08.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.present(FileControlKit(), animated: true, completion: nil)
    }
    
}

