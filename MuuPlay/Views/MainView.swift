//
//  MainView.swift
//  MuuPlay
//
//  Created by Julio César Vaca García on 28/10/25.
//

import SwiftUI

struct MainView: View {
    
    @State private var movies: [ApiNetwork.TMDBMovie] = []
    @State private var loading = true
    @State private var searchText = ""
    @State private var isSearching = false
    
    let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo degradado
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.8),
                        Color.blue.opacity(0.8),
                        Color.black.opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Header con título y buscador
                    VStack(spacing: 15) {
                        Text("🎬 MuuPlay")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 8)
                            .padding(.top, 15)
                        
                        // Buscador
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.7))
                            
                            TextField("Buscar películas...", text: $searchText)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .autocorrectionDisabled()
                                .submitLabel(.search)
                                .onSubmit {
                                    Task {
                                        await searchMovies()
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    Task {
                                        await loadPopularMovies()
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                    
                    // MARK: - Contenido
                    if loading {
                        Spacer()
                        ProgressView("Cargando películas...")
                            .foregroundColor(.white)
                            .font(.title3)
                        Spacer()
                    } else if movies.isEmpty {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "film.stack")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.5))
                            Text("No se encontraron películas")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                ForEach(movies) { movie in
                                    NavigationLink(destination: PlayerView(movie: movie)) {
                                        MovieCard(movie: movie)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await loadPopularMovies()
        }
        .onChange(of: searchText) { oldValue, newValue in
            if newValue.isEmpty && !oldValue.isEmpty {
                Task {
                    await loadPopularMovies()
                }
            }
        }
    }
    
    // MARK: - Cargar películas populares
    func loadPopularMovies() async {
        loading = true
        do {
            movies = try await ApiNetwork().getPopularMovies()
        } catch {
            print("❌ Error al cargar películas: \(error.localizedDescription)")
        }
        loading = false
    }
    
    // MARK: - Buscar películas
    func searchMovies() async {
        guard !searchText.isEmpty else { return }
        
        loading = true
        isSearching = true
        do {
            movies = try await ApiNetwork().searchMovies(query: searchText)
        } catch {
            print("❌ Error al buscar películas: \(error.localizedDescription)")
        }
        loading = false
    }
}

// MARK: - Tarjeta de película
struct MovieCard: View {
    let movie: ApiNetwork.TMDBMovie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 250)
                    .clipped()
                    .cornerRadius(14)
                    .shadow(radius: 5)
            } placeholder: {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 170, height: 250)
                    .overlay(
                        VStack {
                            ProgressView()
                            Text(movie.title)
                                .font(.caption)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(8)
                        }
                    )
            }
            
            Text(movie.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(width: 170, alignment: .leading)
            
            HStack {
                Text(movie.year)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                }
                .foregroundColor(.yellow)
            }
            .frame(width: 170)
        }
    }
}

#Preview {
    MainView()
}
