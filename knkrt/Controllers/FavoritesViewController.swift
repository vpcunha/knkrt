//
//  FavoritesViewController.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 07/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btRemove: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    
    // Variáveis pra fazer busca
    var searchString:String!
    // Variáveis pra receber filtros selecionados
    var detailYear = ""
    var detailGenre = ""
    // Variável pra disparar busca com filtros
    var applyTouched = false
    // Variáveis pra armazenar dados dos filmes
    var titles: [String] = []
    var years: [String] = []
    var plots: [String] = []
    var paths: [String] = []
    var genres: [String] = []
    // Variável exigida pelo Core Data
    var favMovieManagedObjectArray:[NSManagedObject] = []
    // Cores
    let mustardColor = UIColor(red: 247/255, green: 206/255, blue: 91/255, alpha: 1.0)
    let darkMustardColor = UIColor(red: 217/255, green: 151/255, blue: 30/255, alpha: 1.0)
    
    
    // MARK: - Super Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        // Botão pro menu do canto superior direito
        let searchImage = UIImage(named: "FilterIcon")
        let searchItem = UIBarButtonItem(image: searchImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(FavoritesViewController.goTo))
        navigationItem.rightBarButtonItem = searchItem
        // Configurando tableView
        tableView.dataSource = self
        tableView.delegate = self
        // Elimina células vazias após fim do conteúdo
        tableView.tableFooterView = UIView()
        // Cor do botão e textos da barra superior
        self.navigationController?.navigationBar.tintColor = .black
        // cor de fundo da barra
        self.navigationController?.navigationBar.barTintColor = mustardColor
        searchBar.delegate = self
        // Cor do box/contorno da searchBar
        searchBar.barTintColor = mustardColor
        //Pra tirar a linha entre searchBar e navigationBar
        searchBar.isTranslucent = false
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // Colocando a cor do fundo da searchBar
        for subView in searchBar.subviews {
            for subView1 in subView.subviews {
                if subView1.isKind(of: UITextField.self) {
                    // Cor do fundo da searchBar
                    subView1.backgroundColor = darkMustardColor
                }
            }
        }
        // Observers pra receber filtros definidos na SubFilterVC
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "chosenYear"), object: nil, queue: nil) { (notification) in
            if let notification = notification.object as? String {
                self.detailYear = notification
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "chosenGenre"), object: nil, queue: nil) { (notification) in
            if let notification = notification.object as? String {
                self.detailGenre = notification
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "apply"), object: nil, queue: nil) { (notification) in
            if let notification = notification.object as? Bool {
                self.applyTouched = notification
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Carregando favoritos
        if applyTouched == false {
            // Se não há filtro, botão não aparece
            btRemove.setTitle("", for: .normal)
            btRemove.backgroundColor = mustardColor
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
            titles = []
            years = []
            plots = []
            paths = []
            genres = []
            for i in 0..<favMovieManagedObjectArray.count {
                titles.append(favMovieManagedObjectArray[i].value(forKeyPath: "movieName") as! String)
                years.append(favMovieManagedObjectArray[i].value(forKeyPath: "movieYear") as! String)
                plots.append(favMovieManagedObjectArray[i].value(forKeyPath: "moviePlot") as! String)
                paths.append(favMovieManagedObjectArray[i].value(forKeyPath: "moviePath") as! String)
                genres.append(favMovieManagedObjectArray[i].value(forKeyPath: "movieGenres") as! String)
            }
            tableView.reloadData()
        } else {
            // Carregando resultado da busca com filtros
            // Fazendo o botão aparecer
            btRemove.setTitle("Remove Filter", for: .normal)
            btRemove.backgroundColor = .black
            var movie: [String] = []
            var filteredMovies: [[String]] = []
            if self.detailYear != "" && self.detailGenre == "" {
                for i in 0..<self.years.count {
                    if self.years[i] == self.detailYear {
                        movie.append(self.titles[i])
                        movie.append(self.years[i])
                        movie.append(self.plots[i])
                        movie.append(self.paths[i])
                        movie.append(self.genres[i])
                        filteredMovies.append(movie)
                        movie = []
                    }
                }
                self.titles = []
                self.years = []
                self.plots = []
                self.paths = []
                self.genres = []
                for i in 0..<filteredMovies.count {
                    self.titles.append(filteredMovies[i][0])
                    self.years.append(filteredMovies[i][1])
                    self.plots.append(filteredMovies[i][2])
                    self.paths.append(filteredMovies[i][3])
                    self.genres.append(filteredMovies[i][4])
                }
            } else if self.detailYear == "" && self.detailGenre != "" {
                for i in 0..<self.genres.count {
                    if self.genres[i].contains(self.detailGenre) {
                        movie.append(self.titles[i])
                        movie.append(self.years[i])
                        movie.append(self.plots[i])
                        movie.append(self.paths[i])
                        movie.append(self.genres[i])
                        filteredMovies.append(movie)
                        movie = []
                    }
                }
                self.titles = []
                self.years = []
                self.plots = []
                self.paths = []
                self.genres = []
                for i in 0..<filteredMovies.count {
                    self.titles.append(filteredMovies[i][0])
                    self.years.append(filteredMovies[i][1])
                    self.plots.append(filteredMovies[i][2])
                    self.paths.append(filteredMovies[i][3])
                    self.genres.append(filteredMovies[i][4])
                }
            } else if self.detailYear != "" && self.detailGenre != "" {
                for i in 0..<self.years.count {
                    if self.years[i] == self.detailYear {
                        movie.append(self.titles[i])
                        movie.append(self.years[i])
                        movie.append(self.plots[i])
                        movie.append(self.paths[i])
                        movie.append(self.genres[i])
                        filteredMovies.append(movie)
                        movie = []
                    }
                }
                for i in 0..<self.genres.count {
                    if self.genres[i].contains(self.detailGenre) {
                        movie.append(self.titles[i])
                        movie.append(self.years[i])
                        movie.append(self.plots[i])
                        movie.append(self.paths[i])
                        movie.append(self.genres[i])
                        filteredMovies.append(movie)
                        movie = []
                    }
                }
                // Tirando duplicatas do array (o mesmo filme pode aparecer duas vezes por causa do ano e do gênero)
                filteredMovies = filteredMovies.uniqued()
                self.titles = []
                self.years = []
                self.plots = []
                self.paths = []
                self.genres = []
                for i in 0..<filteredMovies.count {
                    self.titles.append(filteredMovies[i][0])
                    self.years.append(filteredMovies[i][1])
                    self.plots.append(filteredMovies[i][2])
                    self.paths.append(filteredMovies[i][3])
                    self.genres.append(filteredMovies[i][4])
                }
                // Tem que eliminar filmes com outros anos que foram incluídos pelo gênero
                var temp1: [String] = []
                var temp2: [String] = []
                var temp3: [String] = []
                var temp4: [String] = []
                var temp5: [String] = []
                for i in 0..<self.years.count {
                    if self.years[i] == self.detailYear {
                        temp1.append(self.titles[i])
                        temp2.append(self.years[i])
                        temp3.append(self.plots[i])
                        temp4.append(self.paths[i])
                        temp5.append(self.genres[i])
                    }
                }
                self.titles = temp1
                self.years = temp2
                self.plots = temp3
                self.paths = temp4
                self.genres = temp5
                // E agora tiram-se os filmes do ano com outro gênero
                temp1 = []
                temp2 = []
                temp3 = []
                temp4 = []
                temp5 = []
                for i in 0..<self.genres.count {
                    if self.genres[i].contains(self.detailGenre) {
                        temp1.append(self.titles[i])
                        temp2.append(self.years[i])
                        temp3.append(self.plots[i])
                        temp4.append(self.paths[i])
                        temp5.append(self.genres[i])
                    }
                }
                self.titles = temp1
                self.years = temp2
                self.plots = temp3
                self.paths = temp4
                self.genres = temp5
                // Alerta de busca vazia
                if self.titles.isEmpty {
                    let alertController = UIAlertController(title: nil, message: "Sua busca não apresentou resultados.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromFavoritesToFilter" {
            let vc = segue.destination as! FilterViewController
            vc.years = years
            vc.genres = genres
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    
    
    // MARK: - Methods
    
    // Ações do botão de filtro na barra de navegação
    @objc func goTo() {
        if !titles.isEmpty {
            performSegue(withIdentifier: "fromFavoritesToFilter", sender: nil)
        } else {
            // Alerta para impedir entrada na FilterVC sem que haja filmes favoritos
            let alertController = UIAlertController(title: nil, message: "É preciso primeiro adicionar filmes à lista de favoritos.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }

    }

    
    // MARK: - IBActions
    
    @IBAction func removeFilter(_ sender: UIButton) {
        applyTouched = false
        detailYear = ""
        detailGenre = ""
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
            titles = []
            years = []
            plots = []
            paths = []
            genres = []
            for i in 0..<favMovieManagedObjectArray.count {
                titles.append(favMovieManagedObjectArray[i].value(forKeyPath: "movieName") as! String)
                years.append(favMovieManagedObjectArray[i].value(forKeyPath: "movieYear") as! String)
                plots.append(favMovieManagedObjectArray[i].value(forKeyPath: "moviePlot") as! String)
                paths.append(favMovieManagedObjectArray[i].value(forKeyPath: "moviePath") as! String)
                genres.append(favMovieManagedObjectArray[i].value(forKeyPath: "movieGenres") as! String)
            }
            tableView.reloadData()
        btRemove.setTitle("", for: .normal)
        btRemove.backgroundColor = mustardColor
    }
    
}





// MARK: - UISearchBarDelegate Methods

extension FavoritesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Busca com string inserida pelo usuário
        var temp1: [String] = []
        var temp2: [String] = []
        var temp3: [String] = []
        var temp4: [String] = []
        var temp5: [String] = []
        for i in 0..<titles.count {
            if titles[i].contains(searchString) {
                temp1.append(titles[i])
                temp2.append(years[i])
                temp3.append(plots[i])
                temp4.append(paths[i])
                temp5.append(genres[i])
            }
        }
        titles = temp1
        years = temp2
        plots = temp3
        paths = temp4
        genres = temp5
        // Alerta de busca vazia
        if self.titles.isEmpty {
            let alertController = UIAlertController(title: nil, message: "Sua busca não apresentou resultados.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
    }
}






// MARK: - UITableViewDataSource Methods

extension FavoritesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavoritesTableViewCell
        DispatchQueue.main.async {
            if let urlPath = URL(string: "https://image.tmdb.org/t/p/w185\(self.paths[indexPath.row])") {
                let imageData = NSData(contentsOf: urlPath)
                let poster = UIImage(data: imageData! as Data)
                cell.ivPoster.image = poster
            } else {
                cell.ivPoster.image = nil
            }
            cell.lbTitle.text = self.titles[indexPath.row]
            cell.lbYear.text = self.years[indexPath.row]
            cell.tvPlot.text = self.plots[indexPath.row]
        }
        return cell
    }
    
}


// MARK: - UITableViewDelegate Methods

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Tirando filme da lista de favoritos
        let delete = UITableViewRowAction(style: .destructive, title: "Unfavorite") { (action, indexPath) in
            // Tirando da tableView
            self.titles.remove(at: indexPath.row)
            self.years.remove(at: indexPath.row)
            self.plots.remove(at: indexPath.row)
            self.paths.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            // Eliminando do Core Data
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavMovie")
            do {
                self.favMovieManagedObjectArray = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            managedContext.delete(self.favMovieManagedObjectArray[indexPath.row])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        return [delete]
    }
    
}


