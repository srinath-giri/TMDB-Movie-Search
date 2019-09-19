//
//  Movie.swift
//  MovieSearch
//
//  Created by Srinath Giri on 9/16/19.
//  Copyright © 2019 Example. All rights reserved.
//


class Movie: Codable, Equatable, CustomDebugStringConvertible {

  var id: Int
  var title: String?
  var release_date: String?
  var overview: String?
  var poster_path: String?
  
  var debugDescription: String {
    return "<Id: \(id), Title: \(title ?? "Unknown"), Poster Path: \(poster_path ?? "nil")>"
  }

  
  static func == (lhs: Movie, rhs: Movie) -> Bool {
    return lhs.id == rhs.id
  }
  
}
