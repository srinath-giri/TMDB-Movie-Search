//
//  MovieSearchViewController.swift
//  MovieSearch
//
//  Created by Srinath Giri on 9/16/19.
//  Copyright © 2019 Example. All rights reserved.
//

import UIKit

class MovieSearchViewController: UIViewController {
  
  @IBOutlet weak var movieResultsTableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var bannerLabel: UILabel!
  
  var movies: [Movie] = []
  var posters: [String: UIImage] = [:]
  var movieSearchResultLastFetched: MovieSearchResult?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.movieResultsTableView.dataSource = self
    self.movieResultsTableView.delegate = self
    self.movieResultsTableView.rowHeight = UITableView.automaticDimension;
    self.movieResultsTableView.estimatedRowHeight = 300.0;
    self.searchBar.delegate = self
    self.updateUi()
  }

  
  func updateUi() {
    self.movieResultsTableView.reloadData()
  }
  

  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if let movieCell = sender as? MovieSearchResultTableViewCell, identifier == "showDetailedDescription" {
      return !movieCell.isShowingFullDescription()
    }
    
    return false
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let movieCell = sender as? MovieSearchResultTableViewCell, segue.identifier == "showDetailedDescription" {
      if let navVC = segue.destination as? UINavigationController, let destinationVC = navVC.visibleViewController as? MovieDescriptionViewController {
        destinationVC.movie =  movieCell.movie
      }
    }
  }
}


extension MovieSearchViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let movieResultCell = tableView.dequeueReusableCell(withIdentifier: "movieResultCell") as? MovieSearchResultTableViewCell {
      
      let movie = movies[indexPath.row]
      movieResultCell.movie = movie
      movieResultCell.viewControler = self
      
      if let posterPath = movie.poster_path, let posterImage = posters[posterPath] {
        movieResultCell.updateUi(posterImage: posterImage)
      } else {
        movieResultCell.updateUi()
      }
      return movieResultCell
    }
    
    return UITableViewCell()
  }
  
}


extension MovieSearchViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    if let movieSearchResultCell = cell as? MovieSearchResultTableViewCell, let movie = movieSearchResultCell.movie {
      
      // Fetch poster image for the movie
      
      if let posterPath = movie.poster_path, posters[posterPath] == nil {
      
        ServerUtils.default.getMoviePoster(movie: movie) { (posterImage, error) in
          
          if let error = error {
            print("Unable to get movie poster. movie=\(movie) error=\(error)")
            return
          }
          
          DispatchQueue.main.async {
           
            if let posterImage = posterImage, let posterPath = movie.poster_path {
              self.posters[posterPath] = posterImage
            }
            
            guard self.movies.contains(where: { return $0.id == movie.id }) else {
              print("Search is obsolete. No need to update the movieResultsTableView with the downloaded image.")
              return
            }

            self.movieResultsTableView.reloadRows(at: [indexPath], with: .none)
          }
        }
      }
      
      // Fetch next page of movie search results.
      
      if let lastMovieResult = movies.last, lastMovieResult == movie {
        
        guard let movieSearchResultLastFetched = movieSearchResultLastFetched, movieSearchResultLastFetched.page < movieSearchResultLastFetched.total_pages else {
          print("Reached end of search results.")
          return
        }
        
        guard let searchText = searchBar.text else {
          print("No text in search bar.")
          return
        }
        
        ServerUtils.default.getMovieSearchResults(searchQueryText: searchText, page: movieSearchResultLastFetched.page + 1) { (movieSearchResult, error) in
          
          DispatchQueue.main.async {
            if let error = error {
              self.bannerLabel.text = error.localizedDescription
              return
            }
            
            if let movieSearchResult = movieSearchResult {
              self.movieSearchResultLastFetched = movieSearchResult
              self.movies.append(contentsOf: movieSearchResult.results)
              self.bannerLabel.text = ""
            }
            
            self.updateUi()
          }
        }
      }
    }
  }
}


extension MovieSearchViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    guard !searchText.isEmpty else {
      self.movies.removeAll()
      self.bannerLabel.isHidden = true
      self.updateUi()
      return
    }

    ServerUtils.default.getMovieSearchResults(searchQueryText: searchText) { (movieSearchResult, error) in
      
      DispatchQueue.main.async {
          if let error = error {
            self.bannerLabel.text = error.localizedDescription
            self.bannerLabel.isHidden = false
            return
          }

          self.movies.removeAll()
        
          if let movieSearchResult = movieSearchResult {
            self.movieSearchResultLastFetched = movieSearchResult
            self.movies.append(contentsOf: movieSearchResult.results)
            
            if movieSearchResult.total_results == 0 {
              self.bannerLabel.text = "No matching results!"
              self.bannerLabel.isHidden = false
            } else {
              self.bannerLabel.text = ""
              self.bannerLabel.isHidden = true
            }
            
          }

          self.updateUi()
      }
    }
    
  }
  
}

