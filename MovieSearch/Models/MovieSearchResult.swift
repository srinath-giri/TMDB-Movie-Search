//
//  SearchResponse.swift
//  MovieSearch
//
//  Created by Srinath Giri on 9/16/19.
//  Copyright © 2019 Example. All rights reserved.
//


import Foundation

class MovieSearchResult: Codable, CustomDebugStringConvertible {
  
  var page: Int
  var total_results: Int
  var total_pages: Int
  var results: [Movie]
  
  var debugDescription: String {
    return "<Page: \(page), Results Count: \(results.count), Total Results Count: \(total_results), Total Pages Count: \(total_pages)>"
  }
}

