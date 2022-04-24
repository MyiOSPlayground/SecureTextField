//
//  ViewController.swift
//  SecureTextField
//
//  Created by hanwe on 2022/04/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var secureTextField: SecureTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func getValue(_ sender: Any) {
        print("value: \(String(describing: self.secureTextField.value()))")
    }
    
}

