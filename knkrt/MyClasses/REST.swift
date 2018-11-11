//
//  REST.swift
//  knkrt
//
//  Created by Vitor Paolozzi on 07/11/18.
//  Copyright © 2018 San Blas Studio. All rights reserved.
//

import Foundation
import UIKit

class REST {
    // Variável necessária para o scroll infinito
    static var page: Int = 1
    // Variável para receber todos os filmes baixados
    static var allMovies: [Movie] = []
    // Variável necessária para download dos filmes
    private static let session = URLSession.shared
    
    class func getGenre(array: [Int], onComplete: @escaping ([String]) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=894889feb3bd8fc5b0706704193cdb89&language=en-US")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let genreInfo = try? JSONDecoder().decode(GenreInfo.self, from: data!)
                let genres: [Genre] = genreInfo!.genres
                var genresArray: [String] = []
                for i in 0..<array.count {
                    for ii in 0..<genres.count {
                        if genres[ii].id == array[i] {
                            genresArray.append(genres[ii].name)
                        }
                    }
                }
                onComplete(genresArray)
            }
        })
        dataTask.resume()
    }
    
    
    
    
    class func getMovies(page: Int, onComplete: @escaping (MovieDBInfo?) -> Void) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/popular?page=\(page)&language=en-US&api_key=894889feb3bd8fc5b0706704193cdb89")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                // Disparando alerta de falta de conexão
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "no internet"), object: nil)
            } else {
                let movieDBInfo = try? JSONDecoder().decode(MovieDBInfo.self, from: data!)
                let movies: [Movie] = movieDBInfo!.results as [Movie]
                for i in 0..<movies.count {
                    allMovies.append(movies[i])
                    allMovies = allMovies.uniqued()
                }
                onComplete(movieDBInfo)
                // Disparando sinal para parar o activityIndicator
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stop"), object: nil)
            }
        })
        dataTask.resume()
    }
}


// Extensão para permitir função que tira duplicatas de array de Movies
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}



