//
//  ApiNetwork.swift
//  MuuPlay
//
//  Created by Julio César Vaca García on 28/10/25.
//

import Foundation

class ApiNetwork {
    
    private let tmdbApiKey = "0d88d2af7100183d09e436614ebaa6de"
    
    // MARK: - TMDB Models
    struct TMDBResponse: Codable {
        let results: [TMDBMovie]
    }
    
    struct TMDBMovie: Codable, Identifiable {
        let id: Int
        let title: String
        let posterPath: String?
        let overview: String
        let releaseDate: String?
        let voteAverage: Double
        
        enum CodingKeys: String, CodingKey {
            case id, title, overview
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case voteAverage = "vote_average"
        }
        
        var posterURL: URL? {
            guard let posterPath = posterPath else { return nil }
            return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
        }
        
        var embedURL: String {
            return "https://vidsrc.to/embed/movie/\(id)"
        }
        
        var quality: String {
            return voteAverage >= 7.0 ? "HD" : "SD"
        }
        
        var year: String {
            guard let releaseDate = releaseDate else { return "" }
            return String(releaseDate.prefix(4))
        }
    }
    
    // MARK: - Buscar películas por nombre
    func searchMovies(query: String) async throws -> [TMDBMovie] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(tmdbApiKey)&language=es-MX&query=\(encodedQuery)&page=1"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
        return response.results
    }
    
    // MARK: - Películas populares (para la página principal)
    func getPopularMovies(page: Int = 1) async throws -> [TMDBMovie] {
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(tmdbApiKey)&language=es-MX&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
        return response.results
    }
    
    // MARK: - Películas en tendencia
    func getTrendingMovies() async throws -> [TMDBMovie] {
        let urlString = "https://api.themoviedb.org/3/trending/movie/week?api_key=\(tmdbApiKey)&language=es-MX"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TMDBResponse.self, from: data)
        return response.results
    }
}
