//
//  KnkrtCollectionViewCell.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 07/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import UIKit

class KnkrtCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var ivBadge: UIImageView!
    
    func prepareCell(favorite: [String], movie: Movie) {
        DispatchQueue.main.async {
            if let path = movie.poster_path {
                let urlPath = URL(string: "https://image.tmdb.org/t/p/w185\(path)")
                if let imageData = NSData(contentsOf: urlPath!) {
                    let poster = UIImage(data: imageData as Data)
                    self.ivPoster.image = poster
                }
            } else {
                self.ivPoster.image = nil
            }
            self.lbTitle.text = movie.title
            // Definindo qual selo de favorito entrará
            if favorite.contains(movie.title) {
                let bundlePath = Bundle.main.path(forResource: "full_heart", ofType: "png")
                let urlPath = URL(fileURLWithPath: bundlePath!)
                let imageData = NSData(contentsOf: urlPath)
                let poster = UIImage(data: imageData! as Data)
                self.ivBadge.image = poster
            } else {
                let bundlePath = Bundle.main.path(forResource: "empty_heart", ofType: "png")
                let urlPath = URL(fileURLWithPath: bundlePath!)
                let imageData = NSData(contentsOf: urlPath)
                let poster = UIImage(data: imageData! as Data)
                self.ivBadge.image = poster
            }
        }
    }
}






