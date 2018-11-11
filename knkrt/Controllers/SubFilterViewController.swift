//
//  SubFilterViewController.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 09/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import UIKit

class SubFilterViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    
    // Variáveis para receber anos e gêneros existentes nos filmes da lista de favoritos
    var years: [String] = []
    var genres: [String] = []
    // Variável pra marcar célula ticada
    var selectedCell: Int!
    // Cor
    let mustardColor = UIColor(red: 247/255, green: 206/255, blue: 91/255, alpha: 1.0)
    
    
    // MARK: - Super Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}


// MARK: - UITableViewDataSource Methods

extension SubFilterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number: Int!
        if !years.isEmpty {
            number = years.count
        } else {
            number = genres.count
        }
        return number
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Definindo célula que vai aparecer com checkmark
        if selectedCell != indexPath.row {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
        // Preenchendo célula com ano ou gênero
        if !years.isEmpty {
            cell.textLabel?.text = years[indexPath.row]
        } else {
            cell.textLabel?.text = genres[indexPath.row]
        }
        cell.tintColor = mustardColor
        return cell
    }
    
}


// MARK: - UITableViewDelegate Methods

extension SubFilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath.row
        // Enviando para a FilterVC filtros escolhidos
        if self.title == "Year" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chosenYear"), object: years[indexPath.row])
        } else if self.title == "Genre" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "chosenGenre"), object: genres[indexPath.row])
        }
        tableView.reloadData()
    }
}










