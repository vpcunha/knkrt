//
//  DetailViewController.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 08/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var ivBackdrop: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbYear: UILabel!
    @IBOutlet weak var lbGenre: UILabel!
    @IBOutlet weak var tvPlot: UITextView!
    @IBOutlet weak var btFavorite: UIButton!
    
    
    // MARK: - Properties
    
    // Variável pra receber dados do filme selecionado
    var selectedMovie: Movie!
    // Variável pra receber os gêneros do filme convertidos
    var genreString = ""
    // Variável pra receber lista de favoritos tirada do Core Data
    var favoriteMovies: [String] = []
    // Variável exigida pelo Core Data
    var favMovieManagedObjectArray:[NSManagedObject] = []
    // Variável pra permitir carregamento de selo de filme favorito
    var isFavorite: Bool!
    
    
    // MARK: - Super Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard selectedMovie != nil else {
            return
        }
        // Baixando foto dos filmes
        DispatchQueue.main.async {
            if let path = self.selectedMovie.backdrop_path {
                let urlPath = URL(string: "https://image.tmdb.org/t/p/w300\(path)")
                if let imageData = NSData(contentsOf: urlPath!) {
                    let poster = UIImage(data: imageData as Data)
                    self.ivBackdrop.image = poster
                }
            } else {
                self.ivBackdrop.image = nil
            }
        }
        // Baixando gêneros dos filmes e formatando string
        REST.getGenre(array: selectedMovie.genre_ids) { (genres) in
            DispatchQueue.main.async {
                for i in 0..<genres.count {
                    self.genreString.append(genres[i] + ", ")
                }
                if !self.genreString.isEmpty {
                    self.genreString.removeLast()
                }
                if !self.genreString.isEmpty {
                    self.genreString.removeLast()
                }
                self.lbGenre.text = self.genreString
            }
        }
        lbTitle.text = selectedMovie.title
        let date = selectedMovie.release_date
        let characters = [Character](date)
        let year = "\(characters[0])" + "\(characters[1])" + "\(characters[2])" + "\(characters[3])"
        lbYear.text = year
        tvPlot.text = selectedMovie.overview
        // Recuperando filmes do Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavMovie")
        do {
            favMovieManagedObjectArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        favoriteMovies = []
        for i in 0..<favMovieManagedObjectArray.count {
            favoriteMovies.append(favMovieManagedObjectArray[i].value(forKeyPath: "movieName") as! String)
        }
        if !favoriteMovies.contains(selectedMovie.title) {
            let image = UIImage(named: "empty_heart")
            btFavorite.setImage(image, for: .normal)
            isFavorite = false
        } else {
            let image = UIImage(named: "full_heart")
            btFavorite.setImage(image, for: .normal)
            isFavorite = true
        }
    }
    

    // Isso faz textView começar do topo (caso volume de texto exceda tamanho da janela)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tvPlot.setContentOffset(CGPoint.zero, animated: false)
    }
    

    
    // MARK: - IBActions
    
    @IBAction func favoriteOrUnfavorite(_ sender: UIButton) {
        if isFavorite == true {
            isFavorite = false
            // Recuperando filmes do Core Data
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavMovie")
            do {
                favMovieManagedObjectArray = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            favoriteMovies = []
            for i in 0..<favMovieManagedObjectArray.count {
            favoriteMovies.append(favMovieManagedObjectArray[i].value(forKeyPath: "movieName") as! String)
            }
            for i in 0..<favoriteMovies.count {
                if favoriteMovies[i] == selectedMovie.title {
                    managedContext.delete(favMovieManagedObjectArray[i])
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                }
            }
            let image = UIImage(named: "empty_heart")
            btFavorite.setImage(image, for: .normal)
        } else {
            isFavorite = true
            // Salvando filme no Core Data
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "FavMovie", in: managedContext)
            let item = NSManagedObject(entity: entity!, insertInto: managedContext)
            item.setValue(lbTitle.text!, forKey: "movieName")
            item.setValue(lbYear.text!, forKey: "movieYear")
            item.setValue(tvPlot.text!, forKey: "moviePlot")
            item.setValue(selectedMovie.poster_path!, forKey: "moviePath")
            item.setValue(genreString, forKey: "movieGenres")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            let image = UIImage(named: "full_heart")
            btFavorite.setImage(image, for: .normal)
        }
    }
}









