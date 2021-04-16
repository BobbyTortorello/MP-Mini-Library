//
//  ViewController.swift
//  MP Mini Library
//
//  Created by Bobby Tortorello on 12/24/20.
//

import UIKit

class StartViewController: UIViewController {

     override func viewDidLoad() {
          super.viewDidLoad()          
     }

     @IBAction func viewLibrariesButton(_ sender: UIButton) {
          let nvc = storyboard?.instantiateViewController(identifier: "librariesVC")
          navigationController?.pushViewController(nvc!, animated: false)
     }
}
