//
//  ViewController.swift
//  SwiftFMI-Auto
//
//  Created by Spas Bilyarski on 3.11.17.
//  Copyright © 2017 spasbilyarski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var controlCenterView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Добавяме заоблени ръбове
        controlCenterView.layer.cornerRadius = 20.0
    }

    @IBAction func iconAction(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
}

