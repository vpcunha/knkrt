//
//  SomeClasses.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 07/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import Foundation


struct MovieDBInfo: Codable {
    let page: Int
    let results: [Movie]
    let total_results: Int
    let total_pages: Int
}


// Tornando struct hashable pra permitir função que elimina duplicatas de arrays
struct Movie: Codable, Hashable {
    let poster_path: String?
    let overview: String
    let release_date: String
    let genre_ids: [Int]
    let id: Int
    let title: String
    let backdrop_path: String?
    
    var hashValue: Int {
        return id.hashValue
    }
}


struct GenreInfo: Codable {
    let genres: [Genre]
}



struct Genre: Codable {
    let id: Int
    let name: String
}













