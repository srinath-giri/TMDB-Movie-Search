//
//  ServerUtils.swift
//  CurrencyConverter
//
//  Created by Srinath Giri on 9/16/19.
//  Copyright © 2019 Example. All rights reserved.
//

import Foundation
import UIKit

class ServerUtils {
  
  private let session: URLSession
  private let searchUrl: URL
  private let posterUrl: URL
  
  private let isDevelopmentBuild: Bool
  
  typealias FetchSearchResultsCompletionHandler = (_ movieSearchResult: MovieSearchResult?, _ error: Error?) -> Void
  typealias FetchPosterCompletionHandler = (_ poster: UIImage?, _ error: Error?) -> Void
  
  static let serverUtils = ServerUtils()
  
  static var `default`: ServerUtils {
    return serverUtils
  }
  
  
  private init() {
    session = URLSession.shared
    searchUrl = URL(string: "https://api.themoviedb.org/3/search/movie")!
    posterUrl = URL(string: "https://image.tmdb.org/t/p")!
    isDevelopmentBuild = false
  }
  
  
  static func buildHTTPGetRequest(baseUrl: URL, subPath:String? = nil, contentType: String? = nil, params: [(key: String, value: String)]) -> URLRequest? {
    var components = URLComponents()
    components.host = baseUrl.host
    components.path = baseUrl.path + (subPath ?? "")
    components.scheme = baseUrl.scheme
    
    var queryItems: [URLQueryItem] = []
    
    for (key, value) in params {
      queryItems.append(URLQueryItem(name: key, value: value))
    }

    queryItems.append(URLQueryItem(name: "api_key", value: "773a667a8037199d25a1604be67408e1"))
    
    components.queryItems = queryItems
    
    guard let urlWithQueryItems = components.url else {
      print("Unable to build query URL from URL components. params=\(params)")
      return nil
    }
    
    var urlRequest = URLRequest(url: urlWithQueryItems)
    urlRequest.httpMethod = "GET"
    urlRequest.setValue(contentType ?? "application/json", forHTTPHeaderField: "Content-Type")
    
    return urlRequest
  }
  
  
  func getMovieSearchResults (
    searchQueryText: String, page: Int = 1, completionHandler: @escaping FetchSearchResultsCompletionHandler
    ) {
    
    var params: [(key: String, value: String)] = []
    params.append((key: "page", value: String(page)))
    params.append((key: "query", value: searchQueryText))
    params.append((key: "include_adult", value: "false"))
    params.append((key: "language", value: "en-US"))
    
    guard let getUrlRequest = ServerUtils.buildHTTPGetRequest(baseUrl: searchUrl, params: params) else {
      print("HTTP Request Error. Unable to form GET request. params=\(params)")
      completionHandler(nil, URLError(.badURL))
      return
    }
    
    let fetchMatchingMoviesTask = session.dataTask(with: getUrlRequest) { data, response, error in
      
      if let error = error {
        print("Client Error. error=\(error)")
        completionHandler(nil, error)
        return
      }
      
      guard let response = response as? HTTPURLResponse else {
        print("Server Error. Missing HTTP response")
        completionHandler(nil, URLError(.badServerResponse))
        return
      }
      
      if response.statusCode >= 300 {
        print("Server Error. Status Code=\(response.statusCode)")
        completionHandler(nil, URLError(.resourceUnavailable))
        return
      }
      
      guard let mime = response.mimeType, mime == "application/json" else {
        print("Data Error. Unexpected MIME type.")
        completionHandler(nil, URLError(.badServerResponse))
        return
      }
      
      guard let data = data else {
        print("Data Error. Missing data payload.")
        completionHandler(nil, URLError(.badServerResponse))
        return
      }
      
      do {
        let jsonDecoder = JSONDecoder()
     
        let movieSearchResult = try jsonDecoder.decode(MovieSearchResult.self, from: data)
        print("Successfully fetched movie search results. movieSearchResult=\(movieSearchResult)")
        
        completionHandler(movieSearchResult, nil)
      } catch {
        print("Data error. Unable to create MovieSearchResult object from raw data. error=\(error.localizedDescription) data=\(data)")
        completionHandler(nil, URLError(.badServerResponse))
      }
    }
    
    fetchMatchingMoviesTask.resume()
  }

  
  func getMoviePoster (movie: Movie, completionHandler: @escaping FetchPosterCompletionHandler) {

    guard let posterPath = movie.poster_path else {
      print("HTTP Request Error. Missing movie poster path. movie=\(movie)")
      completionHandler(nil, URLError(.badURL))
      return
    }

    let defaultWidthPathComponent = "/w342"
    let imageResourcePath = posterPath
    
    guard let getUrlRequest = ServerUtils.buildHTTPGetRequest(baseUrl: posterUrl, subPath: defaultWidthPathComponent + imageResourcePath, contentType: "image/jpeg", params: []) else {
      print("HTTP Request Error. Unable to form GET request. movie=\(movie)")
      completionHandler(nil, URLError(.badURL))
      return
    }
    
    let fetchMoviePosterTask = session.dataTask(with: getUrlRequest) { data, response, error in
      
      if let error = error {
        print("Client Error. error=\(error)")
        completionHandler(nil, error)
        return
      }
      
      guard let response = response as? HTTPURLResponse else {
        print("Server Error. Missing HTTP response")
        completionHandler(nil, URLError(.badServerResponse))
        return
      }
      
      if response.statusCode >= 300 {
        print("Server Error. Status Code=\(response.statusCode)")
        completionHandler(nil, URLError(.resourceUnavailable))
        return
      }
      
      guard let mime = response.mimeType, mime == "image/jpeg" else {
        print("Data Error. Unexpected MIME type.")
        completionHandler(nil, URLError(.badServerResponse))
        return
      }
      
      guard let data = data else {
        print("Data Error. Missing data payload.")
        completionHandler(nil, URLError(.badServerResponse))
        return
      }
        
      if let moviePoster = UIImage(data: data, scale: CGFloat(3.0)) {
        print("Successfully fetched movie poster. moviePoster=\(moviePoster.size)")
        completionHandler(moviePoster, nil)
      } else {
        print("Data error. Unable to create movie poster UIImage from raw data. data.count=\(data.count)")
        completionHandler(nil, URLError(.badServerResponse))
      }
    }
    
    fetchMoviePosterTask.resume()
  }

}
