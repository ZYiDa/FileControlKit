//
//  ViewController.swift
//  FileControlKit
//
//  Created by zhoucz on 2021/06/08.
//

import UIKit

class ViewController: UIViewController,FileControlKitDeledate {
    func fileControlKitDidSelectedFile(with file: FileItemModel) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fileControlKit = FileControlKit()
        fileControlKit.fileControlKitDidSelected { file in
            
        }
        fileControlKit.fileDelegate = self
        self.present(FileControlKit(), animated: true, completion: nil)
    }
    
}

