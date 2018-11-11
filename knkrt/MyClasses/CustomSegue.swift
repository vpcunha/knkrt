//
//  CustomSegue.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 07/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import Foundation
import UIKit

// Segue para fazer fade da launchScreen para a PopMoviesVC
class CustomSegue: UIStoryboardSegue {
    override func perform() {
        let sourceVC = source as UIViewController
        let destinationVC = destination as UIViewController
        let window = UIApplication.shared.keyWindow!
        destination.view.alpha = 0.0
        window.insertSubview(destination.view, belowSubview: source.view)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            sourceVC.view.alpha = 0.0
            destinationVC.view.alpha = 1.0
        }, completion: { (finished) -> Void in
            sourceVC.present(destinationVC, animated: false, completion: nil)
        })
    }
}





