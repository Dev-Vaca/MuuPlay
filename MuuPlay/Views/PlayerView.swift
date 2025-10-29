//
//  PlayerView.swift
//  MuuPlay
//
//  Created by Julio César Vaca García on 28/10/25.
//

import SwiftUI
import WebKit

struct PlayerView: View {
    let movie: ApiNetwork.TMDBMovie
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text(movie.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                
                WebVideoPlayer(urlString: movie.embedURL)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - WebView para reproducir video
struct WebVideoPlayer: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.allowsBackForwardNavigationGestures = false
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
