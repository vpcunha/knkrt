//
//  PopMoviesViewController.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 07/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import UIKit
import CoreData

class PopMoviesViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    
    // Variável para receber filmes baixados
    var movies: [Movie] = []
    // Variável pra enviar dados do filme para a DetailsVC
    var selectedMovie: Movie!
    // Variável pra fazer busca
    var searchString:String!
    // Array para search
    var allMovies: [Movie] = []
    // Variável pra receber lista de filmes favoritos
    var favoriteMovies: [String] = []
    // Variável para recarregar tela se filme tiver sido favoritado
    var favoriteCount = 0
    // Variável exigida pelo Core Data
    var favMovieManagedObjectArray:[NSManagedObject] = []
    // Constantes pra definir número de filmes por linha na collectionView
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    // Cores
    let mustardColor = UIColor(red: 247/255, green: 206/255, blue: 91/255, alpha: 1.0)
    let darkMustardColor = UIColor(red: 217/255, green: 151/255, blue: 30/255, alpha: 1.0)
    // Variável pra impedir que usuário faça outra solicitação (scrolando no fim da collectionView) antes de a primeira solicitação ter terminado.
    var loadingMovies:Bool = false
    // Variável pra pedir nova página no MovieDB
    var currentPage = 1
    // Variável para determinar fim de pedidos por novas páginas ao MovieDB
    var total = 0
    
    
    // MARK: - Super Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Parando activityIndicator quando filmes já foram carregados
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "stop"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.loading.stopAnimating()
            }
        }
        // Alerta de problema na conexão
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "no internet"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                let action = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                    self.loading.stopAnimating()
                })
                self.showAlert(action: action, message: "Aconteceu algum erro. Cheque a sua conexão.")
            }
        }
        // Programando o spinner do activityIndicator
        loading.startAnimating()
        loading.hidesWhenStopped = true
        // Título da tela
        navigationItem.title = "Movies"
        // Configurando collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        // Configurando searchBar
        searchBar.delegate = self
        // Cor do botão e textos da barra superior
        self.navigationController?.navigationBar.tintColor = .black
        // cor de fundo da barra
        self.navigationController?.navigationBar.barTintColor = mustardColor
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
        // Cor do texto da searchBar
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .black
        // Baixando os filmes
        loadMovies()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Para poder atualizar collectionView quando filme for favoritado
        favoriteCount = favoriteMovies.count
        // Recuperando filmes do Core Data. Para atualizar filmes favoritados
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
        // Recarregando filmes (para o caso de usuário ter aberto app sem conexão)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "wake up"), object: nil, queue: nil) { (notification) in
            self.currentPage = 1
            self.total = 0
            self.movies = []
            self.loadMovies()
        }
        // Recarregando tela se usuário tiver incluído filme favorito
        if favoriteCount != favoriteMovies.count {
            collectionView.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromPopToDetail" {
            let vc = segue.destination as! DetailViewController
            vc.selectedMovie = selectedMovie
        }
    }
    
    
    // MARK: - Methods
    
    // Fazendo o download dos filmes
    func loadMovies() {
        loadingMovies = true
        REST.getMovies(page: currentPage) { (info) in
            if let info = info {
                self.movies += info.results
                self.total = info.total_results
                DispatchQueue.main.async {
                    self.loadingMovies = false
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    func showAlert(action: UIAlertAction, message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(action)
        alertController.show()
    }
    
}


// MARK: - UISearchBarDelegate Methods

extension PopMoviesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Guard let para evitar crash se usuário tocar em "buscar" no teclado com campo de busca vazio
        guard let search = searchString else {
            searchBar.resignFirstResponder()
            return
        }
        if searchString == "" {
            searchBar.resignFirstResponder()
        }
        // Let para aplicar filtro. [c] significa case insensitive. Se quisesse busca com case sensitive, faria:
        //let searchPredicate = NSPredicate(format: "SELF CONTAINS %@", search)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", search)
        // Fazendo a busca nos títulos
        var allMoviesTitles: [String] = []
        allMovies = []
        for i in 0..<REST.allMovies.count {
            allMoviesTitles.append(REST.allMovies[i].title)
            allMovies.append(REST.allMovies[i])
        }
        // Array com resultados nos títulos como Any
        let firstTitlesArray = (allMoviesTitles as NSArray).filtered(using: searchPredicate)
        // Array para receber Any transformados em String
        var secondTitlesArray:[String] = []
        // Transformando Any em String
        for i in 0..<firstTitlesArray.count {
            secondTitlesArray.append(firstTitlesArray[i] as! String)
        }
        var temp: [Movie] = []
        for i in 0..<allMovies.count {
            for ii in 0..<secondTitlesArray.count {
                if allMovies[i].title == secondTitlesArray[ii] {
                    temp.append(allMovies[i])
                }
            }
        }
        allMovies = temp
        // Alimentando as variáveis que preencherão a collectionView
        movies = allMovies
        // Recarregando a collectioView
        collectionView.reloadData()
        searchBar.resignFirstResponder()
        // Alerta de busca vazia
        if movies.count == 0 {
            let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (alertAction) in
                searchBar.text = ""
                self.currentPage = 1
                self.total = 0
                self.loadMovies()
            }
            showAlert(action: action, message: "Sua busca não apresentou resultados.")
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        movies = []
        collectionView.reloadData()
    }
}


// MARK: - UICollectionViewDataSource Methods

extension PopMoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
     
     // Método para scroll infinito
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // - 10 pq scroll do usuário está chegando no fim da página.
        // !loadingMovies -> se não estiver carregando (variável pra impedir que usuário faça outra solicitação (scrolando no fim da collectionView) antes de a primeira solicitação ter terminado.)
        // !total -> se já tiver carregado todos os filmes não precisa mais
        if indexPath.row == movies.count - 10 && !loadingMovies && movies.count != total {
            currentPage += 1
            loadMovies()
        }
    }
 
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! KnkrtCollectionViewCell
        // Configurando a célula
        DispatchQueue.main.async {cell.prepareCell(favorite: self.favoriteMovies, movie: self.movies[indexPath.row])
        }
        cell.backgroundColor = UIColor.black
        cell.lbTitle.textColor = mustardColor
        return cell
    }
    
}



// MARK: - UICollectionViewDelegate Methods

extension PopMoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMovie = movies[indexPath.row]
        performSegue(withIdentifier: "fromPopToDetail", sender: nil)
    }
}




// MARK: - UICollectionViewDelegateFlowLayout Methods

// Definindo propriedades da collectionView e número de itens por linha
extension PopMoviesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}


// MARK: - Extension UIAlertController Method

public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}




