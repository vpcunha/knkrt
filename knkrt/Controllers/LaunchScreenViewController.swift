//
//  LaunchScreenViewController.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 07/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import UIKit

// Fazendo fade para a PopMoviesVC
class LaunchScreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) {
            timer in
            self.performSegue(withIdentifier: "segueToApp", sender: self
            )}
    }
}



