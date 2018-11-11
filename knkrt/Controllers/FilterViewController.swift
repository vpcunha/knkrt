//
//  FilterViewController.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 09/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    
    // Variável para preencher tableView
    var fillTableView = ["Year", "Genre"]
    // Variáveis para enviar anos e gêneros dos filmes favoritos para a SubFilterVC
    var years: [String] = []
    var genres: [String] = []
    // Variáveis pra preencher detalhe da célula
    var detailYear = ""
    var detailGenre = ""
    // Cor
    let mustardColor = UIColor(red: 247/255, green: 206/255, blue: 91/255, alpha: 1.0)
    
    
    // MARK: - Super Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filter"
        // Configurando tableView
        tableView.delegate = self
        tableView.dataSource = self
        // Elimina células vazias após fim do conteúdo
        tableView.tableFooterView = UIView()
        // Tirando duplicatas e fazendo sort da lista de anos
        years = years.uniqued()
        years = years.sorted(by: { $0 > $1 })
        // Preparando string com lista de gêneros
        var one = ""
        var two: [String] = []
        var three = ""
        var four: [String] = []
        for i in 0..<genres.count {
            three = genres[i].replacingOccurrences(of: ", ", with: ",")
            four.append(three)
        }
        for i in 0..<four.count {
            var temp = [Character](four[i])
            temp.insert(",", at: temp.count)
            for ii in 0..<temp.count {
                if temp[ii] != "," {
                    one.append(temp[ii])
                } else if temp[ii] == "," {
                    two.append(one)
                    one = ""
                }
            }
        }
        genres = two.uniqued()
        genres.sort()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recebendo filtros da SubFilterVC e recarregando tableView
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
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "yearSegue" {
            let vc = segue.destination as! SubFilterViewController
            vc.years = years
            vc.title = "Year"
        } else if segue.identifier == "genreSegue" {
            let vc = segue.destination as! SubFilterViewController
            vc.genres = genres
            vc.title = "Genre"
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    
    // MARK: - IBActions
    
    @IBAction func backToFavorites(_ sender: UIButton) {
        // Avisando FavoritesVC que botão Apply foi acionado
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "apply"), object: true)
        // Voltando para a FavoritesVC
        _ = navigationController?.popViewController(animated: true)
    }
}




// MARK: - UITableViewDataSource Methods

extension FilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = detailYear
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = detailGenre
        }
        cell.textLabel?.text = fillTableView[indexPath.row]
        cell.detailTextLabel?.textColor = mustardColor
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}


// MARK: - UITableViewDelegate Methods

extension FilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "yearSegue", sender: self)
        } else {
            performSegue(withIdentifier: "genreSegue", sender: self)
        }
    }
}











