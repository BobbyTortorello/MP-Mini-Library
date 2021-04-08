//
//  ViewController.swift
//  MP Mini Library
//
//  Created by Bobby Tortorello on 12/24/20.
//

import UIKit

@available(iOS 13.0, *)
class StartViewController: UIViewController {

     override func viewDidLoad() {
          super.viewDidLoad()
          // Do any additional setup after loading the view.
     }

     @IBAction func viewLibrariesButton(_ sender: UIButton) {
          let vc = storyboard?.instantiateViewController(identifier: "librariesVC")
          navigationController?.pushViewController(vc!, animated: false)
     }
     
}
